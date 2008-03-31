# A rider who either appears in race results or who is added as a member of a racing association
#
# Names are _not_ unique
#
# New memberships start on today, but really should start on January 1st of next year, if +year+ is next year
class Racer < ActiveRecord::Base

  include Comparable
  include Dirty

  before_validation :find_associated_records
  validate :membership_dates
  before_save :destroy_shadowed_aliases
  after_save :add_alias_for_old_name
  after_save :save_numbers

  belongs_to :team
  has_many :aliases
  has_many :race_numbers, :include => [:discipline, :number_issuer]
  has_many :results
  
  attr_accessor :year
  
  CATEGORY_FIELDS = [:ccx_category, :dh_category, :mtb_category, :road_category, :track_category]

  # Does not consider Aliases
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
  
  def Racer.find_all_by_name_or_alias(first_name, last_name)
    if !first_name.blank? and !last_name.blank?
      Racer.find(
        :all,
        :conditions => ['first_name = ? and last_name = ?', first_name, last_name]
      ) | Alias.find_all_racers_by_name(Racer.full_name(first_name, last_name))
      
    elsif last_name.blank?
      Racer.find_all_by_first_name(first_name) | Alias.find_all_racers_by_name(first_name)
      
    elsif first_name.blank?
      Racer.find_all_by_last_name(last_name) | Alias.find_all_racers_by_name(last_name)
      
    else
      Racer.find(
        :all,
        :conditions => ['first_name = ? and last_name = ?', '', ''],
        :order => 'last_name, first_name')
      
    end
  end
  
  def Racer.find_all_by_name_like(name, limit = 100)
    name_like = "%#{name}%"
    Racer.find(
      :all, 
      :conditions => ["concat(first_name, ' ', last_name) like ? or aliases.name like ?", name_like, name_like],
      :include => :aliases,
      :limit => limit,
      :order => 'last_name, first_name'
    )
  end
  
  def Racer.find_by_name(name)
    Racer.find(
      :first, 
      :conditions => ["concat(first_name, ' ', last_name) = ?", name]
    )
  end
  
  def Racer.find_by_number(number)
    Racer.find(:all, 
               :include => :race_numbers,
               :conditions => ['year = ? and value = ?', Date.today.year, number])
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
    unless attributes.nil?
      if attributes["member_to(1i)"] && !attributes["member_to(2i)"]
        attributes["member_to(2i)"] = '12'
        attributes["member_to(3i)"] = '31'
      end
      if attributes[:team] and attributes[:team].is_a?(Hash)
        attributes[:team] = Team.new(attributes[:team])
      end 
    end
    super(attributes)
  end

  def name
    Racer.full_name(first_name, last_name)
  end

    # Tries to split +name+ into +first_name+ and +last_name+
  # TODO Handle name, Jr.
  def name=(value)  
    logger.debug("name=#{name}")
    @old_name = name unless @old_name
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
  
  def first_name=(value)
    @old_name = name unless @old_name
    self[:first_name] = value
  end
  
  def last_name=(value)
    @old_name = name unless @old_name
    self[:last_name] = value
  end

  def team_name
    if team
      team.name || ''
    else
      ''
    end
  end

  def team_name=(value)
    if value.blank? or value == 'N/A'
      self.team = nil
    else
      self.team = Team.find_or_create_by_name(value)
    end
  end

  def gender_pronoun
    if gender == "F"
      "herself"
    else
      "himself"
    end
  end
  
  def gender=(value)
    value.upcase!
    case value
    when 'M', 'MALE', 'BOY'
      self[:gender] = 'M'
    when 'F', 'FEMALE', 'GIRL'
      self[:gender] = 'F'
    else
      self[:gender] = 'M'
    end
  end
  
  def date_of_birth=(value)
    if value.is_a?(String)
      value.gsub!(/^00/, '19')
      value.gsub!(/^(\d+\/\d+\/)(\d\d)$/, '\119\2')
    end
    if value and value.to_s.size < 5
      int_value = value.to_i
      if int_value > 10 and int_value <= 99
        value = "01/01/19#{value}"
      end
      if int_value > 0 and int_value <= 10
        value = "01/01/20#{value}"
      end
    end
    
    # Don't overwrite month and day if we're just passing in the same year
    if self[:date_of_birth] and value
      if value.is_a?(String)
        new_date = Date.parse(value)
      else
        new_date = value
      end
      if new_date.year == self[:date_of_birth].year and new_date.month == 1 and new_date.day == 1
        return
      end
    end
    super
  end
  
  def birthdate
    date_of_birth
  end
  
  def birthdate=(value)
    self.date_of_birth = value
  end
  
  # 30 years old or older
  def master?
    if date_of_birth
      date_of_birth <= Date.new(30.years.ago.year, 12, 31)
    end
  end
  
  # Under 18 years old
  def junior?
    if date_of_birth
      date_of_birth >= Date.new(18.years.ago.year, 1, 1)
    end
  end
  
  # Oldest age racer will be at any point in year
  def racing_age
    if date_of_birth
      (Date.today.year - date_of_birth.year).ceil
    end
  end
  
  def number(discipline, reload = false)
    raise 'discipline cannot be nil' if discipline.nil?

    if discipline.is_a?(Symbol)
      discipline = Discipline[discipline]
    end
    number = race_numbers(reload).detect do |race_number|
      race_number.year == Date.today.year and race_number.discipline_id == discipline.id and race_number.number_issuer.name == ASSOCIATION.short_name
    end
    if number
      number.value
    else
      nil
    end
  end
  
  # Look for RaceNumber +year+ in +attributes+. Not sure if there's a simple and better way to do that.
  def add_number(value, discipline, association = nil, _year = year)
    association = NumberIssuer.find_by_name(ASSOCIATION.short_name) if association.nil?
    _year ||= Date.today.year
    discipline ||= Discipline[:road] 
    
    if value.blank?
      unless new_record?
        # Delete ALL numbers for ASSOCIATION and this discipline?
        # FIXME Delete number individually in UI
        RaceNumber.destroy_all(
          ['racer_id=? and discipline_id=? and year=? and number_issuer_id=?', 
          self.id, discipline.id, _year, association.id])
      end
    else
      self.dirty
      if new_record?
        existing_number = race_numbers.any? do |number|
          number.value == value && number.discipline == discipline && number.association == association && number.year == _year
        end
        race_numbers.build(:racer => self, :value => value, :discipline => discipline, :year => _year, :number_issuer => association) unless existing_number
      else
        race_number = RaceNumber.find(
          :first,
          :conditions => ['value=? and racer_id=? and discipline_id=? and year=? and number_issuer_id=?', 
                           value, self.id, discipline.id, _year, association.id])
        unless race_number
          race_numbers.create(:racer => self, :value => value, :discipline => discipline, :year => _year, :number_issuer => association)
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
  
  def singlespeed_number(reload = false)
    number(Discipline[:singlespeed], reload)
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
  
  def singlespeed_number=(value)
    add_number(value, Discipline[:singlespeed])
  end

  def track_number=(value)
    add_number(value, Discipline[:track])
  end
  
  def xc_number=(value)
    add_number(value, Discipline[:mountain_bike])
  end
  
  # Is Racer a current member of the bike racing association?
  def member?(date = Date.today)
    date = Date.new(date.year, date.month, date.day) if date.is_a? Time
    !self.member_to.nil? && !self.member_from.nil? && (self.member_from <= date && self.member_to >= date)
  end

  # Is/was Racer a current member of the bike racing association at any point during +date+'s year?
  def member_in_year?(date = Date.today)
    date = Date.new(date.year, date.month, date.day) if date.is_a? Time
    year = date.year
    !self.member_to.nil? && !self.member_from.nil? && (self.member_from.year <= year && self.member_to.year >= year)
  end
  
  def member
    member?
  end
  
  # Is Racer a current member of the bike racing association?
  def member=(value)
    if value and !member?
      self.member_from = Date.today if self.member_from.nil? or self.member_from >= Date.today
      self.member_to = Date.new(Date.today.year, 12, 31) unless self.member_to and (self.member_to >= Date.new(Date.today.year, 12, 31))
    elsif !value and member?
      if self.member_from.year == Date.today.year
        self.member_from = nil
        self.member_to = nil
      else
        self.member_to = Date.new(Date.today.year - 1, 12, 31)
      end
    end
  end
  
  def member_from=(date)
    if date.nil?
      self[:member_from] = nil
      self[:member_to] = nil
      return date
    end

    date_as_date = date
    case date_as_date
    when Date
      # Nothing to do
    when DateTime, Time
      date_as_date = Date.new(date.year, date.month, date.day)
    else
      date_as_date = Date.parse(date)
    end

    if self.member_to.nil?
      self[:member_to] = Date.new(date_as_date.year, 12, 31)
    end
    self[:member_from] = date_as_date
  end
  
  def member_to=(date)
    unless date.nil?
      self[:member_from] = Date.today if self.member_from.nil?
      self[:member_from] = date if self.member_from > date
    end
    self[:member_to] = date
  end
  
  # Validates member_from and member_to
  def membership_dates
    if member_to and member_from.nil?
      errors.add('member_from', "cannot be nil if member_to is not nil (#{member_to})")
    end
    if member_from and member_to.nil?
      errors.add('member_to', "cannot be nil if member_from is not nil (#{member_from})")
    end
    if member_from and member_to and member_from > member_to
      errors.add('member_to', "cannot be greater than member_from: #{member_from}")
    end
  end
  
  def renewed?
    self.member_from && (self.member_from > Date.today)
  end
  
  def print_card?
    self.print_card
  end
  
  def state=(value)
    if value and value.size == 2
      value.upcase!
    end
    super
  end
  
  def city_state_zip
    if !city.blank?
      if !state.blank?
        "#{city}, #{state} #{zip}"
      else
        "#{city} #{zip}"
      end
    else
      if !state.blank?
        "#{state} #{zip}"
      else
        zip || ''
      end
    end
  end
  
  def hometown
    if city.blank?
      if state.blank?
        ''
      else
        if state == ASSOCIATION.state
          ''
        else
          state
        end
      end
    else
      if state.blank?
        city
      else
        if state == ASSOCIATION.state
          city
        else
          "#{city}, #{state}"
        end
      end
    end
  end
  
  def hometown=(value)
    self.city = nil
    self.state = nil
    return value if value.blank?
    parts = value.split(',')
    if parts.size > 1
      self.state = parts.last.strip
    end
    self.city = parts.first.strip
  end
  
  # Hack around in-place editing
  def toggle!(attribute)
    logger.debug("toggle! #{attribute} #{attribute == 'member'}")
    if attribute == 'member'
      self.member = !member?
      save!
    else
      super
    end
  end
  
  # All non-Competition results
  # reload does an optimized load with joins
  def event_results(reload = true)
    if reload
      return Result.find(
        :all,
        :include => [:team, :racer, :scores, :category, {:race => [{:standings => :event}, :category]}],
        :conditions => ['racers.id = ?', id]
      ).reject {|r| r.competition_result?}
    end
    results.reject do |result|
      result.competition_result?
    end
  end
  
  # BAR, Oregon Cup, Ironman
  def competition_results
    results.select do |result|
      result.competition_result?
    end
  end

  # Moves another racers' aliases, results, and race numbers to this racer,
  # and delete the other racer.
  # Also adds the other racers' name as a new alias
  def merge(other_racer)
    # TODO Consider just using straight SQL for this --
    # it's not complicated, and the current process generates an
    # enormous amount of SQL
    if other_racer == self
      raise "Cannot merge racer onto #{gender_pronoun}"
    end

    Racer.transaction do
      events = other_racer.results.collect do |result|
        event = result.race.standings.event
        event.disable_notification!
        event
      end
      begin
        save!
        aliases << other_racer.aliases
        results << other_racer.results
        race_numbers << other_racer.race_numbers
        Racer.delete(other_racer.id)
        existing_alias = aliases.detect{|a| a.name.casecmp(other_racer.name) == 0}
        if existing_alias.nil? and Racer.find_all_by_name(other_racer.name).empty?
          aliases.create(:name => other_racer.name) 
        end
      ensure
        if events
          events.each do |event|
            event.reload
            event.enable_notification!
          end
        end
      end
    end
    true
  end
  
  # Replace +team+ with exising Team if current +team+ is an unsaved duplicate of an existing Team
  def find_associated_records
    if self.team and (team.new_record? or team.dirty?)
      if team.name.blank? or team.name == 'N/A'
        self.team = nil
      else
        existing_team = Team.find_by_name_or_alias(team.name)
        self.team = existing_team if existing_team
      end
    end
  end
  
  def save_numbers
    for number in race_numbers
      number.save! if number.new_record?
    end
  end
  
  # If name changes to match existing alias, destroy the alias
  def destroy_shadowed_aliases
    Alias.destroy_all(['name = ?', name])
  end
  
  def add_alias_for_old_name
    if !new_record? &&
       !@old_name.blank? && 
       !name.blank? && 
       @old_name.casecmp(name) != 0 && 
       !Alias.exists?(['name = ? and racer_id = ?', @old_name, id]) && 
       !Racer.exists?(["trim(concat(first_name, ' ', last_name)) = ?", @old_name])

      Alias.create!(:name => @old_name, :racer => self)
    end
  end

  def <=>(other)
    if other
      id <=> other.id
    else
      -1
    end
  end
  
  def to_s
    "#<Racer #{id} #{first_name} #{last_name} #{team_id}>"
  end
end