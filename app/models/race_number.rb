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
class RaceNumber < ActiveRecord::Base
  before_validation :defaults
  validates_presence_of :discipline
  validates_presence_of :number_issuer
  validates_presence_of :person, :unless => :new_record?
  validates_presence_of :value
  validate :unique_number
  
  before_save :get_person_id
  before_save :validate_year
  
  belongs_to :discipline
  belongs_to :number_issuer
  belongs_to :person
  
  def RaceNumber.find_all_by_value_and_event(value, _event)
    return [] if _event.nil? || value.blank? || _event.number_issuer.nil?
    
    discipline_id = RaceNumber.discipline_id(_event.discipline)
    return [] unless discipline_id
    
    race_numbers = RaceNumber.find(
      :all, 
      :conditions => ['value=? and discipline_id = ? and number_issuer_id=? and year=?',
                      value, 
                      discipline_id, 
                      _event.number_issuer.id, 
                      _event.date.year],
      :include => :person
    )
  end
  
  # FIXME Dupe of lousy code from Discipline
  def RaceNumber.discipline_id(discipline)
    case Discipline[discipline]
    when Discipline[:road], Discipline[:track], Discipline[:time_trial], Discipline[:circuit], Discipline[:criterium]
      Discipline[:road].id
    when Discipline[:cyclocross]
      Discipline[:cyclocross].id
    when Discipline[:mountain_bike]
      Discipline[:mountain_bike].id
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
    self.year = ASSOCIATION.effective_year unless (self.year and self.year > 1800)
  end
  
  def get_person_id
    if person && (person.new_record? || person.changed?)
      person.reload
    end
  end
  
  def validate_year
    self.year > 1800
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
    _discipline = Discipline.find(self[:discipline_id])
    if RaceNumber.rental?(self[:value], _discipline)
      errors.add('value', "#{value} is a rental number. #{ASSOCIATION.short_name} rental numbers: #{ASSOCIATION.rental_numbers}")
      person.errors.add('value', "#{value} is a rental number. #{ASSOCIATION.short_name} rental numbers: #{ASSOCIATION.rental_numbers}")
      return false 
    end
    
    return true if person.nil?
  
    if new_record?
      existing_numbers = RaceNumber.count(
        :conditions => ['value=? and discipline_id=? and number_issuer_id=? and year=? and person_id = ?', 
        self[:value], self[:discipline_id], self[:number_issuer_id], self[:year], person.id])
    else
      existing_numbers = RaceNumber.count(
        :conditions => ['value=? and discipline_id=? and number_issuer_id=? and year=? and id<>? and person_id = ?', 
        self[:value], self[:discipline_id], self[:number_issuer_id], self[:year], self.id, person.id])
    end
      
    unless existing_numbers == 0
      person_id = person.id
      errors.add('value', "Number '#{value}' can't be used for #{person.name}. Already used as #{year} #{number_issuer.name} #{discipline.name.downcase} number.")
      person.errors.add('value', "Number '#{value}' can't be used for #{person.name}. Already used as #{year} #{number_issuer.name} #{discipline.name.downcase} number.")
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