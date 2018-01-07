# frozen_string_literal: true

# "Historical" names. "In +year+ 2007, Team name was Safeway." People and Teams can have Names.
# +year+ means: "name until this year". If the River City team was 'Safeway' until 2008, it
# would have one Name with a year of 2007.
# 2005: Safeway
# 2006: Safeway
# 2007: Safeway
# 2008: River City
# 2009: River City
# 2010: River City
# Used on results pages.
# Created by Person or Team for new Result in new year and name changes from previous year.
# Used to handle Person name changes after marriages, as well. See Names::Nameable.
class Name < ActiveRecord::Base
  validates :name, presence: true
  validates :year, presence: true
  validates :name, uniqueness: { scope: %i[year nameable_type nameable_id] }
  validates :nameable_id, uniqueness: { scope: %i[year nameable_type] }

  belongs_to :nameable, polymorphic: true

  def date=(value)
    self.year = value.year
  end

  def to_s
    "#<Name #{name} #{year} #{nameable_type} #{nameable_id}>"
  end
end
