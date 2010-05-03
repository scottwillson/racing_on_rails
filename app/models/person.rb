# A rider who either appears in race results or who is added as a member of a racing association
#
# Names are _not_ unique
#
# New memberships start on today, but really should start on January 1st of next year, if +year+ is next year
class Person < ActiveRecord::Base
  include Comparable

  acts_as_authentic do |config|
    config.validates_length_of_login_field_options :within => 3..100, :allow_nil => true, :allow_blank => true
    config.validates_format_of_login_field_options :with => Authlogic::Regex.login, 
                                                   :message => I18n.t('error_messages.login_invalid', :default => "should use only letters, numbers, spaces, and .-_@ please."),
                                                   :allow_nil => true,
                                                   :allow_blank => true

    config.validates_length_of_password_field_options  :minimum => 4, :allow_nil => true, :allow_blank => true
    config.validates_length_of_password_confirmation_field_options  :minimum => 4, :allow_nil => true, :allow_blank => true
    config.validate_email_field false
    config.disable_perishable_token_maintenance true
  end

  before_validation :find_associated_records, :make_login_blanks_nil
  validate :membership_dates
  before_save :destroy_shadowed_aliases
  after_save :add_alias_for_old_name

  has_many :aliases
  belongs_to :created_by, :polymorphic => true
  has_and_belongs_to_many :editable_people, :class_name => "Person", :foreign_key => "editor_id", :before_add => :validate_unique_editors
  has_and_belongs_to_many :editors, :class_name => "Person", :association_foreign_key => "editor_id", :before_add => :validate_unique_editors
  has_many :editor_requests, :dependent => :destroy
  has_many :events, :foreign_key => "promoter_id"
  has_many :race_numbers, :include => [ :discipline, :number_issuer ]
  has_many :results
  has_and_belongs_to_many :roles
  has_many :sent_editor_requests, :foreign_key => "editor_id", :class_name => "EditorRequest", :dependent => :destroy
  belongs_to :team
  
  attr_accessor :year
  
  CATEGORY_FIELDS = [:bmx_category, :ccx_category, :dh_category, :mtb_category, :road_category, :track_category]

  def self.per_page
    50
  end

  # Does not consider Aliases
  def Person.find_all_by_name(name)
    if name.blank?
      Person.find(
        :all,
        :conditions => ['first_name = ? and last_name = ?', '', ''],
        :order => 'last_name, first_name')
    else
      Person.find(
        :all,
        :conditions => ["trim(concat(first_name, ' ', last_name)) = ?", name],
        :order => 'last_name, first_name')
    end
  end
  
  # "Jane Doe" or "Jane", "Doe" or :name => "Jane Doe" or :first_name => "Jane", :last_name => "Doe"
  def Person.find_all_by_name_or_alias(*args)
    options = args.extract_options!
    options.keys.each { |key| raise(ArgumentError, "'#{key}' is not a valid key") unless [:name, :first_name, :last_name].include?(key) }
    
    name = args.join(" ") if options.empty?
    
    name = name || options[:name]
    first_name = options[:first_name]
    last_name = options[:last_name]
    
    if name.present?
      return Person.find(
        :all,
        :conditions => ["trim(concat(first_name, ' ', last_name)) = ?", name]
      ) | Alias.find_all_people_by_name(name)
    elsif first_name.present? && last_name.blank?
      Person.find(
        :all,
        :conditions => ['first_name = ?', first_name]
      ) | Alias.find_all_people_by_name(Person.full_name(first_name, last_name))
    elsif first_name.blank? && last_name.present?
      Person.find(
        :all,
        :conditions => ['last_name = ?', last_name]
      ) | Alias.find_all_people_by_name(Person.full_name(first_name, last_name))
    else
      Person.find(
        :all,
        :conditions => ['first_name = ? and last_name = ?', first_name, last_name]
      ) | Alias.find_all_people_by_name(Person.full_name(first_name, last_name))
    end
  end
  
  def Person.find_all_by_name_like(name, limit = 100)
    return [] if name.blank?
    
    name_like = "%#{name.strip}%"
    Person.find(
      :all, 
      :conditions => ["trim(concat(first_name, ' ', last_name)) like ? or aliases.name like ?", name_like, name_like],
      :include => :aliases,
      :limit => limit,
      :order => 'last_name, first_name'
    )
  end
  
  def Person.find_by_info(name, email = nil, home_phone = nil)
    if !name.blank?
      Person.find_by_name(name)
    else
      Person.find(
        :first, 
        :conditions => ["(email = ? and email <> '' and email is not null) or (home_phone = ? and home_phone <> '' and home_phone is not null)", 
                        email, home_phone]
      )
    end
  end

  def Person.find_by_name(name)
    Person.find(
      :first, 
      :conditions => ["trim(concat(first_name, ' ', last_name)) = ?", name]
    )
  end
  
  def Person.find_by_number(number)
    Person.find(:all, 
               :include => :race_numbers,
               :conditions => [ 'race_numbers.year in (?) and race_numbers.value = ?', [ ASSOCIATION.year, ASSOCIATION.next_year ], number ])
  end

  # if/else to avoid strip
  def Person.full_name(first_name, last_name)
    if first_name.present?
      if last_name.present?
        "#{first_name} #{last_name}"
      else
        first_name
      end
    else
      if last_name.present?
        last_name
      else
        ""
      end
    end
  end
  
  def Person.find_all_current_email_addresses
    Person.connection.select_rows(%Q{ 
      select first_name, last_name, email 
      from people 
      where member_to > NOW() and email is not null and email != '' 
      order by last_name, first_name, email
    }).collect do |first_name, last_name, email|
      if first_name.blank? && last_name.blank?
        email
      else
        "#{first_name} #{last_name} <#{email}>"
      end
    end
  end
  
  # Flattened, straight SQL dump for export to Excel, FinishLynx, or SportsBase.
  def Person.find_all_for_export(date = ASSOCIATION.today, include_people = "members_only")
    association_number_issuer_id = NumberIssuer.find_by_name(ASSOCIATION.short_name).id
    if include_people == "members_only"
      where_clause = "WHERE (member_to >= '#{date.to_s}')" 
    elsif include_people == "print_cards"
      where_clause = "WHERE  (member_to >= '#{date.to_s}') and print_card is true" 
    end
    
    people = Person.connection.select_all(%Q{
      SELECT people.id, license, first_name, last_name, teams.name as team_name, people.notes,
             DATE_FORMAT(member_from, '%m/%d/%Y') as member_from, DATE_FORMAT(member_to, '%m/%d/%Y') as member_to, DATE_FORMAT(member_usac_to, '%m/%d/%Y') as member_usac_to,
             print_card, card_printed_at, membership_card, ccx_only, DATE_FORMAT(date_of_birth, '%m/01/%Y') as date_of_birth, occupation,
             street, people.city, people.state, zip, wants_mail, email, wants_email, home_phone, work_phone, cell_fax, gender, 
             ccx_category, road_category, track_category, mtb_category, dh_category, 
             volunteer_interest, official_interest, race_promotion_interest, team_interest,
             CEILING(#{date.year} - YEAR(date_of_birth)) as racing_age,
             ccx_numbers.value as ccx_number, dh_numbers.value as dh_number, road_numbers.value as road_number, 
             singlespeed_numbers.value as singlespeed_number, xc_numbers.value as xc_number,
             DATE_FORMAT(people.created_at, '%m/%d/%Y') as created_at, DATE_FORMAT(people.updated_at, '%m/%d/%Y') as updated_at
      FROM people
      LEFT OUTER JOIN teams ON teams.id = people.team_id 
      LEFT OUTER JOIN race_numbers as ccx_numbers ON ccx_numbers.person_id = people.id 
                      and ccx_numbers.number_issuer_id = #{association_number_issuer_id} 
                      and ccx_numbers.year = #{date.year} 
                      and ccx_numbers.discipline_id = #{Discipline[:ccx].id}
      LEFT OUTER JOIN race_numbers as dh_numbers ON dh_numbers.person_id = people.id 
                      and dh_numbers.number_issuer_id = #{association_number_issuer_id} 
                      and dh_numbers.year = #{date.year} 
                      and dh_numbers.discipline_id = #{Discipline[:downhill].id}
      LEFT OUTER JOIN race_numbers as road_numbers ON road_numbers.person_id = people.id 
                      and road_numbers.number_issuer_id = #{association_number_issuer_id} 
                      and road_numbers.year = #{date.year} 
                      and road_numbers.discipline_id = #{Discipline[:road].id}
      LEFT OUTER JOIN race_numbers as singlespeed_numbers ON singlespeed_numbers.person_id = people.id 
                      and singlespeed_numbers.number_issuer_id = #{association_number_issuer_id} 
                      and singlespeed_numbers.year = #{date.year} 
                      and singlespeed_numbers.discipline_id = #{Discipline[:singlespeed].id}
      LEFT OUTER JOIN race_numbers as track_numbers ON track_numbers.person_id = people.id 
                      and track_numbers.number_issuer_id = #{association_number_issuer_id} 
                      and track_numbers.year = #{date.year} 
                      and track_numbers.discipline_id = #{Discipline[:track].id}
      LEFT OUTER JOIN race_numbers as xc_numbers ON xc_numbers.person_id = people.id 
                      and xc_numbers.number_issuer_id = #{association_number_issuer_id} 
                      and xc_numbers.year = #{date.year} 
                      and xc_numbers.discipline_id = #{Discipline[:mountain_bike].id}
      #{where_clause}
      ORDER BY last_name, first_name, people.id
    })
    
    last_person = nil
    people.reject! do |person|
      if last_person && last_person["id"] == person["id"]
        true
      else
        last_person = person
        false
      end
    end
    
    people
  end
  
  #interprets dates returned in sql above for member export
  def Person.lic_check(lic, lic_date)
    if lic.to_i > 0
      (lic_date && (Date.parse(lic_date) > ASSOCIATION.today)) ? "current" : "CHECK LIC!"
    else
      "NOT ON FILE"
    end
  end
  
  # Find Person with most recent. If no results, select the most recently updated Person.
  def Person.select_by_recent_activity(people)
    results = people.to_a.inject([]) { |results, person| results + person.results }
    if results.empty?
      people.to_a.sort_by(&:updated_at).last
    else
      results = results.sort_by(&:date)
      results.last.person
    end
  end
  
  def people_with_same_name
    people = Person.find_all_by_name(self.name) | Alias.find_all_people_by_name(self.name)
    people.reject! { |person| person == self }
    people
  end
  
  def attributes=(attributes)
    unless attributes.nil?
      if attributes["member_to(1i)"] && !attributes["member_to(2i)"]
        attributes["member_to(2i)"] = '12'
        attributes["member_to(3i)"] = '31'
      end
      if attributes[:team] and attributes[:team].is_a?(Hash)
        attributes[:team] = Team.new(attributes[:team])
        attributes[:team][:created_by] = attributes[:created_by] if new_record?
      end 
    end
    super(attributes)
  end

  def name
    Person.full_name(first_name, last_name)
  end

  def email_with_name
    "#{name} <#{email}>"
  end

  def name_or_login
    if name.present?
      name
    elsif login.present?
      login
    else
      email
    end
  end
  
  def last_name_or_login
    if last_name.present?
      last_name
    elsif login.present?
      login
    else
      email
    end
  end

  # Name. If +name+ is blank, returns email and phone
  def name_or_contact_info
    if name.blank?
      [email, home_phone].join(', ')
    else
      name
    end
  end
  
  # Cannot have promoters with duplicate contact information
  def unique_info
    person = Person.find_by_info(name, email, home_phone)
    if person && person != self
      errors.add("existing person with name '#{name}'")
    end
  end

  # Tries to split +name+ into +first_name+ and +last_name+
  # TODO Handle name, Jr.
  # This looks too complicated …
  def name=(value)  
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
          self.last_name = parts[1..(parts.size - 1)].join(" ")
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
    if value.blank? || value == 'N/A'
      self.team = nil
    else
      self.team = Team.find_by_name_or_alias(value)
      self.team = Team.new(:name => value, :created_by => new_record? ? created_by : nil) unless self.team
    end
  end

  def gender_pronoun
    if gender == "F"
      "herself"
    else
      "himself"
    end
  end
  
  # Non-nil for happier sorting
  def gender
    self[:gender] || ''
  end
  
  def gender=(value)
    if value.nil?
      self[:gender] = nil
    else
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
      date_of_birth <= Date.new(ASSOCIATION.masters_age.years.ago.year, 12, 31)
    end
  end
  
  # Under 18 years old
  def junior?
    if date_of_birth
      date_of_birth >= Date.new(18.years.ago.year, 1, 1)
    end
  end
  
  # Over 18 years old
  def senior?
    if date_of_birth
      date_of_birth < Date.new(18.years.ago.year, 1, 1)
    end
  end
  
  # Oldest age person will be at any point in year
  def racing_age
    if date_of_birth
      (ASSOCIATION.year - date_of_birth.year).ceil
    end
  end
  
  def cyclocross_racing_age
    if date_of_birth
      racing_age + 1
    end
  end
  
  def category(discipline)
    if discipline.is_a?(String)
      _discipline = Discipline[discipline]
    else
      _discipline = discipline
    end
    
    case _discipline
    when Discipline[:road], Discipline[:track], Discipline[:criterium], Discipline[:time_trial], Discipline[:circuit]
      self["road_category"]
    when Discipline[:road], Discipline[:criterium], Discipline[:time_trial], Discipline[:circuit]
      self["track_category"]
    when Discipline[:cyclocross]
      self["ccx_category"]
    when Discipline[:dh]
      self["dh_category"]
    when Discipline[:bmx]
      self["bmx_category"]
    when Discipline[:mtb]
      self["xc_category"]
    end
  end
  
  def number(discipline_param, reload = false, year = nil)
    return nil if discipline_param.nil?

    year = year || ASSOCIATION.year
    if discipline_param.is_a?(Discipline)
      discipline_param = discipline_param.to_param
    end
    number = race_numbers(reload).detect do |race_number|
      race_number.year == year && race_number.discipline_id == RaceNumber.discipline_id(discipline_param) && race_number.number_issuer.name == ASSOCIATION.short_name
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
    _year ||= ASSOCIATION.year

    if discipline.nil? || !discipline.numbers?
      discipline = Discipline[:road]
    end
    
    if value.blank?
      unless new_record?
        # Delete ALL numbers for ASSOCIATION and this discipline?
        # FIXME Delete number individually in UI
        RaceNumber.destroy_all(
          ['person_id=? and discipline_id=? and year=? and number_issuer_id=?', 
          self.id, discipline.id, _year, association.id])
      end
    else
      if new_record?
        existing_number = race_numbers.any? do |number|
          number.value == value && number.discipline == discipline && number.association == association && number.year == _year
        end
        race_numbers.build(
          :person => self, :value => value, :discipline => discipline, :year => _year, :number_issuer => association, 
          :updated_by => self.updated_by
        ) unless existing_number
      else
        race_number = RaceNumber.find(
          :first,
          :conditions => ['value=? and person_id=? and discipline_id=? and year=? and number_issuer_id=?', 
                           value, self.id, discipline.id, _year, association.id])
        unless race_number
          race_numbers.create(
            :person => self, :value => value, :discipline => discipline, :year => _year, 
            :number_issuer => association, :updated_by => self.updated_by
          )
        end
      end
    end
  end
  
  def bmx_number(reload = false, year = nil)
    number(Discipline[:bmx], reload, year)
  end
  
  def ccx_number(reload = false, year = nil)
    number(Discipline[:cyclocross], reload, year)
  end
  
  def dh_number(reload = false, year = nil)
    number(Discipline[:downhill], reload, year)
  end
  
  def road_number(reload = false, year = nil)
    number(Discipline[:road], reload, year)
  end
  
  def singlespeed_number(reload = false, year = nil)
    number(Discipline[:singlespeed], reload, year)
  end

  def track_number(reload = false, year = nil)
    number(Discipline[:track], reload, year)
  end
  
  def xc_number(reload = false, year = nil)
    number(Discipline[:mountain_bike], reload, year)
  end
  
  def bmx_number=(value)
    add_number(value, Discipline[:bmx])
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

  # Handle updates to people without logins
  def make_login_blanks_nil
    self.login = nil if login.blank?
    self.password = nil if password.blank?
    self.password_confirmation = nil if password_confirmation.blank?
  end
  
  def administrator?
    roles.any? { |role| role.name == "Administrator" }
  end

  def promoter?
    Event.exists?([ "promoter_id = ?", self.id ])
  end

  # Is Person a current member of the bike racing association?
  def member?(date = ASSOCIATION.today)
    date = Date.new(date.year, date.month, date.day) if date.is_a? Time
    !self.member_to.nil? && !self.member_from.nil? && (self.member_from <= date && self.member_to >= date)
  end

  # Is/was Person a current member of the bike racing association at any point during +date+'s year?
  def member_in_year?(date = ASSOCIATION.today)
    date = Date.new(date.year, date.month, date.day) if date.is_a? Time
    year = date.year
    !self.member_to.nil? && !self.member_from.nil? && (self.member_from.year <= year && self.member_to.year >= year)
  end
  
  def member
    member?
  end
  
  # Is Person a current member of the bike racing association?
  def member=(value)
    if value
      self.member_from = ASSOCIATION.today if self.member_from.nil? || self.member_from >= ASSOCIATION.today
      self.member_to = Date.new(ASSOCIATION.effective_year, 12, 31) unless self.member_to && (self.member_to >= Date.new(ASSOCIATION.effective_year, 12, 31))
    elsif !value && member?
      if self.member_from.year == ASSOCIATION.year
        self.member_from = nil
        self.member_to = nil
      else
        self.member_to = Date.new(ASSOCIATION.year - 1, 12, 31)
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
      self[:member_from] = ASSOCIATION.today if self.member_from.nil?
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
    self.member_to && (self.member_to.year >= ASSOCIATION.effective_year)
  end

  def renew!(license_type)
    self.member = true
    self.print_card = true
    self.license_type = license_type
    save!
  end

  def print_card?
    self.print_card
  end
  
  def created_from_result?
    !created_by.nil? && created_by.kind_of?(Event)
  end
  
  def updated_after_created?
    created_at && updated_at && ((updated_at - created_at) > 1.hour) && updated_by
  end

  def deliver_password_reset_instructions!
    reset_perishable_token!
    Notifier.deliver_password_reset_instructions(self)
  end

  def state=(value)
    if value and value.size == 2
      value.upcase!
    end
    super
  end
  
  def city_state
    if !city.blank?
      if !state.blank?
        "#{city}, #{state}"
      else
        "#{city}"
      end
    else
      if !state.blank?
        "#{state}"
      else
        nil
      end
    end
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
        :include => [:team, :person, :scores, :category, {:race => [:event, :category]}],
        :conditions => ['people.id = ?', id]
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

  # Moves another people' aliases, results, and race numbers to this person,
  # and delete the other person.
  # Also adds the other people' name as a new alias
  def merge(other_person)
    # TODO Consider just using straight SQL for this --
    # it's not complicated, and the current process generates an
    # enormous amount of SQL
    raise(ArgumentError, 'Cannot merge nil person') unless other_person
    raise(ArgumentError, 'Cannot merge person onto itself') if other_person == self

    Person.transaction do
      events_with_results = other_person.results.collect do |result|
        event = result.event
        event.disable_notification! if event
        event
      end.compact || []
      if login.blank? && other_person.login.present?
        self.login = other_person.login
        self.crypted_password = other_person.crypted_password
        other_person.update_attribute :login, nil
      end
      if member_from.nil? || (other_person.member_from && other_person.member_from < member_from)
        self.member_from = other_person.member_from
      end
      if member_to.nil? || (other_person.member_to && other_person.member_to > member_to)
        self.member_to = other_person.member_to
      end
      
      if license.blank?
        self.license = other_person.license
      end

      save!
      aliases << other_person.aliases
      events << other_person.events
      results << other_person.results
      race_numbers << other_person.race_numbers
      Person.delete(other_person.id)
      existing_alias = aliases.detect{|a| a.name.casecmp(other_person.name) == 0}
      if existing_alias.nil? and Person.find_all_by_name(other_person.name).empty?
        aliases.create(:name => other_person.name) 
      end
      events_with_results.each do |event|
        event.reload
        event.enable_notification!
      end
    end
    true
  end
  
  # Replace +team+ with exising Team if current +team+ is an unsaved duplicate of an existing Team
  def find_associated_records
    if self.team && team.new_record?
      if team.name.blank? or team.name == 'N/A'
        self.team = nil
      else
        existing_team = Team.find_by_name_or_alias(team.name)
        self.team = existing_team if existing_team
      end
    end
  end
  
  # If name changes to match existing alias, destroy the alias
  def destroy_shadowed_aliases
    Alias.destroy_all(['name = ?', name]) if first_name_changed? || last_name_changed?
  end
  
  def add_alias_for_old_name
    if !new_record? &&
       !@old_name.blank? && 
       !name.blank? && 
       @old_name.casecmp(name) != 0 && 
       !Alias.exists?(['name = ? and person_id = ?', @old_name, id]) && 
       !Person.exists?(["trim(concat(first_name, ' ', last_name)) = ?", @old_name])

      Alias.create!(:name => @old_name, :person => self)
    end
  end

  def validate_unique_editors(editor)
    if editors.include?(editor)
      raise ActiveRecord::ActiveRecordError, "Can't add duplicate editor #{editor.name} for #{name}"
    end
    
    if editor == self
      raise ActiveRecord::ActiveRecordError, "Can't be editor for self"
    end
  end
  
  def account_permissions
    (editors + editable_people).reject { |person| person == self }.uniq.map do |person|
      AccountPermission.new(person, editable_people.include?(person), editors.include?(person))
    end
  end

  # TODO Any reason not to change this to last name, first name?
  def <=>(other)
    if other
      id <=> other.id
    else
      -1
    end
  end
  
  def to_s
    "#<Person #{id} #{first_name} #{last_name} #{team_id}>"
  end
end