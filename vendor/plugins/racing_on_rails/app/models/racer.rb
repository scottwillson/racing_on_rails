class Racer < ActiveRecord::Base

  include Comparable
  include Dirty

  NUMBERS = [:road_number, :ccx_number, :xc_number, :downhill_number]
  
  before_validation :find_associated_records
  validate :unique

  belongs_to :team
  has_many :aliases
  # has_many :results

  def Racer.find_by_name(name)
    if name.blank?
      Racer.find(
        :first,
        :conditions => ['first_name = ? and last_name = ?', '', ''],
        :order => 'last_name, first_name')
    else
      Racer.find(
        :first,
        :conditions => ["trim(concat(first_name, ' ', last_name)) = ?", name],
        :order => 'last_name, first_name')
    end
  end

  def Racer.full_name(first_name, last_name)
    unless first_name.blank? or last_name.blank?
      return "#{first_name} #{last_name}"
    end
    unless first_name.blank?
      return first_name
    end
    unless last_name.blank?
      return last_name
    end
    
    ''
  end
  
  # criteria example: {:first_name => 'Ryan', road_number => '70'}
  # Assume only one number key
  # Return array of Racers
  def Racer.match(criteria)
    logger.debug("Racer.match: #{criteria.inspect}")
    if criteria.include?(:name) and (criteria.include?(:first_name) or criteria.include?(:last_name))
      raise(ArgumentError, 'Cannot match on both :name and :first_name or :last_name')
    end
    unless criteria.is_a?(Hash)
      raise(ArgumentError, 'Criteria must be Hash')
    end

    _criteria = remove_rental_numbers(criteria)
    unless has_number?(_criteria) or has_names?(_criteria)
      logger.debug("Racer.match found: []")
      return []
    end
    
    if has_number?(_criteria) and !has_names?(_criteria)
      results = match_by_number(_criteria)
      logger.debug("Racer.match found: #{results}")
      return results
    end
    
    if has_names?(_criteria)
      name_matches = match_by_name(_criteria)
      case name_matches.size
      when 0
        # None found? Check number and add warning that name doesn't match
      when 1
        logger.debug("Racer.match found: #{name_matches}")
        return name_matches
      else
        # Break ties by number
        number_matches = match_by_number(_criteria, name_matches)
        if number_matches.size == 1
          logger.debug("Racer.match found: #{number_matches}")
          return number_matches
        end
        # Break ties by team
        team_matches = match_by_team(_criteria, name_matches)
        if team_matches.size == 1
          logger.debug("Racer.match found: #{team_matches}")
          return team_matches
        else
          logger.debug("Racer.match found: #{name_matches}")
          return name_matches
        end
      end
    end
    
    logger.debug("Racer.match found: []")
    []
  end
  
  def Racer.remove_rental_numbers(criteria)
    criteria.delete_if do |key, value|
      NUMBERS.include?(key) and value.to_i > 10  and value.to_i < 100
    end
    criteria
  end
  
  def Racer.has_number?(criteria)
    criteria.detect do |key, value|
      [:road_number, :ccx_number, :xc_number, :downhill_number].include?(key)
    end
  end
  
  def Racer.has_names?(criteria)
    criteria.include?(:name) or criteria.include?(:first_name) or criteria.include?(:last_name)
  end
  
  def Racer.match_by_number(criteria, previous_matches = nil)
    number_condition = criteria.detect do |key, value|
      NUMBERS.include?(key)
    end
    return [] if number_condition.nil?
    
    if previous_matches.nil?
      Racer.find(:all, :conditions => ["#{number_condition.first} = ?", number_condition.last])
    else
      previous_matches.select do |racer|
        racer[number_condition.first] == number_condition.last
      end
    end
  end
  
  def Racer.match_by_team(criteria, previous_matches = nil)
    return [] unless criteria[:team_name]
    
    team = Team.find_by_name_or_alias(criteria[:team_name])
    matches = [] | previous_matches
    matches.reject! do |racer|
      racer.team != team
    end
    
    matches
  end
  
  # TODO Order consistently
  def Racer.match_by_name(criteria)
    RAILS_DEFAULT_LOGGER.debug("Racer.match_by_name(#{criteria.inspect})")
    matches = []
    
    if criteria.include?(:name)
      if criteria[:name].blank?
        matches = Racer.find(
          :all,
          :conditions => ['first_name = ? and last_name = ?', '', ''],
          :order => 'last_name, first_name')  | Alias.find_all_racers_by_name(criteria[:name])
      else
        matches = Racer.find(
          :all,
          :conditions => ["trim(concat(first_name, ' ', last_name)) = ?", criteria[:name]],
          :order => 'last_name, first_name')  | Alias.find_all_racers_by_name(criteria[:name])
      end
        
    elsif criteria.include?(:first_name) and criteria.include?(:last_name)
      matches = Racer.find(
        :all,
        :conditions => ['first_name = ? and last_name = ?', criteria[:first_name], criteria[:last_name]]
      ) | Alias.find_all_racers_by_name(Racer.full_name(criteria[:first_name], criteria[:last_name]))
      
    elsif criteria.include?(:first_name)
      matches = Racer.find_all_by_first_name(criteria[:first_name]) | Alias.find_all_racers_by_name(criteria[:first_name])
      
    elsif criteria.include?(:last_name)
      matches = Racer.find_all_by_last_name(criteria[:last_name]) | Alias.find_all_racers_by_name(criteria[:last_name])
      
    end
    
    matches
  end
  
  def attributes=(attributes)
    if self.obra_member.nil?
      self.obra_member = true
    end
    
    unless attributes.nil?
      if attributes[:team] and attributes[:team].is_a?(Hash)
        attributes[:team] = Team.new(attributes[:team])
      end 
    end
    super(attributes)
  end

  def name
    Racer.full_name(first_name, last_name)
  end
  
  # TODO Handle name, Jr.
  def name=(value)
    if value.blank?
      self.first_name = ''
      self.last_name = ''
      return
    end

    if value.include?(',')
      parts = value.split(',')
      if parts.size > 0
        self.last_name = parts[0].strip
        if parts.size > 1
          self.first_name = parts[1..(parts.size - 1)].join
          self.first_name.strip!
        end
      end
    else
      parts = value.split(' ')
      if parts.size > 0
        self.first_name = parts[0].strip
        if parts.size > 1
          self.last_name = parts[1..(parts.size - 1)].join
          self.last_name.strip!
        end
      end
    end
  end

  def team_name
    if team
      team.name || ''
    else
      ''
    end
  end

  def team_name=(value)
    if value.blank?
      self.team = nil
    else
      self.team = Team.find_or_create_by_name(value)
    end
  end
  
  def master?
    if date_of_birth
      date_of_birth <= Date.new(30.years.ago.year, 12, 31)
    end
  end
  
  def junior?
    if date_of_birth
      date_of_birth >= Date.new(18.years.ago.year, 1, 1)
    end
  end
  
  def racing_age
    if date_of_birth
      (Date.today.year - date_of_birth.year).ceil
    end
  end
  
  def ccx_number=(value)
    if value.blank?
      self[:ccx_number] = nil
    else
      self[:ccx_number] = value
    end
  end
  
  def dh_number=(value)
    if value.blank?
      self[:dh_number] = nil
    else
      self[:dh_number] = value
    end
  end
  
  def road_number=(value)
    if value.blank?
      self[:road_number] = nil
    else
      self[:road_number] = value
    end
  end
  
  def track_number=(value)
    if value.blank?
      self[:track_number] = nil
    else
      self[:track_number] = value
    end
  end
  
  def xc_number=(value)
    if value.blank?
      self[:xc_number] = nil
    else
      self[:xc_number] = value
    end
  end
  
  # All non-Competition results
  # def event_results
  #   results.reject do |result|
  #     result.race.standings.event.is_a?(Competition)
  #   end
  # end
  # 
  # # BAR, Oregon Cup, Ironman
  # def competition_results
  #   results.select do |result|
  #     result.race.standings.event.is_a?(Competition)
  #   end
  # end
  
  def merge(racer)
    # TODO Consider just using straight SQL for this --
    # it's not complicated, and the current process generates an
    # enormous amount of SQL
    if racer == self
      raise(IllegalArgumentError, 'Cannot merge racer onto itself')
    end
    Racer.transaction do
      # events = racer.results.collect do |result|
      #   event = result.race.standings.event
      #   event.disable_notification!
      #   event
      # end
      begin
        save!
        aliases << racer.aliases
        # results << racer.results
        Racer.delete(racer.id)
        existing_alias = aliases.detect{|a| a.name.casecmp(racer.name) == 0}
        if existing_alias.nil? and Racer.match(:name => racer.name).empty?
          aliases.create(:name => racer.name) 
        end
      ensure
        # events.each do |event|
        #   event.reload
        #   event.enable_notification!
        # end
      end
    end
  end
  
  def find_associated_records
    if self.team and (team.new_record? or team.dirty?)
      if team.name.blank?
        self.team = nil
      else
        existing_team = Team.find_by_name_or_alias(team.name)
        self.team = existing_team if existing_team
      end
    end
  end
  
  # first + last name and no same, non-blank numbers
  def unique
    racers_with_same_name = Racer.match_by_name(:first_name => first_name, :last_name => last_name)
    racers_with_same_name.delete(self)
    if racers_with_same_name.size == 0
      return
    end
    
    non_blank_number = false
    for number in NUMBERS
      if !self[number].blank?
        non_blank_number = true
      end
    end
    unless non_blank_number
      errors.add(number, "Ambiguous racer: multiple racers named '#{name}', but racer's numbers are all blank")
      return
    end
    
    for number in NUMBERS
      racer_numbers = Set.new
      for racer in racers_with_same_name
        if !self[number].blank? and self[number] == racer[number]
          errors.add(number, "Racer ID #{racer.id} has same name '#{name}' has same #{number}: '#{self[number]}")
          return
        end
        if self[number].blank? and !racer[number].blank?
          errors.add(number, "Ambiguous Racer: racer ID #{racer.id} has same name '#{name}' and #{number} of '#{self[number]},' but current racer's #{number} is blank")
          return
        end
        if !self[number].blank? and racer[number].blank?
          errors.add(number, "Ambiguous Racer: racer ID #{racer.id} has same name '#{name},' but blank #{number}. Current racer's '#{number} is not blank")
          return
        end
      end
    end
  end
  
  def <=>(other)
    self.id <=> other.id
  end
  
  def to_s
    "<Racer #{id} #{first_name} #{last_name} #{team_id}>"
  end

end