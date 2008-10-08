# Number used to identify a Racer during a Race: bib number. RaceNumbers are issued from a NumberIssuer, 
# which is usually a racing Association, but sometimes an Event.
#
# In the past, RaceNumbers had to be unique for NumberIssuer, Discipline and year. But we allow 
# duplicates now.
#
# +Value+ is the number on the physical number plate. RaceNumber values can have letters and numbers
#
# This all may seem to be a case or over-modelling, but it refleccts how numbers are used by promoters
# and associations. RacerNumbers are also used to differentiate between Racers with the same name, and 
# to identify racer results with misspelled names.
class RaceNumber < ActiveRecord::Base
  before_validation :defaults
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
  
  # Different disciplines have different rules about what is a rental number
  def RaceNumber.rental?(number, discipline = Discipline[:road])
    if ASSOCIATION.rental_numbers.nil?
      return false
    end
    
    if number.blank?
      return true
    end

    if ASSOCIATION.rental_numbers.nil? || discipline == Discipline[:mountain_bike] || discipline == Discipline[:downhill] || number.strip[/^\d+$/].nil?
      return false
    end
    
    numeric_value = number.to_i    
    if ASSOCIATION.rental_numbers.include?(numeric_value)
      return true
    end
    
    false
  end
  
  # Default to Road, ASSOCIATION, and current year
  def defaults
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
  
  # Checks that Racer doesn't already have this number.
  #
  # Numbers are unique by value, Racer, Discipline, NumberIssuer, and year.
  #
  # Skips check if +racer+ is not set. Typically, this happens when
  # importing a Result that has a +number+, but no +racer+
  #
  # OBRA rental numbers (11-99) are not valid
  def unique_number 
    _discipline = Discipline.find(self[:discipline_id])
    if RaceNumber.rental?(self[:value], _discipline)
      errors.add('value', "#{value} is a rental numbers. #{ASSOCIATION.short_name} rental numbers: #{ASSOCIATION.rental_numbers}")
      racer.errors.add('value', "#{value} is a rental numbers. #{ASSOCIATION.short_name} rental numbers: #{ASSOCIATION.rental_numbers}")
      return false 
    end
    
    return true if racer.nil?
  
    if new_record?
      existing_numbers = RaceNumber.find(
        :all,
        :conditions => ['value=? and discipline_id=? and number_issuer_id=? and year=? and racer_id = ?', 
        self[:value], self[:discipline_id], self[:number_issuer_id], self[:year], racer.id])
    else
      existing_numbers = RaceNumber.find(
        :all,
        :conditions => ['value=? and discipline_id=? and number_issuer_id=? and year=? and id<>? and racer_id = ?', 
        self[:value], self[:discipline_id], self[:number_issuer_id], self[:year], self.id, racer.id])
    end
      
    unless existing_numbers.empty?
      racer_id = racer.id
      errors.add('value', "Number '#{value}' can't be used for #{racer.name}. Already used as #{year} #{number_issuer.name} #{discipline.name.downcase} number.")
      racer.errors.add('value', "Number '#{value}' can't be used for #{racer.name}. Already used as #{year} #{number_issuer.name} #{discipline.name.downcase} number.")
      if existing_numbers.size > 1
        logger.warn("Race number '#{value}' found #{existing_numbers.size} times for discipline #{discipline_id}, number issuer #{number_issuer_id}, year #{year}, racer #{racer_id}")
      end
      return false
    end
  end
  
  def to_s
    "<RaceNumber (#{id}) (#{value}) (#{racer_id}) (#{number_issuer_id}) (#{discipline_id}) (#{year})>"
  end
end