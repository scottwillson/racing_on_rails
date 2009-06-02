module CreateIfBestResultForRaceExtension
  def create_if_best_result_for_race(attributes)
    source_result = attributes[:source_result]
    for score in @owner.scores
      same_race  = (score.source_result.race  == source_result.race)
      same_racer = (score.source_result.racer == source_result.racer)
      if same_race && score.source_result.racer && same_racer
        if attributes[:points] > score.points
          @owner.scores.delete(score)
        else
          return nil
        end
      end
    end
    create(attributes)
  end
end

# Race result
#
# Race is the only required attribute -- even +racer+ and +place+ can be blank
#
# Result keeps its own copy of +number+ and +team+, even though each Racer has
# a +team+ atribute and many RaceNumbers. Result's number is just a String, not
# a RaceNumber
#
# Doesn't support multiple hotspot points, though it should
class Result < ActiveRecord::Base
  # FIXME Make sure names are coerced correctly
  # TODO Add number (race_number) and license

  attr_accessor :updated_by

  before_save :find_associated_records
  before_save :save_racer
  after_save :update_racer_number
  after_destroy [ :destroy_racers, :destroy_teams ]

  has_many :scores, :foreign_key => 'competition_result_id', :dependent => :destroy, :extend => CreateIfBestResultForRaceExtension
  has_many :dependent_scores, :class_name => 'Score', :foreign_key => 'source_result_id', :dependent => :destroy
  belongs_to :category
  belongs_to :race
  belongs_to :racer
  belongs_to :team

  validates_presence_of :race

  def Result.find_all_for(racer)
    if racer.is_a? Racer
      racer_id = racer.id
    else
      racer_id = racer
    end
    Result.find(
      :all,
      :include => [:team, :racer, :scores, :category, {:race => [:event, :category]}],
      :conditions => ['racers.id = ?', racer_id]
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

  # Replace any new +racer+, or +team+ with one that already exists if name matches
  def find_associated_records
    _racer = racer
    if _racer && _racer.new_record?
      if _racer.name.blank?
        self.racer = nil
      else
        existing_racers = find_racers
        if existing_racers.size == 1
          self.racer = existing_racers.to_a.first
        elsif existing_racers.size > 1
          results = existing_racers.to_a.inject([]) { |results, racer| results + racer.results }
          if results.empty?
            self.racer = existing_racers.to_a.sort_by(&:updated_at).last
          else
            results = results.sort_by(&:date)
            self.racer = results.last.racer
          end
        end
      end
    end

    # This logic should be in Racer
    if !racer.nil? &&
       racer.new_record? &&
       !racer.first_name.blank? &&
       !racer.last_name.blank? &&
       racer[:member_from].blank? &&
       event.number_issuer.name == ASSOCIATION.short_name &&
       !RaceNumber.rental?(number, Discipline[event.discipline])

      racer.member_from = race.date
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

  # Use +first_name+, +last_name+, +race_number+, +team+ to figure out if +racer+ already exists.
  # Returns an Array of Racers if there is more than one potential match
  #
  # TODO refactor into methods or split responsibilities with Racer?
  # Need Event to match on race number. Event will not be set before result is saved to database
  def find_racers(_event = event)
    matches = Set.new
    
    # name
    matches = matches + Racer.find_all_by_name_or_alias(first_name, last_name)
    return matches if matches.size == 1

    # number
    if number.present? && (matches.size > 1 || (matches.empty? && first_name.blank? && last_name.blank?))
      race_numbers = RaceNumber.find_all_by_value_and_event(number, _event)
      race_numbers.each do |race_number|
        if matches.include?(race_number.racer)
          return [race_number.racer]
        else
          matches << race_number.racer
        end
      end
      return matches if matches.size == 1
    end

    # team
    unless team_name.blank?
      team = Team.find_by_name_or_alias(team_name)
      matches.reject! do |match|
        match.team != team
      end
    end

    # license
    unless self.license.blank?
      matches.reject! do |match|
        match.license != license
      end
    end

    matches
  end

  # Set +racer#number+ to +number+ if this isn't a rental number
  def update_racer_number
    discipline = Discipline[event.discipline]
    if racer && !number.blank? && !RaceNumber.rental?(number, discipline)
      racer.updated_by = self.updated_by
      event.number_issuer unless event.number_issuer
      racer.add_number(number, discipline, event.number_issuer, event.date.year)
    end
  end

  def save_racer
    if racer && (racer.new_record? || racer.changed?)
      racer.created_by = event
      racer.save!
    end
  end

  # Destroy Racers that only exist because they were created by importing results
  def destroy_racers
    if racer && racer.results.count == 0 && racer.created_from_result? && !racer.updated_after_created?
      racer.destroy
    end
  end

  # Destroy Team that only exist because they were created by importing results
  def destroy_teams
    if team && team.results.count == 0 && team.racers.count == 0 && team.created_from_result? && !team.updated_after_created?
      team.destroy
    end
  end

  # Only used for manual entry of Cat 4 Womens Series Results
  def validate_racer_name
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
  def competition_result?
    self.event.is_a?(CrossCrusadeOverall) || event.is_a?(TaborOverall) || event.is_a?(Competition)
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
    if racer and !racer.first_name.blank?
      racer.first_name
    else
      ""
    end
  end

  def first_name=(value)
    if self.racer
      self.racer.first_name = value
    else
      self.racer = Racer.new(:first_name => value)
    end
  end

  def last_name
    if (racer and !racer.last_name.blank?)
      racer.last_name
    else
      ""
    end
  end

  def last_name=(value)
    if self.racer
      self.racer.last_name = value
    else
      self.racer = Racer.new(:last_name => value)
    end
  end

  # racer.name
  def name
    if racer == nil
      ""
    else
      racer.name
    end
  end

  def racer_name
    name
  end

  # racer.name
  def name=(value)
    if value.blank?
      self.racer = nil
      return value
    end

    if racer
      racer_for_name = Racer.new(:name => value)
      existing_racers = Racer.find_all_by_name_or_alias(racer_for_name.first_name, racer_for_name.last_name)
      if existing_racers.size == 1
        self.racer = existing_racers.first
      else
        racer_id_will_change!
        racer.name = value
      end
    else
      self.racer = Racer.new(:name => value)
    end
  end

  def racer_name=(value)
    name = value
  end

  # Team name when result was created
  def team_name
    if self.team
      team.name(date) || ""
    else
      ""
    end
  end

  # Racer's current team name
  def racer_team_name
    if racer
      racer.team_name
    else
      ""
    end
  end

  def team_name=(value)
    team_id_will_change!
    if team.nil? || team.name != value
      self.team = Team.new(:name => value)
    end
    if racer && racer.team_name != value
      racer.team = team
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
    when Time, DateTime  
      self[attribute] = value.hour * 3600 + value.min * 60 + value.sec + (value.usec / 100.0)
      self[attribute]
    else
      self[attribute] = value
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
  # This method doesn't handle some typical edge cases very well
  def time_to_s(time)
    return '' if time == 0.0 or time.blank?
    hours = (time / 3600).to_i
    minutes = ((time - (hours * 3600)) / 60).floor
    seconds = (time - (hours * 3600).floor - (minutes * 60).floor)
    # TODO Use sprintf better
    seconds = sprintf('%0.2f', seconds)
    if hours > 0
      hour_prefix = "#{hours.to_s.rjust(2, '0')}:"
    end
    "#{hour_prefix}#{minutes.to_s.rjust(2, '0')}:#{seconds.rjust(5, '0')}"
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
      t
    end
  end

  # Fix common formatting mistakes and inconsistencies
  def cleanup
    cleanup_place
    cleanup_number
    self.first_name = cleanup_name(first_name)
    self.last_name = cleanup_name(last_name)
    self.team_name = cleanup_name(team_name)
  end

  # Drops the 'st' from 1st, among other things
  def cleanup_place
    if place
      normalized_place = place.to_s
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

  # Highest points first. Break ties by numbershighest placing
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
    max_results = max(scores_by_place.size, other_scores_by_place.size)
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

  def max(x, y)
    if x >= y
      x
    else
      y
    end
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
    "#<Result #{id} place #{place} race #{race_id} racer #{racer_id} team #{team_id} pts #{points}>"
  end
end