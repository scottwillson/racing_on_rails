# Year-long competition that derive there standings from other Events:
# BAR, Ironman
class Competition < Event

  def initialize(attributes = nil)
    super
    if self.date.month != 1 or self.date.day != 1
      self.date = Date.new(Date.today.year)    
    end
  end

  # Same as +date+. Should always be Januaray 1st
  def start_date
    date
  end
  
  # Last day of year for +date+
  def end_date
    Date.new(date.year, 12, 31)
  end
  
  # Assert start and end dates are first and last days of the year
  def valid_dates
    if !start_date or start_date.month != 1 or start_date.day != 1
      errors.add("start_date", "Start date must be January 1st")
    end
    if !end_date or end_date.month != 12 or end_date.day != 31
      errors.add("end_date", "End date must be December 31st")
    end
  end

  def destroy_standings
    for s in standings(true)
      s.destroy
    end
  end

  def to_s
    "<self.class #{id} #{name} #{start_date} #{end_date}>"
  end
end
