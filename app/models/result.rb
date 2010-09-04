module CreateIfBestResultForRaceExtension
  def create_if_best_result_for_race(attributes)
    source_result = attributes[:source_result]
    @owner.scores.each do |score|
      same_race  = (score.source_result.race  == source_result.race)
      same_person = (score.source_result.person == source_result.person)
      if same_race && score.source_result.person && same_person
        if attributes[:points] > score.points
          @owner.scores.delete score
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
  attr_accessor :updated_by
  serialize :custom_attributes, Hash

  before_save :find_associated_records
  before_save :save_person
  after_save :update_person_number
  after_destroy [ :destroy_people, :destroy_teams ]

  has_many :scores, :foreign_key => 'competition_result_id', :dependent => :destroy, :extend => CreateIfBestResultForRaceExtension
  has_many :dependent_scores, :class_name => 'Score', :foreign_key => 'source_result_id', :dependent => :destroy
  belongs_to :category
  belongs_to :race
  belongs_to :person
  belongs_to :team

  validates_presence_of :race

  def Result.find_all_for(person)
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

  def attributes=(attributes)
    unless attributes.nil?
      if attributes[:first_name]
        self.first_name = attributes[:first_name]
      end
      if attributes[:last_name]
        self.last_name = attributes[:last_name]
      end
      if attributes[:team_name]
        self.team_name = attributes[:team_name]
      end
      if attributes[:category] && attributes[:category].is_a?(String)
        attributes[:category] = Category.find_or_create_by_name(attributes[:category])
      end
    end
    super(attributes)
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
       event.number_issuer.name == RacingAssociation.current.short_name &&
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
      team.created_by = event if team && team.new_record?
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
      person.updated_by = self.updated_by
      person.add_number(number, discipline, event.number_issuer, event.date.year)
    end
  end

  # Save associated Person
  def save_person
    if person && (person.new_record? || person.changed?)
      person.created_by = event
      person.save!
    end
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
      for score in scores
        pts = pts + score.points
      end
      self.points = pts
    end
  end

  def category_name
    (category && category.name) || ""
  end

  def category_name=(name)
    if name.blank?
      self.category = nil
    else
      self.category = Category.find_or_create_by_name(name)
    end
  end

  # TODO refactor to something like act_as_competitive or create CompetitionResult
  # TODO Is this method triggering additional DB calls?
  def competition_result?
    event.is_a?(Competition)
  end

  def team_competition_result?
    event.is_a?(TeamBar) || event.is_a?(CrossCrusadeTeamCompetition) || event.is_a?(MbraTeamBar)
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
    if race || race(true)
      race.event_id
    end
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

  def first_name
    if person and !person.first_name.blank?
      person.first_name(date)
    else
      ""
    end
  end

  def first_name=(value)
    if self.person
      self.person.first_name = value
    else
      self.person = Person.new(:first_name => value)
    end
  end

  def last_name
    if (person and !person.last_name.blank?)
      person.last_name(date)
    else
      ""
    end
  end

  def last_name=(value)
    if self.person
      self.person.last_name = value
    else
      self.person = Person.new(:last_name => value)
    end
  end

  # person.name
  def name
    if person == nil
      ""
    else
      person.name(date)
    end
  end

  def person_name
    name
  end

  # person.name
  def name=(value)
    if value.present?
      self.person = Person.new(:name => value)
    else
      self.person = nil
    end
  end

  def person_name=(value)
    self.name = value
  end

  # Team name when result was created
  def team_name
    if self.team
      team.name(date) || ""
    else
      ""
    end
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
  end

  def time=(value)
    set_time_value(:time, value)
  end

  def time_bonus_penalty=(value)
    set_time_value(:time_bonus_penalty, value)
  end

  def time_gap_to_leader=(value)
    set_time_value(:time_gap_to_leader, value)
  end

  def time_total=(value)
    set_time_value(:time_total, value)
  end

  def time_gap_to_previous=(value)
    set_time_value(:time_gap_to_previous, value)
  end

  def time_gap_to_winner=(value)
    set_time_value(:time_gap_to_winner, value)
  end

  def time_total=(value)
    set_time_value(:time_total, value)
  end

  def set_time_value(attribute, value)
    case value
    when DateTime
      self[attribute] = value.hour * 3600 + value.min * 60 + value.sec
    when Time
      self[attribute] = value.hour * 3600 + value.min * 60 + value.sec + (value.usec / 100.0)
    when Numeric, NilClass
      self[attribute] = value      
    else
      self[attribute] = s_to_time(value)
    end
  end

  # Time in hh:mm:ss.00 format. E.g., 1:20:59.75
  def time_s
    time_to_s(self.time)
  end

  # Time in hh:mm:ss.00 format. E.g., 1:20:59.75
  def time_s=(time)
    self.time = s_to_time(time)
  end

  # Time in hh:mm:ss.00 format. E.g., 1:20:59.75
  def time_total_s
    time_to_s(self.time_total)
  end

  # Time in hh:mm:ss.00 format. E.g., 1:20:59.75
  def time_total_s=(time_total)
    self.time_total = s_to_time(time_total)
  end

  # Time in hh:mm:ss.00 format. E.g., 1:20:59.75
  def time_bonus_penalty_s
    time_to_s(self.time_bonus_penalty)
  end

  # Time in hh:mm:ss.00 format. E.g., 1:20:59.75
  def time_bonus_penalty_s=(time_bonus_penalty)
    self.time_bonus_penalty = s_to_time(time_bonus_penalty)
  end

  # Time in hh:mm:ss.00 format. E.g., 1:20:59.75
  def time_gap_to_leader_s
    time_to_s(self.time_gap_to_leader)
  end

  # Time in hh:mm:ss.00 format. E.g., 1:20:59.75
  def time_gap_to_leader_s=(time_gap_to_leader_s)
    self.time_gap_to_leader = s_to_time(time_gap_to_leader_s)
  end

  # Time in hh:mm:ss.00 format. E.g., 1:20:59.75
  def time_gap_to_winner_s
    time_to_s time_gap_to_winner
  end

  # Time in hh:mm:ss.00 format. E.g., 1:20:59.75
  # This method doesn't handle some typical edge cases very well
  def time_to_s(time)
    return '' if time == 0.0 or time.blank?
    positive = time >= 0
    
    if !positive
      time = -time
    end
    
    hours = (time / 3600).to_i
    minutes = ((time - (hours * 3600)) / 60).floor
    seconds = (time - (hours * 3600).floor - (minutes * 60).floor)
    seconds = sprintf('%0.2f', seconds)
    if hours > 0
      hour_prefix = "#{hours.to_s.rjust(2, '0')}:"
    end
    "#{"-" unless positive}#{hour_prefix}#{minutes.to_s.rjust(2, '0')}:#{seconds.rjust(5, '0')}"
  end

  # Time in hh:mm:ss.00 format. E.g., 1:20:59.75
  # This method doesn't handle some typical edge cases very well
  def s_to_time(string)
    if string.to_s.blank?
      0.0
    else
      string.gsub!(',', '.')
      parts = string.to_s.split(':')
      parts.reverse!
      t = 0.0
      parts.each_with_index do |part, index|
        t = t + (part.to_f) * (60.0 ** index)
      end
      if parts.last && parts.last.starts_with?("-")
        -t
      else
        t
      end
    end
  end

  # Fix common formatting mistakes and inconsistencies
  def cleanup
    cleanup_place
    cleanup_number
    cleanup_license
    self.first_name = cleanup_name(first_name)
    self.last_name = cleanup_name(last_name)
    self.team_name = cleanup_name(team_name)
  end

  # Drops the 'st' from 1st, among other things
  def cleanup_place
    if place
      normalized_place = place.to_s.dup
      normalized_place.upcase!
      normalized_place.gsub!("ST", "")
      normalized_place.gsub!("ND", "")
      normalized_place.gsub!("RD", "")
      normalized_place.gsub!("TH", "")
      normalized_place.gsub!(")", "")
      normalized_place = normalized_place.to_i.to_s if normalized_place[/^\d+\.0$/]
      normalized_place.strip!
      normalized_place.gsub!(".", "")
      self.place = normalized_place
    else
      self.place = ""
    end
  end

  def cleanup_number
    self.number = number.to_s
    self.number = number.to_i.to_s if number[/^\d+\.0$/]
  end

  def cleanup_license
    self.license = license.to_s
    # USAC license numbers are being imported with a one decimal zero, e.g., 12345.0
    self.license = license.to_i.to_s if license[/^\d+\.0$/]
  end

  # Mostly removes unfortunate punctuation typos
  def cleanup_name(name)
    return name if name.nil?
    name = name.to_s
    return '' if name == '0.0'
    return '' if name == '0'
    return '' if name == '.'
    return '' if name.include?('N/A')
    name = name.gsub(';', '\'')
    name = name.gsub(/ *\/ */, '/')
  end

  # Highest points first. Break ties by highest placing
  # OBRA rules:
  # * The most first place finishes or, if still tied, the most second place finishes, etc., or if still tied;
  # * The highest placing in the last race, or the race nearest the last race in which at least one of the tied riders placed.
  #
  # Fairly complicated and procedural, but in nearly all cases, it short-circuits after comparing points
 def compare_by_points(other, break_ties = true)
    diff = other.points <=> points
    return diff if diff != 0 || !break_ties

    diff = compare_by_highest_place(other)
    return diff if diff != 0

    diff = compare_by_most_recent_place(other)
    return diff if diff != 0

    0
  end

  def compare_by_highest_place(other)
    scores_by_place = scores.sort do |x, y|
      x.source_result <=> y.source_result
    end
    other_scores_by_place = other.scores.sort do |x, y|
      x.source_result <=> y.source_result
    end
    max_results = [ scores_by_place.size, other_scores_by_place.size ].max
    return 0 if max_results == 0
    for index in 0..(max_results - 1)
      if scores_by_place.size == index
        return 1
      elsif other_scores_by_place.size == index
        return -1
      else
        diff = scores_by_place[index].source_result.place <=> other_scores_by_place[index].source_result.place
        return diff if diff != 0
      end
    end
    0
  end

  def compare_by_most_recent_place(other)
    dates = Set.new(scores + other.scores) { |score| score.source_result.date }.to_a
    dates.sort!.reverse!
    dates.each do |date|
      score = scores.detect { |s| s.source_result.event.date == date }
      other_score = other.scores.detect { |s| s.source_result.event.date == date }
      if score && !other_score
        return -1
      elsif !score && other_score
        return 1
      else
        diff = score.source_result.place <=> other_score.source_result.place
        return diff if diff != 0
      end
    end
    0
  end

  # Poor name. For comparison, we sort by placed, finished, DNF, etc
  def major_place
    if place.to_i > 0
      0
    elsif place.blank? || place == 0
      1
    elsif place.upcase == 'DNF'
      2
    elsif place.upcase == 'DQ'
      3
    elsif place.upcase == 'DNS'
      4
    else
      5
    end
  end

  def place_as_integer
    place.to_i
  end
  
  def method_missing(sym, *args, &block)
    if sym != :custom_attributes && custom_attributes && custom_attributes.has_key?(sym)
      custom_attributes[sym]
    else
      super
    end
  end

  # All numbered places first, then blanks, followed by DNF, DQ, and DNS
  def <=>(other)
    # Figure out the major position by place first, then break it down further if
    begin
      major_difference = (major_place <=> other.major_place)
      return major_difference if major_difference != 0

      if place.to_i > 0
        place.to_i <=> other.place.to_i
      elsif self.id
        self.id <=> other.id
      else
        0
      end
    rescue ArgumentError => error
      logger.error("Error in Result.<=> #{error} comparing #{self} with #{other}")
      throw error
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