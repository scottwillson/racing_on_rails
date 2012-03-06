module CreateIfBestResultForRaceExtension
  def create_if_best_result_for_race(attributes)
    source_result = attributes[:source_result]
    scores = proxy_association.owner.scores
    scores.each do |score|
      same_race  = (score.source_result.race_id  == source_result.race_id)
      same_person = (score.source_result.person_id == source_result.person_id)
      if same_race && score.source_result.person && same_person
        if attributes[:points] > score.points
          scores.delete score
        else
          return nil
        end
      end
    end
    create attributes
  end
end

# Race result
#
# Race is the only required attribute -- even +person+ and +place+ can be blank
#
# Result keeps its own copy of +number+ and +team+, even though each Person has
# a +team+ atribute and many RaceNumbers. Result's number is just a String, not
# a RaceNumber
class Result < ActiveRecord::Base
  include Concerns::Result::Cleanup
  include Concerns::Result::Comparison
  include Concerns::Result::Time
  include Export::Results
  
  serialize :custom_attributes, Hash

  before_save :find_associated_records
  before_save :save_person
  before_save :cache_non_event_attributes
  before_create :cache_event_attributes
  before_save :ensure_custom_attributes
  after_save :update_person_number
  after_destroy [ :destroy_people, :destroy_teams ]

  has_many :scores, :foreign_key => 'competition_result_id', :dependent => :destroy, :extend => CreateIfBestResultForRaceExtension
  has_many :dependent_scores, :class_name => 'Score', :foreign_key => 'source_result_id', :dependent => :destroy
  belongs_to :category
  belongs_to :event
  belongs_to :race
  belongs_to :person
  belongs_to :team

  validates_presence_of :race

  scope :competition, where(:competition_result => true)

  attr_accessor :updater

  def self.find_all_for(person)
    if person.is_a? Person
      person_id = person.id
    else
      person_id = person
    end
    Result.find(
      :all,
      :include => [:team, :person, :scores, :category, {:race => [:event, :category]}],
      :conditions => ['people.id = ?', person_id]
    )
  end

  # Replace any new +person+, or +team+ with one that already exists if name matches
  def find_associated_records
    _person = person
    if _person && _person.new_record?
      if _person.name.blank?
        self.person = nil
      else
        existing_people = find_people
        if existing_people.size == 1
          self.person = existing_people.to_a.first
        elsif existing_people.size > 1
          self.person = Person.select_by_recent_activity(existing_people)
        end
      end
    end

    # This logic should be in Person
    if person && 
       RacingAssociation.current.add_members_from_results? &&
       person.new_record? &&
       person.first_name.present? &&
       person.last_name.present? &&
       person[:member_from].blank? &&
       event.number_issuer.association? &&
       !RaceNumber.rental?(number, Discipline[event.discipline])

      person.member_from = race.date
    end

    if team && team.new_record?
      if team.name.blank?
        self.team = nil
      else
        existing_team = Team.find_by_name_or_alias(team.name)
        self.team = existing_team if existing_team
      end
      if team && team.new_record?
        team.updater = event
      end
    end
    true
  end

  # Use +first_name+, +last_name+, +race_number+, +team+ to figure out if +person+ already exists.
  # Returns an Array of People if there is more than one potential match
  #
  # TODO refactor into methods or split responsibilities with Person?
  # Need Event to match on race number. Event will not be set before result is saved to database
  def find_people(_event = event)
    matches = Set.new
    
    #license first if present and source is reliable (USAC)
    if RacingAssociation.current.eager_match_on_license? && license.present?
      matches = matches + Person.find_all_by_license(license)
      return matches if matches.size == 1
    end
    
    # name
    matches = matches + Person.find_all_by_name_or_alias(:first_name => first_name, :last_name => last_name)
    return matches if matches.size == 1

    # number
    if number.present?
      if matches.size > 1
        # use number to choose between same names
        RaceNumber.find_all_by_value_and_event(number, _event).each do |race_number|
          if matches.include?(race_number.person)
            return [ race_number.person ]
          end
        end
      elsif name.blank?
        # no name, so try to match by number
        matches = RaceNumber.find_all_by_value_and_event(number, _event).map(&:person)
      end
    end

    # team
    unless team_name.blank?
      team = Team.find_by_name_or_alias(team_name)
      matches.reject! do |match|
        match.team != team
      end
      return matches if matches.size == 1
    end

    # license
    unless self.license.blank?
      matches.reject! do |match|
        match.license != license
      end
    end

    matches
  end

  # Set +person#number+ to +number+ if this isn't a rental number
  # FIXME optimize default number issuer business
  def update_person_number
    discipline = Discipline[event.discipline]
    default_number_issuer = NumberIssuer.find_by_name(RacingAssociation.current.short_name)
    if person && event.number_issuer && event.number_issuer != default_number_issuer && number.present? && !RaceNumber.rental?(number, discipline)
      person.updater = updater
      person.add_number(number, discipline, event.number_issuer, event.date.year)
    end
  end

  # Save associated Person
  def save_person
    if person && (person.new_record? || person.changed?)
      if person.new_record?
        person.updater = event
      end
      person.save!
    end
  end
  
  # Cache expensive cross-table lookups
  def cache_non_event_attributes
    self[:category_name] = category.try(:name)
    self[:first_name]    = person.try(:first_name, date)
    self[:last_name]     = person.try(:last_name, date)
    self[:name]          = person.try(:name, date)
    self[:team_name]     = team.try(:name, date)
  end
  
  def cache_event_attributes
    self[:competition_result]      = competition_result?
    self[:date]                    = event.date
    self[:event_date_range_s]      = event.date_range_s
    self[:event_end_date]          = event.end_date
    self[:event_full_name]         = event.full_name
    self[:event_id]                = event.id
    self[:race_full_name]          = race.try(:full_name)
    self[:race_name]               = race.try(:name)
    self[:team_competition_result] = team_competition_result?
    self.year                      = event.year
  end

  def cache_attributes!(*args)
    args = args.extract_options!
    event.disable_notification!
    cache_event_attributes if args.include?(:event)
    cache_non_event_attributes if args.empty? || args.include?(:non_event)
    save!
    event.enable_notification!
  end
  
  def ensure_custom_attributes
    if race_id && race.custom_columns && !custom_attributes
      self.custom_attributes = Hash.new
      race.custom_columns.each do |key|
        custom_attributes[key.to_sym] = nil
      end
    end
  end

  def custom_attributes=(hash)
    if hash
      symbolized_hash = Hash.new
      hash.each { |key, value| symbolized_hash[key.to_s.to_sym] = value}
    end
    self[:custom_attributes] = symbolized_hash
  end
  
  # Destroy People that only exist because they were created by importing results
  def destroy_people
    if person && person.results.count == 0 && person.created_from_result? && !person.updated_after_created?
      person.destroy
    end
  end

  # Destroy Team that only exist because they were created by importing results
  def destroy_teams
    if team && team.results.count == 0 && team.people.count == 0 && team.created_from_result? && !team.updated_after_created?
      team.destroy
    end
  end

  # Only used for manual entry of Cat 4 Womens Series Results
  def validate_person_name
    if first_name.blank? && last_name.blank?
      errors.add(:first_name, "and last name cannot both be blank")
    end
  end

  # Set points from +scores+
  def calculate_points
    if !scores.empty? and competition_result?
      pts = 0
      scores.each do |score|
        pts = pts + score.points
      end
      self.points = pts
    end
  end

  def category_name=(name)
    if name.blank?
      self.category = nil
    else
      self.category = Category.find_or_create_by_name(name)
    end
    self[:category_name] = name.try(:to_s)
  end

  def competition_result?
    if competition_result.nil?
      @competition_result = event.is_a?(Competition)
    else
      competition_result
    end
  end

  def team_competition_result?
    if team_competition_result.nil?
      @team_competition_result = event.is_a?(TeamBar) || event.is_a?(CrossCrusadeTeamCompetition) || event.is_a?(MbraTeamBar)
    else
      team_competition_result
    end
  end
  
  # TODO Cache this, too
  def team_size
    if race_id
      @team_size ||= Result.count(:conditions => ["race_id =? and place = ?", race_id, place])
    else
      @team_size ||= 1
    end
  end

  # Not blank, DNF, DNS, DQ.
  def finished?
    return false if place.blank?
    return false if ["DNF", "DNS", "DQ"].include?(place)
    place.to_i > 0
  end

  # Does this result belong to the last event in a MultiDayEvent?
  def last_event?
    return false unless self.event && event.parent
    return false unless event.parent.respond_to?(:parent)
    return true unless event.parent

    !(event.parent && (event.parent.end_date != self.date))
  end

  def date
    if race || race(true)
      race.date
    end
  end

  def distance
    race && race.distance
  end

  def event_id
    self[:event_id] || (race || race(true)).try(:event_id)
  end

  def event(reload = false)
    if race(reload)
      race.event(reload)
    end
  end

  def laps
    self[:laps] || (race && race.laps)
  end

  def place
    self[:place] || ''
  end

  def points
    if self[:points]
      self[:points].to_f
    else
      0.0
    end
  end

  # Hot spots
  def points_bonus_penalty=(value)
    if value == nil || value == ""
      value = 0
    end
    write_attribute(:points_bonus_penalty, value)
  end

  # Points from placing at finish, not from hot spots
  def points_from_place=(value)
    if value == nil || value == ""
      value = 0
    end
    write_attribute(:points_from_place, value)
  end

  def first_name=(value)
    if self.person
      self.person.first_name = value
    else
      self.person = Person.new(:first_name => value)
    end
    self[:first_name] = value
    self[:name] = self.person.try(:name, date)
  end

  def last_name=(value)
    if self.person
      self.person.last_name = value
    else
      self.person = Person.new(:last_name => value)
    end
    self[:last_name] = value
    self[:name] = self.person.try(:name, date)
  end

  def person_name
    name
  end

  # person.name
  def name=(value)
    if value.present?
      if person.try(:name) != value
        self.person = Person.new(:name => value)
      end
      self[:first_name] = person.first_name
      self[:last_name] = person.last_name
    else
      self.person = nil
      self[:first_name] = nil
      self[:last_name] = nil
    end
    self[:name] = value
  end

  def person_name=(value)
    self.name = value
  end

  # Person's current team name
  def person_team_name
    if person
      person.team_name
    else
      ""
    end
  end

  def team_name=(value)
    team_id_will_change!
    if team.nil? || team.name != value
      self.team = Team.new(:name => value)
    end
    if person && person.team_name != value
      person.team = team
    end
    self[:team_name] = value
  end
  
  def method_missing(sym, *args, &block)
    # Performance fix for results page. :to_ary would be called and trigger a load of race to get custom_attributes
    # May want to denormalize custom_attributes in Result.
    if sym == :to_ary
      return super
    end

    if sym != :custom_attributes && custom_attributes && custom_attributes.has_key?(sym)
      custom_attributes[sym]
    elsif race && race.custom_columns && race.custom_columns.include?(sym)
      nil
    else
      super
    end
  end

  # Add +race+ and +race#event+ name, time and points to default to_s
  def to_long_s
    "#<Result #{id}\t#{place}\t#{race.event.name}\t#{race.name} (#{race.id})\t#{name}\t#{team_name}\t#{self.category_name}\t#{points}\t#{time_s if self[:time]}>"
  end

  def to_s
    "#<Result #{id} place #{place} race #{race_id} person #{person_id} team #{team_id} pts #{points}>"
  end
end