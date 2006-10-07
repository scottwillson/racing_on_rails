class Result < ActiveRecord::Base
  
  include Dirty
  
  # FIME Make sure names are coerced correctly
  # TODO Add number (race_number) and license
  
  before_validation :find_associated_records
  before_save :update_racer_team, :update_racer_number, :save_racer
  after_save {|result| result.race.standings.after_result_save}
  after_destroy {|result| result.race.standings.after_result_destroy}
  
  has_many :scores, :foreign_key => 'competition_result_id', :dependent => :destroy
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
        existing_racers = Racer.match(
          :first_name => _racer.first_name, 
          :last_name => _racer.last_name, 
          Discipline.number_type(self.race.standings.event.discipline) => number
        )
        self.racer = existing_racers.first if existing_racers.size == 1
      end
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
  
  def update_racer_team 
    if self.racer and self.team and self.racer.team.nil?
      self.racer.team = self.team
    end
  end
  
  def update_racer_number
    if self.racer and !self.number.blank?
      number_type = Discipline.number_type(self.race.standings.event.discipline)
      existing_number = self.racer[number_type]
      if existing_number.blank? or (existing_number.to_i > 10 and existing_number.to_i < 100)
        self.racer[number_type] = self.number
        self.racer.dirty
        existing_racer = Racer.find(:first, :conditions => ["#{number_type} = ?", self.number])
        if existing_racer and existing_racer != self.racer
          self.racer[number_type] = nil
        end
      end
    end
  end
  
  def save_racer
    if self.racer and self.racer.dirty?
      self.racer.save!
    end
  end
  
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
  
  def points_bonus_penalty=(value)
    if value == nil || value == ""
      value = 0
    end
    write_attribute(:points_bonus_penalty, value)
  end
  
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
  
  def team_name
    if team
      return team.name unless team.nil? or team.name.nil?
    end
    ""
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
  
  def time_s
    time_to_s(self.time)
  end
  
  def time_s=(time)
    self.time = s_to_time(time)
  end
  
  def time_total_s
    time_to_s(self.time_total)
  end
  
  def time_total_s=(time_total)
    self.time_total = s_to_time(time_total)
  end
  
  def time_bonus_penalty_s
    time_to_s(self.time_bonus_penalty)
  end
  
  def time_bonus_penalty_s=(time_bonus_penalty)
    self.time_bonus_penalty = s_to_time(time_bonus_penalty)
  end
  
  def time_gap_to_leader_s
    time_to_s(self.time_gap_to_leader)
  end
  
  def time_gap_to_leader_s=(time_gap_to_leader_s)
    self.time_gap_to_leader = s_to_time(time_gap_to_leader_s)
  end
  
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

  def cleanup_name(name)
    return name if name.nil?
    return '' if name == '0.0'
    return '' if name == '0'
    return '' if name == '.'
    return '' if name.include?('N/A')
    name = name.gsub(';', '\'')
    name = name.gsub(/ *\/ */, '/')
  end
  
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

  def to_long_s
    "<Result #{id}\t#{place}\t#{race.standings.name}\t#{race.name} (#{race.id})\t#{name}\t#{team_name}\t#{points}\t#{time_s if self[:time]}>"
  end
  
  def to_s
    "<Result #{id} place #{place} race #{race_id} racer #{racer_id} team #{team_id} pts #{points}>"
  end
end