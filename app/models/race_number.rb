# Number used to indentify a Racer during a Race: bib number. RaceNumbers are issued from a NumberIssuer, 
# which is usually a racing Association, but sometimes an Event. RaceNumbers are also restricted
# by Discipline and year.
#
# +Value+ is the number on the physical number. RaceNumber values can have letters and numbers
#
# This all may seem to be a case or over-modelling, but it refleccts how numbers are used by promoters
# and associations. RacerNumbers are also used to differentiate between Racers with the same name, and 
# to identify racer results with misspelled names.
#
# TODO Add same(other) method that compares significatn fields
class RaceNumber < ActiveRecord::Base
  validates_presence_of :discipline_id
  validates_presence_of :number_issuer_id
  validates_presence_of :racer_id
  validates_presence_of :value
  validate :unique_number
  
  before_save :get_racer_id
  before_save :validate_year
  
  belongs_to :discipline
  belongs_to :number_issuer
  belongs_to :racer
  
  def RaceNumber.find_all_by_value_and_event(value, _event)
    return [] if _event.nil? or value.blank?
    _event.number_issuer(true) unless _event.number_issuer
    return [] unless _event.number_issuer

    discipline_id = RaceNumber.discipline_id(_event.discipline)
    race_numbers = RaceNumber.find(
      :all, 
      :conditions => ['value=? and discipline_id = ? and number_issuer_id=? and year=?',
                      value, 
                      discipline_id, 
                      _event.number_issuer.id, 
                      _event.date.year],
      :include => :racer
    )
  end
  
  # FIXME Dupe of lousy code from Discipline
  def RaceNumber.discipline_id(discipline)
    case discipline
    when Discipline[:cyclocross]
      Discipline[:cyclocross].id
    when Discipline[:mountain_bike]
      Discipline[:mountain_bike].id
    else
      Discipline[:road].id
    end
  end
  
  def RaceNumber.rental?(number)
    if number.nil? || ASSOCIATION.rental_numbers.nil? || number.strip[/^\d+$/].nil?
      return false
    end
    numeric_value = number.to_i
    if ASSOCIATION.rental_numbers.include?(numeric_value)
      return true
    end
    false
  end
  
  # Default to Road, ASSOCIATION, and current year
  def after_initialize
    self.discipline = Discipline[:road] unless self.discipline
    self.number_issuer = NumberIssuer.find_by_name(ASSOCIATION.short_name) unless self.number_issuer
    self.year = Date.today.year unless (self.year and self.year > 1800)
  end
  
  def get_racer_id
    if racer and racer.new_record?
      racer.reload
    end
  end
  
  def validate_year
    self.year > 1800
  end
  
  # Checks that another Racer doesn't already have this number.
  #
  # Numbers are unique by value, Discipline, NumberIssuer, and year.
  #
  # Skips check if +racer+ is not set. Typically, this happens when
  # importing a Result that has a +number+, but no +racer+
  #
  # OBRA rental numbers (11-99) are not valid
  def unique_number 
    if RaceNumber.rental?(self[:value])
      errors.add('value', "#{value} is a rental numbers. #{ASSOCIATION.short_name} rental numbers: #{ASSOCIATION.rental_numbers}")
      return false 
    end
    
    return true if racer.nil?
  
    if ASSOCIATION.gender_specific_numbers && !racer.gender.blank?
      existing_numbers = RaceNumber.count_by_sql([%q{
        SELECT COUNT(DISTINCT race_numbers.id) 
        FROM race_numbers 
        join racers ON racers.id = race_numbers.racer_id 
        WHERE (value=? and discipline_id=? and number_issuer_id=? and year=? and racers.gender=? and racers.id <> ?)}, 
        value, discipline.id, number_issuer.id, year, racer.gender, racer.id]
      )
    else
      if new_record?
        existing_numbers = RaceNumber.count(
          :conditions => ['value=? and discipline_id=? and number_issuer_id=? and year=? and racer_id <> ?', 
          self[:value], self[:discipline_id], self[:number_issuer_id], self[:year], racer.id])
      else
        existing_numbers = RaceNumber.count(
          :conditions => ['value=? and discipline_id=? and number_issuer_id=? and year=? and id<>?', 
          self[:value], self[:discipline_id], self[:number_issuer_id], self[:year], self.id])
      end
    end
      
    unless existing_numbers == 0
      if racer
        racer_id = racer.id
      else
        racer_id = nil
      end
      errors.add('value', "'#{value}' already used for discipline #{discipline_id}, number issuer #{number_issuer_id}, year #{year}, racer #{racer_id}")
      if existing_numbers > 1
        logger.warn("Race number '#{value}' found #{existing_numbers} times for discipline #{discipline_id}, number issuer #{number_issuer_id}, year #{year}, racer #{racer_id}")
      end
      return false
    end
  end
  
  def to_s
    "<RaceNumber (#{id}) (#{value}) (#{racer_id}) (#{number_issuer_id}) (#{discipline_id}) (#{year})>"
  end
end