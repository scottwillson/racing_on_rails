class RaceNumber < ActiveRecord::Base
  validates_presence_of :discipline_id
  validates_presence_of :number_issuer_id
  validates_presence_of :racer_id
  validates_presence_of :value
  validates_presence_of :year

  belongs_to :discipline
  belongs_to :number_issuer
  belongs_to :racer
  
  def RaceNumber.find_by_value_and_event(value, event)
    RaceNumber.find(
      :first, 
      :conditions => ['value=? and discipline_id=? and number_issuer_id=? and year=?',
                      value, event.discipline.id, event.number_issuer.id, event.date.year]
    )
  end
end