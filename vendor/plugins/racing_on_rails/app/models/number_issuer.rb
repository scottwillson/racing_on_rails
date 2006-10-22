class NumberIssuer < ActiveRecord::Base
  validates_presence_of :name
  
  has_many :race_numbers
  
  def to_s
    "<NumberIssuer #{name}>"
  end
end