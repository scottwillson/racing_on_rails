# MultiDayEvent with events on several, non-contiguous days
#
# This class doesn't add any special behavior to MultiDayEvent, but it is 
# convential to separate events like stage races from series like the 
# Cross Crusade
#
# By convention, only SingleDayEvents have Standings and Results -- WeeklySeries do not. 
# Final standings like Overall GC are associated with the last day's SingleDayEvent.
class Series < MultiDayEvent

  def Series.find_all_by_year(year)
    logger.debug("Series.find_all_by_year(year)")
    start_of_year = Date.new(year, 1, 1)
    end_of_year = Date.new(year, 12, 31)
    return Series.find(
      :all,
      :conditions => ["date >= ? and date <= ?", start_of_year, end_of_year],
      :order => "date"
    )
  end

  def friendly_class_name
    "Series"
  end
end