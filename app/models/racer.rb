class Racer < ActiveRecord::Base

  include Comparable
  include Dirty

  before_validation :find_associated_records

  belongs_to :team
  has_many :aliases
  has_many :race_numbers
  has_many :results

  def Racer.find_all_by_name(name)
    if name.blank?
      Racer.find(
        :all,
        :conditions => ['first_name = ? and last_name = ?', '', ''],
        :order => 'last_name, first_name')
    else
      Racer.find(
        :all,
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
  
  def attributes=(attributes)
    if self.member.nil?
      self.member = true
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
  
  def number(discipline, reload = false)
    association = NumberIssuer.find_by_name(ASSOCIATION.short_name)
    number = race_numbers(reload).detect do |race_number|
      race_number.year == Date.today.year and race_number.discipline == discipline and race_number.number_issuer == association
    end
    if number
      number.value
    else
      nil
    end
  end
  
  def add_number(value, discipline)
    logger.debug("add_number(#{value}, #{discipline})")
    association = NumberIssuer.find_by_name(ASSOCIATION.short_name)
    if value.blank?
      logger.debug('blank # -- delete')
      # Delete ALL numbers for ASSOCIATION and this discipline?
      # FIXME Delete number individually in UI
      RaceNumber.destroy_all(
        ['racer_id=? and discipline_id=? and year=? and number_issuer_id=?', 
        self.id, discipline.id, Date.today.year, association.id])
    else
      if new_record?
        logger.debug('new racer -- build number')
        race_numbers.build(:racer => self, :value => value, :discipline => discipline, :year => Date.today.year, :number_issuer => association)
      else
        logger.debug('existing racer')
        race_number = RaceNumber.find(
          :first,
          :conditions => ['value=? and racer_id=? and discipline_id=? and year=? and number_issuer_id=?', 
                           value, self.id, discipline.id, Date.today.year, association.id])
        logger.debug("race_number: #{race_number}")
        unless race_number
          race_numbers.create!(:racer => self, :value => value, :discipline => discipline, :year => Date.today.year, :number_issuer => association)
        end
      end
    end
  end
  
  def ccx_number(reload = false)
    number(Discipline[:cyclocross], reload)
  end
  
  def dh_number(reload = false)
    number(Discipline[:downhill], reload)
  end
  
  def road_number(reload = false)
    number(Discipline[:road], reload)
  end
  
  def track_number(reload = false)
    number(Discipline[:track], reload)
  end
  
  def xc_number(reload = false)
    number(Discipline[:mountain_bike], reload)
  end
  
  def ccx_number=(value)
    add_number(value, Discipline[:cyclocross])
  end
  
  def dh_number=(value)
    add_number(value, Discipline[:downhill])
  end
  
  def road_number=(value)
    add_number(value, Discipline[:road])
  end
  
  def track_number=(value)
    add_number(value, Discipline[:track])
  end
  
  def xc_number=(value)
    add_number(value, Discipline[:mountain_bike])
  end
  
  # All non-Competition results
  def event_results
    results.reject do |result|
      result.race.standings.event.is_a?(Competition)
    end
  end
  
  # BAR, Oregon Cup, Ironman
  def competition_results
    results.select do |result|
      result.race.standings.event.is_a?(Competition)
    end
  end
  
  def merge(racer)
    # TODO Consider just using straight SQL for this --
    # it's not complicated, and the current process generates an
    # enormous amount of SQL
    if racer == self
      raise(IllegalArgumentError, 'Cannot merge racer onto itself')
    end
    Racer.transaction do
      events = racer.results.collect do |result|
        event = result.race.standings.event
        event.disable_notification!
        event
      end
      begin
        save!
        aliases << racer.aliases
        results << racer.results
        race_numbers << racer.race_numbers
        Racer.delete(racer.id)
        existing_alias = aliases.detect{|a| a.name.casecmp(racer.name) == 0}
        if existing_alias.nil? and Racer.find_all_by_name(racer.name).empty?
          aliases.create(:name => racer.name) 
        end
      ensure
        events.each do |event|
          event.reload
          event.enable_notification!
        end
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
  
  def <=>(other)
    self.id <=> other.id
  end
  
  def to_s
    "<Racer #{id} #{first_name} #{last_name} #{team_id}>"
  end

end