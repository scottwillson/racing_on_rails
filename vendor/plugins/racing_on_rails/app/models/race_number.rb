class RaceNumber < ActiveRecord::Base
  validates_presence_of :discipline_id
  validates_presence_of :name
  validates_presence_of :number_issuer_id
  validates_presence_of :racer_id

  belongs_to :discipline
  belongs_to :number_issuer
  belongs_to :racer
end