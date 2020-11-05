# frozen_string_literal: true

# Number used to identify a Person during a Race: bib number. RaceNumbers are issued from a NumberIssuer,
# which is usually a racing Association, but sometimes an Event.
#
# In the past, RaceNumbers had to be unique for NumberIssuer, Discipline and year. But we allow
# duplicates now.
#
# +Value+ is the number on the physical number plate. RaceNumber values can have letters and numbers
#
# This all may seem to be a case or over-modelling, but it refleccts how numbers are used by promoters
# and associations. PersonNumbers are also used to differentiate between People with the same name, and
# to identify person results with misspelled names.
class RaceNumber < ApplicationRecord
  include RacingOnRails::PaperTrail::Versions

  validates :discipline, presence: true
  validates :number_issuer, presence: true
  validates :person, presence: true
  validates :value, presence: true
  validate :unique_number

  before_save :validate_year

  belongs_to :discipline
  belongs_to :number_issuer
  belongs_to :person

  attribute :discipline_id, :integer, default: -> { Discipline[RacingAssociation.current.default_discipline].try(:id) }
  attribute :number_issuer_id, :integer, default: -> { RacingAssociation.current.number_issuer.try(:id) }
  attribute :year, :integer, default: -> { RacingAssociation.current.effective_year }

  def self.find_all_by_value_and_event(value, _event)
    return [] if _event.nil? || value.blank? || _event.number_issuer.nil?

    discipline_id = RaceNumber.discipline_id(_event.discipline)
    return [] unless discipline_id

    RaceNumber
      .includes(:person)
      .where(value: value)
      .where(discipline_id: discipline_id)
      .where(number_issuer_id: _event.number_issuer_id)
      .where(year: _event.date.year)
  end

  # Dupe of lousy code from Discipline
  def self.discipline_id(discipline)
    case Discipline[discipline]
    when Discipline[:road], Discipline[:track], Discipline[:time_trial], Discipline[:circuit], Discipline[:criterium]
      Discipline[:road].id
    when Discipline[:cyclocross]
      Discipline[:cyclocross].id
    when Discipline[:mountain_bike], Discipline[:super_d]
      Discipline[:mountain_bike].id
    when Discipline[:downhill]
      Discipline[:downhill].id
    when Discipline[:singlespeed]
      Discipline[:singlespeed].id
    else
      Discipline[:road].id
    end
  end

  # Different disciplines have different rules about what is a rental number
  def self.rental?(number, discipline = Discipline[:road])
    return false if RacingAssociation.current.rental_numbers.nil?

    return true if number.blank?

    return false if discipline == Discipline[:mountain_bike] || discipline == Discipline[:downhill]

    return false if number.strip[/^\d+$/].nil?

    numeric_value = number.to_i
    return true if RacingAssociation.current.rental_numbers.include?(numeric_value)

    false
  end

  def value=(value)
    self[:value] = if value
                     value.to_s
                   else
                     value
                   end

    self[:value]
  end

  def year=(value)
    self[:year] = value if value && value.to_i > 1800
    year
  end

  def validate_year
    year > 1800
  end

  # Checks that Person doesn't already have this number.
  #
  # Numbers are unique by value, Person, Discipline, NumberIssuer, and year.
  #
  # Skips check if +person+ is not set. Typically, this happens when
  # importing a Result that has a +number+, but no +person+
  #
  # OBRA rental numbers (11-99) are not valid
  def unique_number
    _discipline = Discipline.find(discipline_id)
    if number_issuer.association? && RaceNumber.rental?(value, _discipline)
      errors.add("value", "#{value} is a rental number. #{RacingAssociation.current.short_name} rental numbers: #{RacingAssociation.current.rental_numbers}")
      person.errors.add("value", "#{value} is a rental number. #{RacingAssociation.current.short_name} rental numbers: #{RacingAssociation.current.rental_numbers}")
      return false
    end

    return true if person.nil?

    if new_record?
      existing_numbers = RaceNumber
                         .where(value: value, discipline_id: discipline_id, number_issuer_id: number_issuer_id, year: year, person_id: person_id)
                         .count
    else
      existing_numbers = RaceNumber
                         .where(value: value, discipline_id: discipline_id, number_issuer_id: number_issuer_id, year: year, person_id: person_id)
                         .where.not(id: id)
                         .count
    end

    unless existing_numbers == 0
      person_id = person.id
      errors.add("value", "Number '#{value}' can't be used for #{person.name}. Already used as #{year} #{number_issuer.name} #{discipline.name.downcase} number.")
      person.errors.add("value", "Number '#{value}' can't be used for #{person.name}. Already used as #{year} #{number_issuer.name} #{discipline.name.downcase} number.")
      if existing_numbers.size > 1
        logger.warn("Race number '#{value}' found #{existing_numbers} times for discipline #{discipline_id}, number issuer #{number_issuer_id}, year #{year}, person #{person_id}")
      end
      return false
    end
  end

  def <=>(other)
    if other
      value <=> other.value
    else
      -1
    end
  end

  def to_s
    "<RaceNumber (#{id}) (#{value}) (#{person_id}) (#{number_issuer_id}) (#{discipline_id}) (#{year})>"
  end
end
