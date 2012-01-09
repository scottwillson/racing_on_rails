# Any 'party' that issues a set of numbers. Usually, this is the racing Association, 
# but large events like stage races have their own set of numbers, as do 
# series like the Cross Crusade
class NumberIssuer < ActiveRecord::Base
  validates_presence_of :name
  
  has_many :race_numbers
  
  def association?
    name == RacingAssociation.current.short_name
  end

  def to_s
    "#<NumberIssuer #{name}>"
  end
end