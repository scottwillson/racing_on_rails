class Competition < Event

  def initialize(attributes = nil)
    super
    if self.date.month != 1 or self.date.day != 1
      self.date = Date.new(Date.today.year)    
    end
  end

  def start_date
    date
  end
  
  def end_date
    Date.new(date.year, 12, 31)
  end
  
  def valid_dates
    if !start_date or start_date.month != 1 or start_date.day != 1
      errors.add("start_date", "Start date must be January 1st")
    end
    if !end_date or end_date.month != 12 or end_date.day != 31
      errors.add("end_date", "End date must be December 31st")
    end
  end

  def set_all_last_updated_dates(date)
    for s in standings(true)
      # s.save!
    end
  end

  def to_s
    "<self.class #{id} #{name} #{start_date} #{end_date}>"
  end
end
