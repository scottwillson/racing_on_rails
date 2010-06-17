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
