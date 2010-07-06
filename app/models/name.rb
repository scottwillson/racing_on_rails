# "Historical" names. "In +year+ 2007, Team name was Safeway." People and Teams can have Names.
# Used on results pages.
# Created by Person or Team for new Result in new year and name changes from previous year. 
# Used to handle Person name changes after marriages, as well. See Names::Nameable.
class Name < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :year
  validates_uniqueness_of :name, :scope => [ :year, :nameable_type, :nameable_id ]
  validates_uniqueness_of :nameable_id, :scope => [ :year, :nameable_type ]

  def date=(value)
    self.year = value.year
  end
  
  def to_s
    "#<Name #{name} #{year} #{nameable_type} #{nameable_id}>"
  end
end
