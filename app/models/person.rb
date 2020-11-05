# frozen_string_literal: true

require "sentient_user/sentient_user"

# Someone who either appears in race results or who is added as a member of a racing association
#
# Names are _not_ unique. In fact, there are many business rules about names. See Aliases and Names.
class Person < ApplicationRecord
  include Comparable
  include Export::People
  include Names::Nameable
  include People::Aliases
  include People::Ages
  include People::Authorization
  include People::Export
  include People::Gender
  include People::Membership
  include People::Merge
  include People::Names
  include People::Numbers
  include RacingOnRails::PaperTrail::Versions
  include SentientUser

  acts_as_authentic do |config|
    config.crypto_provider = Authlogic::CryptoProviders::SCrypt
    config.disable_perishable_token_maintenance true
    config.log_in_after_create false
    config.log_in_after_password_change false
    config.transition_from_crypto_providers = [Authlogic::CryptoProviders::Sha512]
  end

  validates :login,
            allow_blank: true,
            format: { with: /\A\w[\w\.+\-_@ ]+\z/, message: "should use only letters, numbers, spaces, and .-_@ please" },
            length: { in: 3..100 },
            uniqueness: { case_sensitive: false }

  validates :password,
            allow_blank: true,
            length: { minimum: 4 }

  validates :password_confirmation,
            allow_blank: true,
            length: { minimum: 4 },
            presence: true,
            if: proc { |user| user.password.present? }

  before_validation :find_associated_records
  before_validation :set_membership_dates
  before_save { |r| r.license = nil if license.blank? }
  validate :membership_dates
  before_destroy :ensure_no_results

  has_and_belongs_to_many :editable_events, class_name: "Event", foreign_key: "editor_id", join_table: "editors_events"
  has_many :events, foreign_key: "promoter_id"
  has_many :event_team_memberships, dependent: :destroy
  has_many :event_teams, through: :event_team_memberships
  has_many :results
  belongs_to :team, optional: true

  attr_accessor :password_confirmation, :year

  CATEGORY_FIELDS = %i[bmx_category ccx_category dh_category mtb_category road_category track_category].freeze

  def self.where_name_or_number_like(name)
    return Person.none if name.blank?

    Person
      .where(
        "people.name like :name_like or aliases.name like :name_like or race_numbers.value = :name",
        name_like: "%#{name.strip}%", name: name.strip
      )
      .includes(:aliases)
      .includes(:race_numbers)
      .includes(:team)
      .references(:aliases)
      .references(:race_numbers)
      .order(:last_name, :first_name)
  end

  def self.first_by_info(name, email = nil, home_phone = nil)
    if name.present?
      Person.find_by(name: name)
    else
      Person.where(
        "(email = ? and email <> '' and email is not null) or (home_phone = ? and home_phone <> '' and home_phone is not null)",
        email, home_phone
      ).first
    end
  end

  # interprets dates returned in sql above for member export
  def self.lic_check(lic, lic_date)
    if lic_date && lic.to_i > 0
      case lic_date
      when Date, Time, DateTime
        lic_date > Time.zone.today ? "current" : "CHECK LIC!"
      else
        Date.strptime(lic_date, "%m/%d/%Y") > Time.zone.today ? "current" : "CHECK LIC!"
      end
    else
      "NOT ON FILE"
    end
  end

  # Find Person with most recent. If no results, select the most recently updated Person.
  def self.select_by_recent_activity(people)
    results = people.map(&:results).flatten
    if results.empty?
      people.to_a.sort_by(&:updated_at).last
    else
      results = results.sort_by(&:date)
      results.last.person
    end
  end

  def self.deliver_password_reset_instructions!(people)
    people.each(&:reset_perishable_token!)
    Notifier.password_reset_instructions(people).deliver_now
  end

  # Cannot have promoters with duplicate contact information
  def unique_info
    person = Person.first_by_info(name, email, home_phone)
    errors.add("existing person with name '#{name}'") if person && person != self
  end

  def team_name
    if team
      team.name || ""
    else
      ""
    end
  end

  def team_name=(value)
    if value.blank? || value == "N/A"
      self.team = nil
    else
      self.team = Team.find_by_name_or_alias(value)
      self.team = Team.new(name: value, updater: new_record? ? updater : nil) unless team
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
    self[:gender] || ""
  end

  def gender=(value)
    if value.nil?
      self[:gender] = nil
    else
      value = value.upcase
      case value
      when "M", "MALE", "BOY"
        self[:gender] = "M"
      when "F", "FEMALE", "GIRL"
        self[:gender] = "F"
      else
        self[:gender] = "M"
      end
    end
  end

  def category(discipline)
    _discipline = if discipline.is_a?(String)
                    Discipline[discipline]
                  else
                    discipline
                  end

    case _discipline
    when Discipline[:road], Discipline[:criterium], Discipline[:time_trial], Discipline[:circuit]
      self["road_category"]
    when Discipline[:track]
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

  def state=(value)
    value = value.to_s.upcase if value && value.to_s.size == 2
    super value
  end

  def city_state
    if city.present?
      if state.present?
        "#{city}, #{state}"
      else
        city.to_s
      end
    else
      state.to_s if state.present?
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
        zip || ""
      end
    end
  end

  def hometown
    if city.blank?
      if state.blank?
        ""
      else
        if state == RacingAssociation.current.state
          ""
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

    parts = value.split(",")
    self.state = parts.last.strip if parts.size > 1
    self.city = parts.first.strip
  end

  # Hack around in-place editing
  def toggle!(attribute)
    if attribute.try(:to_s) == "member"
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
      return Result
             .includes(:team, :person, :scores, :category, race: %i[event category])
             .where("people.id" => id)
             .reject(&:competition_result?)
    end
    results.reject(&:competition_result?)
  end

  # BAR, Oregon Cup, Ironman
  def competition_results
    results.select(&:competition_result?)
  end

  # Replace +team+ with exising Team if current +team+ is an unsaved duplicate of an existing Team
  def find_associated_records
    if team&.new_record?
      if team.name.blank? || (team.name == "N/A")
        self.team = nil
      else
        existing_team = Team.find_by_name_or_alias(team.name)
        self.team = existing_team if existing_team
      end
    end
  end

  def ensure_no_results
    if results.present?
      errors.add :base, "Can't delete person with results"
      throw :abort
    end
  end

  # TODO: Any reason not to change this to last name, first name?
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
