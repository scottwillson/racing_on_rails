class RaceNumber < ActiveRecord::Base
  validates_presence_of :discipline_id
  validates_presence_of :number_issuer_id
  validates_presence_of :racer_id, :if => Proc.new {|race_number| 
    race_number.racer && !race_number.racer.new_record? 
  }
  validates_presence_of :value

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
  
  def after_initialize
    self.discipline = Discipline[:road] unless self.discipline
    self.number_issuer = NumberIssuer.find_by_name(ASSOCIATION.short_name) unless self.number_issuer
    self.year = Date.today.year unless self.year and self.year > 1800
  end
  
  def get_racer_id
    if racer and racer.new_record?
      racer.reload
    end
  end
  
  def validate_year
    self.year > 1800
  end
  
  def to_s
    "<RaceNumber (#{id}) (#{value}) (#{racer_id}) (#{number_issuer_id}) (#{discipline_id}) (#{year})>"
  end
end