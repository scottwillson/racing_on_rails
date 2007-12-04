# TODO: +new_record+ and +attributes+ are somewhat redundant
class Duplicate < ActiveRecord::Base
  serialize :new_racer
  validates_presence_of :new_racer

  has_and_belongs_to_many :racers
end