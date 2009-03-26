class HistoricalName < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :year
  validates_uniqueness_of :name, :scope => [:year, :team_id]
  validates_uniqueness_of :team_id, :scope => :year

  def date=(value)
    self.year = value.year
  end
end
