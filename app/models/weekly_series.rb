# By convention, only SingleDayEvents have Standings and Results -- WeeklySeries do not. 
# Final standings like Overall GC are associated with the last day's SingleDayEvent.
class WeeklySeries < Series
  
  # TODO Is this duplicaqted from Ruby core and standard lib?
  WEEKDAYS = ['Su', 'M', 'Tu', 'W', 'Th', 'F', 'Sa'] unless defined?(WEEKDAYS)

  # Only used by UpcomingEvents, could replace with days_of_week(date_range)
  attr_accessor :days_of_week

  def days_of_week
    @days_of_week = @days_of_week || []
  end
  
  def earliest_day_of_week
    days_of_week.min {|a, b| a.wday <=> b.wday } 
  end
  
  # Formatted list. Examples:
  # * Tueday PIR: Tu
  # * Track classes: M, W, F
  def days_of_week_s
    distinct_days = []
    for day in days_of_week
      distinct_days << day.wday unless distinct_days.include?(day.wday)
    end

    case distinct_days.size
    when 0
      ''
    when 1
      Time::RFC2822_DAY_NAME[distinct_days.first]
    else
      distinct_days.sort!
      distinct_days.collect {|day| WEEKDAYS[day]}.join('/')
    end
  end

  def friendly_class_name
    "Weekly Series"
  end

  def to_s
    "<#{self.class} #{id} #{discipline} #{name} #{date} #{events.size} #{earliest_day_of_week}>"
  end
end