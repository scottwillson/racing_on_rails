module CreateIfBestResultForRaceExtension
  def create_if_best_result_for_race(attributes)
    source_result = attributes[:source_result]
    for score in @owner.scores
      if score.source_result.race == source_result.race && score.source_result.racer == source_result.racer
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
  
  include Dirty
  
  # FIME Make sure names are coerced correctly
  # TODO Add number (race_number) and license
  
  before_validation :find_associated_records
  before_save :save_racer
  after_save :update_racer_team, :update_racer_number
  after_save {|result| result.race.standings.after_result_save}
  after_destroy {|result| result.race.standings.after_result_destroy}
  
  has_many :scores, :foreign_key => 'competition_result_id', :dependent => :destroy, :extend => CreateIfBestResultForRaceExtension
  has_many :dependent_scores, :class_name => 'Score', :foreign_key => 'source_result_id', :dependent => :destroy
  belongs_to :category
  belongs_to :race
  belongs_to :racer
  belongs_to :team
  
  validates_presence_of :race_id
    
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
      if attributes[:category] and attributes[:category].is_a?(String)
        attributes[:category] = Category.new(:name => attributes[:category])
      end
    end
    super(attributes)
  end
  
  # Replace any new +category+, +racer+, or +team+ with one that already exists if name matches
  def find_associated_records
    if category and (category.new_record? or category.dirty?)
      if category.name.blank?
        self.category = nil
      else
        existing_category = Category.find_by_name_and_scheme(category.name, category.scheme)
        self.category = existing_category if existing_category
      end
    end
    
    _racer = self.racer
    if _racer and (_racer.new_record? or _racer.dirty?)
      if _racer.name.blank?
        self.racer = nil
      else
        existing_racers = find_racers
        self.racer = existing_racers.to_a.first if existing_racers.size == 1
      end
    end
    
    if !self.racer.nil? && self.racer.new_record? && self.racer[:member_from].blank?
      self.racer.member_from = Date.today
    end
    
    if self.team and (team.new_record? or team.dirty?)
      if team.name.blank?
        self.team = nil
      else
        existing_team = Team.find_by_name_or_alias(team.name)
        self.team = existing_team if existing_team
      end
    end
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
    if matches.size > 1 or (matches.empty? and first_name.blank? and last_name.blank?)
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
    
    matches
  end
  
  # Set +racer#team+ to +team+ if +racer+ doesn't already have a team
  def update_racer_team 
    if self.racer and self.team and self.racer.team.nil?
      self.racer.team = self.team
    end
  end
  
  # Set +racer#number+ to +number+ if this isn't a rental number
  def update_racer_number
    discipline = Discipline[event.discipline]
    if self.racer and !number.blank? and !RaceNumber.rental?(number, discipline)
      event.number_issuer unless event.number_issuer
      self.racer.add_number(number, discipline, event.number_issuer, event.date.year)
    end
  end
  
  def save_racer
    if self.racer and self.racer.dirty?
      self.racer.save!
    end
  end
  
  # Set points from +scores+
  def calculate_points
    if !scores.empty? and (race.standings.event.is_a?(Competition))
      pts = 0
      for score in scores
        pts = pts + score.points
      end
      self.points = pts
    end
  end
  
  def category_name
    if self.category
      self.category.name
    else
      ''
    end
  end
  
  def category_name=(name)
    if name.blank?
      self.category = nil
    else
      self.category = Category.new(:name => name)
    end
  end

  def event
    if (race || race(true)) && (race.standings || race.standings(true)) && (race.standings.event || race.standings.event(true))
      race.standings.event
    end
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
      self.racer.dirty
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
      self.racer.dirty
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
    if self.racer
      self.racer.name = value
      self.racer.dirty
    else
      self.racer = Racer.new
      self.racer.name = value
    end
  end
  
  def racer_name=(value)
    name = value
  end
  
  def team_name
    return '' if team.nil?
    team.name || ''
  end

  def team_name=(value)
    if self.team
      self.team.name = value
      self.team.dirty
    else
      self.team = Team.new(:name => value)
    end
    if self.racer
      self.racer.team = self.team
      self.racer.dirty
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
    self.number = self.number.to_s
    self.number = self.number.to_i.to_s if self.number[/^\d+\.0$/]
  end

  # Mostly removes unfortunate punctuation typos
  def cleanup_name(name)
    return name if name.nil?
    return '' if name == '0.0'
    return '' if name == '0'
    return '' if name == '.'
    return '' if name.include?('N/A')
    name = name.gsub(';', '\'')
    name = name.gsub(/ *\/ */, '/')
  end
  
  # Highest points first. Break ties by highest placing
  def compare_by_points(other, break_ties = true)
    diff = other.points <=> points
    return diff if diff != 0 || !break_ties
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
  
  def max(x, y)
    if x >= y
      x
    else
      y
    end
  end
  
  # All numbered places first, followed by DNF, DQ, and DNS
  def <=>(other)
    begin
      if place.blank?
        place_as_int = 0
      else
        place_as_int = place.to_i
      end
      if other.place.blank?
        other_place_as_int = 0
      else
        other_place_as_int = other.place.to_i
      end
    
      if place_as_int > 0
        if other_place_as_int == 0
          return -1
        elsif place_as_int != other_place_as_int
          return place_as_int <=> other_place_as_int
        end
      elsif place == 'DNF'
        if other_place_as_int > 0
          return 1
        elsif other.place == 'DNF'
          if id.nil?
            return 0
          else
            return id <=> other.id
          end
        elsif other.place == 'DQ'
          return -1
        else
          return -1
        end
      elsif place == 'DQ'
        if other_place_as_int > 0
          return 1
        elsif other.place == 'DNF'
          return 1
        elsif other.place == 'DQ'
          if id.nil?
            return 0
          else
            return id <=> other.id
          end
        else
          return -1
        end
      elsif place == 'DNS'
        if other_place_as_int > 0
          return 1
        elsif other.place == 'DNF'
          return 1
        elsif other.place == 'DQ'
          return 1
        elsif other.place == 'DNS'
          if id.nil?
            return 0
          else
            return id <=> other.id
          end
        else
          return -1
        end
      elsif place.blank?
        if other_place_as_int > 0
          return 1
        elsif other.place == 'DNF'
          return 1
        elsif other.place == 'DNS'
          return 1
        else
          if id.nil?
            return 0
          else
            return id <=> other.id
          end
        end
      end
      if id.nil?
        return 0
      else
        return id <=> other.id
      end
    rescue ArgumentError => error
      RAILS_DEFAULT_LOGGER.error("Error in Result.<=> #{error} comparing #{self} with #{other}")
      throw error
    end
  end

  # Add +race+ and +race#standings+ name, and points to default to_s
  def to_long_s
    "#<Result #{id}\t#{place}\t#{race.standings.name}\t#{race.name} (#{race.id})\t#{name}\t#{team_name}\t#{points}\t#{time_s if self[:time]}>"
  end
  
  def to_s
    "#<Result #{id} place #{place} race #{race_id} racer #{racer_id} team #{team_id} pts #{points}>"
  end
end