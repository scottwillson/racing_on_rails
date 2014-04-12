require "sentient_user/sentient_user"

# Someone who either appears in race results or who is added as a member of a racing association
#
# Names are _not_ unique. In fact, there are many business rules about names. See Aliases and Names.
class Person < ActiveRecord::Base

  YEAR_1900 = Time.zone.local(1900).to_date

  include Comparable
  include Concerns::Versioned
  include Export::People
  include Names::Nameable
  include SentientUser

  acts_as_authentic do |config|
    config.crypto_provider Authlogic::CryptoProviders::Sha512
    config.validates_length_of_login_field_options :within => 3..100, :allow_nil => true, :allow_blank => true
    config.validates_format_of_login_field_options :with => Authlogic::Regex.login,
                                                   :message => I18n.t('error_messages.login_invalid',
                                                   :default => "should use only letters, numbers, spaces, and .-_@ please."),
                                                   :allow_nil => true,
                                                   :allow_blank => true

    config.validates_uniqueness_of_login_field_options :allow_blank => true, :allow_nil => true, :case_sensitive => false
    config.validates_confirmation_of_password_field_options :unless => Proc.new { |user| user.password.blank? }
    config.validates_length_of_password_field_options  :minimum => 4, :allow_nil => true, :allow_blank => true
    config.validates_length_of_password_confirmation_field_options  :minimum => 4, :allow_nil => true, :allow_blank => true
    config.validate_email_field false
    config.disable_perishable_token_maintenance true
    config.maintain_sessions false
  end

  before_validation :find_associated_records
  before_validation :set_membership_dates
  validate :membership_dates
  before_save :destroy_shadowed_aliases
  after_save :add_alias_for_old_name
  before_destroy :ensure_no_results

  has_many :aliases
  has_and_belongs_to_many :editable_people, :class_name => "Person", :foreign_key => "editor_id", :before_add => :validate_unique_editors
  has_and_belongs_to_many :editors, :class_name => "Person", :association_foreign_key => "editor_id", :before_add => :validate_unique_editors
  has_many :editor_requests, :dependent => :destroy
  has_many :events, :foreign_key => "promoter_id"
  has_and_belongs_to_many :editable_events, :class_name => "Event", :foreign_key => "editor_id", :join_table => "editors_events"
  has_many :race_numbers, -> { includes(:discipline, :number_issuer) }
  has_many :results
  has_and_belongs_to_many :roles
  has_many :sent_editor_requests, :foreign_key => "editor_id", :class_name => "EditorRequest", :dependent => :destroy
  belongs_to :team

  accepts_nested_attributes_for :race_numbers,
    :reject_if => proc { |attributes| !attributes.has_key?(:value) || attributes[:value].blank? }

  attr_accessor :year

  CATEGORY_FIELDS = [ :bmx_category, :ccx_category, :dh_category, :mtb_category, :road_category, :track_category ]

  def self.per_page
    50
  end

  # Does not consider Aliases
  def self.find_all_by_name(name)
    Person.where(:name => name).order("last_name, first_name")
  end

  # "Jane Doe" or "Jane", "Doe" or :name => "Jane Doe" or :first_name => "Jane", :last_name => "Doe"
  def self.find_all_by_name_or_alias(*args)
    options = args.extract_options!
    options.keys.each { |key| raise(ArgumentError, "'#{key}' is not a valid key") unless [:name, :first_name, :last_name].include?(key) }

    name = args.join(" ") if options.empty?

    name = name || options[:name]
    first_name = options[:first_name]
    last_name = options[:last_name]

    if name.present?
      Person.where(:name => name) | Alias.find_all_people_by_name(name)
    elsif first_name.present? && last_name.blank?
      Person.where(:first_name => first_name) | Alias.find_all_people_by_name(Person.full_name(first_name, last_name))
    elsif first_name.blank? && last_name.present?
      Person.where(:last_name => last_name) | Alias.find_all_people_by_name(Person.full_name(first_name, last_name))
    else
      Person.where(:first_name => first_name).where(:last_name => last_name) | Alias.find_all_people_by_name(Person.full_name(first_name, last_name))
    end
  end

  # Considers aliases
  def self.find_all_by_name_like(name, limit = RacingAssociation.current.search_results_limit, page = 1)
    return [] if name.blank?

    name_like = "%#{name.strip}%"
    Person.
      where("people.name like ? or aliases.name like ?", name_like, name_like).
      includes(:team).
      includes(:aliases).
      references(:aliases).
      limit(limit).
      page(page).
      order('last_name, first_name')
  end

  def self.find_by_info(name, email = nil, home_phone = nil)
    if name.present?
      Person.find_by_name(name)
    else
      Person.where(
        "(email = ? and email <> '' and email is not null) or (home_phone = ? and home_phone <> '' and home_phone is not null)",
        email, home_phone
      ).first
    end
  end

  def self.find_by_name(name)
    Person.where(:name => name).first
  end

  def self.find_all_by_number(number)
    RaceNumber.
      includes(:person).
      where(:year => [ RacingAssociation.current.year, RacingAssociation.current.next_year ]).
      where(:value => number).
      map(&:person)
  end

  def self.full_name(first_name, last_name)
    "#{first_name} #{last_name}".strip
  end

  # Flattened, straight SQL dump for export to Excel, FinishLynx, or SportsBase.
  def self.find_all_for_export(date = Time.zone.today, include_people = "members_only")
    association_number_issuer_id = NumberIssuer.find_by_name(RacingAssociation.current.short_name).id
    if include_people == "members_only"
      where_clause = "WHERE (member_to >= '#{date.to_s}')"
    elsif include_people == "print_cards"
      where_clause = "WHERE  (member_to >= '#{date.to_s}') and print_card is true"
    end

    people = Person.connection.select_all(%Q{
      SELECT people.id, license, first_name, last_name, teams.name as team_name, team_id, people.notes,
             member_from, member_to, member_usac_to,
             (member_from IS NOT NULL AND member_to IS NOT NULL AND member_from <= NOW() AND member_to >= NOW()) as member,
             print_card, card_printed_at, membership_card, ccx_only, date_of_birth, occupation,
             street, people.city, people.state, zip, wants_mail, email, wants_email, home_phone, work_phone, cell_fax, gender,
             ccx_category, road_category, track_category, mtb_category, dh_category,
             volunteer_interest, official_interest, race_promotion_interest, team_interest,
             CEILING(#{date.year} - YEAR(date_of_birth)) as racing_age,
             ccx_numbers.value as ccx_number, dh_numbers.value as dh_number, road_numbers.value as road_number,
             singlespeed_numbers.value as singlespeed_number, xc_numbers.value as xc_number,
             people.created_at, people.updated_at
      FROM people
      LEFT OUTER JOIN teams ON teams.id = people.team_id
      LEFT OUTER JOIN race_numbers as ccx_numbers ON ccx_numbers.person_id = people.id
                      and ccx_numbers.number_issuer_id = #{association_number_issuer_id}
                      and ccx_numbers.year = #{date.year}
                      and ccx_numbers.discipline_id = #{Discipline[:cyclocross].id}
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
    people.to_a.reject do |person|
      if last_person && last_person["id"] == person["id"]
        true
      else
        last_person = person
        false
      end
    end
  end

  # interprets dates returned in sql above for member export
  def self.lic_check(lic, lic_date)
    if lic_date && lic.to_i > 0
      case lic_date
      when Date, Time, DateTime
        (lic_date > Time.zone.today) ? "current" : "CHECK LIC!"
      else
        (Date.strptime(lic_date, "%m/%d/%Y") > Time.zone.today) ? "current" : "CHECK LIC!"
      end
    else
      "NOT ON FILE"
    end
  end

  # Find Person with most recent. If no results, select the most recently updated Person.
  def self.select_by_recent_activity(people)
    results = people.to_a.inject([]) { |r, person| r + person.results }
    if results.empty?
      people.to_a.sort_by(&:updated_at).last
    else
      results = results.sort_by(&:date)
      results.last.person
    end
  end

  def self.deliver_password_reset_instructions!(people)
    people.each(&:reset_perishable_token!)
    Notifier.password_reset_instructions(people).deliver
  end

  def people_with_same_name
    if name.present?
      people = Person.find_all_by_name(name) | Alias.find_all_people_by_name(name)
      people.reject! { |person| person == self }
      people
    else
      []
    end
  end

  def people_name_sounds_like
    return [] if name.blank?

    Person.where.not(:id => id).where("soundex(name) = soundex(?)", name.strip) +
    Person.where(:first_name => last_name).where(:last_name => first_name)
  end

  # Name on year. Could be rolled into Nameable?
  def name(date_or_year = nil)
    year = parse_year(date_or_year)
    name_record_for_year(year).try(:name) || Person.full_name(first_name(year), last_name(year))
  end

  def first_name(date_or_year = nil)
    year = parse_year(date_or_year)
    name_record_for_year(year).try(:first_name) || read_attribute(:first_name)
  end

  def last_name(date_or_year = nil)
    year = parse_year(date_or_year)
    name_record_for_year(year).try(:last_name) || read_attribute(:last_name)
  end

  def email_with_name
    if name.present?
      "#{name} <#{email}>"
    else
      email
    end
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
    self[:name] = value
    if value.blank?
      self[:first_name] = ''
      self[:last_name] = ''
      return
    end

    if value.include?(',')
      parts = value.split(',')
      if parts.size > 0
        self[:last_name] = parts[0].strip
        if parts.size > 1
          self[:first_name] = parts[1..(parts.size - 1)].join.strip
          self[:last_name]
        end
      end
    else
      parts = value.split(' ')
      case parts.size
      when 0
        self[:first_name] = ""
        self[:last_name] = ""
      when 1
        self[:first_name] = parts[0].strip
        self[:last_name] = ""
      else
        self[:first_name] = parts[0].strip
        self[:last_name] = parts[1..(parts.size - 1)].join(" ").strip
      end
    end
  end

  def first_name=(value)
    self[:name] = Person.full_name(value, last_name)
    self[:first_name] = value
  end

  def last_name=(value)
    self[:name] = Person.full_name(first_name, value)
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
      self.team = Team.new(:name => value, :updated_by => new_record? ? updated_by : nil) unless self.team
    end
  end

  def gender_pronoun
    if female?
      "herself"
    else
      "himself"
    end
  end

  def possessive_pronoun
    if female?
      "her"
    else
      "his"
    end
  end

  def third_person_pronoun
    if female?
      "her"
    else
      "him"
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
      if value[%r{^\d\d/\d\d/\d\d$}]
        value.gsub! %r{(\d+)/(\d+)/(\d+)}, '19\3/\1/\2'
      else
        value.gsub!(/^00/, '19')
        value.gsub!(/^(\d+\/\d+\/)(\d\d)$/, '\119\2')
      end
    end

    if value && value.to_s.size < 5
      int_value = value.to_i
      if int_value > 10 && int_value <= 99
        value = "01/01/19#{value}"
      end
      if int_value > 0 && int_value <= 10
        value = "01/01/20#{value}"
      end
    end

    # Don't overwrite month and day if we're just passing in the same year
    if self[:date_of_birth] && value
      if value.is_a?(String)
        new_date = Date.parse(value)
      else
        new_date = value
      end
      if new_date.year == self[:date_of_birth].year && new_date.month == 1 && new_date.day == 1
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
      date_of_birth <= Date.new(RacingAssociation.current.masters_age.years.ago.year, 12, 31)
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

  def female?
    gender == "F"
  end

  def male?
    gender == "M"
  end

  def age_category
    if female?
      if junior?
        "girl"
      else
        "woman"
      end
    else
      if master?
        "master"
      elsif junior?
        "boy"
      else
        "man"
      end
    end
  end

  # Oldest age person will be at any point in year
  def racing_age
    if date_of_birth
      (RacingAssociation.current.year - date_of_birth.year).ceil
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

    year ||= RacingAssociation.current.year
    if discipline_param.is_a?(Discipline)
      discipline_param = discipline_param.to_param
    end
    number = race_numbers(reload).detect do |race_number|
      race_number.year == year &&
      race_number.discipline_id == RaceNumber.discipline_id(discipline_param) &&
      race_number.number_issuer.name == RacingAssociation.current.short_name
    end
    number.try :value
  end

  # Look for RaceNumber +year+ in +attributes+. Not sure if there's a simple and better way to do that.
  # Need to set +updated_by+ before setting numbers to ensure updated_by is passed to number. Setting all via a
  # parameter hash may add number before updated_by is set.
  def add_number(value, discipline, association = nil, _year = year)
    association = NumberIssuer.find_by_name(RacingAssociation.current.short_name) if association.nil?
    _year ||= RacingAssociation.current.year

    if discipline.nil? || !discipline.numbers?
      discipline = Discipline[:road]
    end

    if value.blank?
      unless new_record?
        # Delete ALL numbers for RacingAssociation.current and this discipline?
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
          :value => value, :discipline => discipline, :year => _year, :number_issuer => association,
          :updated_by => updated_by
        ) unless existing_number
      else
        RaceNumber.where(
          :value => value, :person_id => id, :discipline_id => discipline.id, :year => _year, :number_issuer_id => association.id
        ).first || race_numbers.create(
          :value => value, :discipline => discipline, :year => _year, :number_issuer => association, :updated_by => updated_by
        )
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

  def administrator?
    roles.any? { |role| role.name == "Administrator" }
  end

  def promoter?
    if new_record?
      false
    else
      Event.where(:promoter_id => id).exists? || editable_events.present?
    end
  end

  # Is Person a current member of the bike racing association?
  def member?(date = Time.zone.today)
    member_to.present? && member_from.present? && member_from.to_date <= date.to_date && member_to.to_date >= date.to_date
  end

  # Is/was Person a current member of the bike racing association at any point during +date+'s year?
  def member_in_year?(date = Time.zone.today)
    year = date.year
    member_to && member_from && member_from.year <= year && member_to.year >= year
    member_to.present? && member_from.present? && member_from.year <= year && member_to.year >= year
  end

  def member
    member?
  end

  def member=(value)
    if value
      self.member_from = Time.zone.today if member_from.nil? || member_from.to_date >= Time.zone.today.to_date
      unless member_to && (member_to.to_date >= Time.zone.local(RacingAssociation.current.effective_year).end_of_year.to_date)
        self.member_to = Time.zone.local(RacingAssociation.current.effective_year).end_of_year.to_date
      end
    elsif !value && member?
      if self.member_from.year == RacingAssociation.current.year
        self.member_from = nil
        self.member_to = nil
      else
        self.member_to = Time.zone.local(RacingAssociation.current.year - 1).end_of_year.to_date
      end
    end
  end

  # Also sets member_to if it is blank
  def member_from=(date)
    if date.nil?
      self[:member_from] = nil
      self[:member_to] = nil
      return date
    end

    date_as_date = case date
    when Date, DateTime, Time
      Time.zone.local(date.year, date.month, date.day)
    else
      Time.zone.parse(date)
    end

    self[:member_from] = date_as_date
  end

  # Also sets member_from if it is blank
  def set_membership_dates
    if member_from && member_to.nil?
      self.member_to = Time.zone.local(member_from.year).end_of_year
    elsif member_from.nil? && member_to
      self.member_from = Time.zone.today if member_from.nil?
      self.member_from = member_to if member_from.to_date > member_to.to_date
    elsif member_from && member_to && member_from.to_date > member_to.to_date
      self.member_from = member_to
    end
    true
  end

  # Validates member_from and member_to
  def membership_dates
    if member_to && !member_from
      errors.add('member_from', "cannot be nil if member_to is not nil (#{member_to})")
    end
    if member_from && !member_to
      errors.add('member_to', "cannot be nil if member_from is not nil (#{member_from})")
    end
    if member_from && member_to && member_from.to_date > member_to.to_date
      errors.add('member_to', "cannot be greater than member_from: #{member_from}")
    end
    if member_from && member_from < YEAR_1900
      self.member_from = member_from_was
    end
    if member_to && member_to < YEAR_1900
      self.member_to = member_to_was
    end
  end

  def renewed?
    member_to && member_to.year >= RacingAssociation.current.effective_year
  end

  def renew!(license_type)
    self.member = true
    self.print_card = true
    self.license_type = license_type
    save!
  end

  def state=(value)
    if value and value.size == 2
      value.upcase!
    end
    super
  end

  def city_state
    if city.present?
      if state.present?
        "#{city}, #{state}"
      else
        "#{city}"
      end
    else
      if state.present?
        "#{state}"
      else
        nil
      end
    end
  end

  def city_state_zip
    if city.present?
      if state.present?
        "#{city}, #{state} #{zip}"
      else
        "#{city} #{zip}"
      end
    else
      if state.present?
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
        if state == RacingAssociation.current.state
          ''
        else
          state
        end
      end
    else
      if state.blank?
        city
      else
        if state == RacingAssociation.current.state
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
    if attribute.try(:to_s) == 'member'
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
      return Result.
        includes(:team, :person, :scores, :category, {:race => [:event, :category]}).
        where("people.id" => id).
        reject {|r| r.competition_result?}
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
    # Consider just using straight SQL for this --
    # it's not complicated, and the current process generates an
    # enormous amount of SQL

    if other_person.nil? || other_person == self
      return false
    end

    Person.transaction do
      ActiveRecord::Base.lock_optimistically = false
      self.merge_version do
        events_with_results = other_person.results.collect do |result|
          event = result.event
          event.disable_notification! if event
          event
        end.compact || []
        if login.blank? && other_person.login.present?
          self.login = other_person.login
          self.crypted_password = other_person.crypted_password
          other_person.skip_version do
            other_person.update_attributes :login => nil
          end
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
        names << other_person.names
        results << other_person.results
        race_numbers << other_person.race_numbers

        begin
          versions << other_person.versions
        rescue ActiveRecord::SerializationTypeMismatch => e
          logger.error e
        end

        versions.sort_by(&:created_at).each_with_index do |version, index|
          version.number = index + 2
          version.save!
        end

        Person.delete other_person.id
        existing_alias = aliases.detect{ |a| a.name.casecmp(other_person.name) == 0 }
        if existing_alias.nil? and Person.find_all_by_name(other_person.name).empty?
          aliases.create(:name => other_person.name)
        end
        events_with_results.each do |event|
          event.reload
          event.enable_notification!
        end
      end
      ActiveRecord::Base.lock_optimistically = true
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

  def can_edit?(person)
    person == self || administrator? || person.editors.include?(self)
  end

  # If name changes to match existing alias, destroy the alias
  def destroy_shadowed_aliases
    Alias.destroy_all(['name = ?', name]) if first_name_changed? || last_name_changed?
  end

  def add_alias_for_old_name
    if !new_record? &&
       name_was.present? &&
       name.present? &&
       name_was.casecmp(name) != 0 &&
       !Alias.exists?(['name = ? and person_id = ?', name_was, id]) &&
       !Person.exists?(["name = ?", name_was])

      new_alias = Alias.new(:name => name_was, :person => self)
      unless new_alias.save
        logger.error "Could not save alias #{new_alias}: #{new_alias.errors.full_messages.join(", ")}"
      end
      new_alias
    end
  end

  def ensure_no_results
    if results.present?
      errors.add :base, "Can't delete person with results"
    end
    errors.empty?
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