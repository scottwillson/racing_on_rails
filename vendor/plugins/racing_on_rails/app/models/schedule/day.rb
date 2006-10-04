module Schedule
  # Day on a year's Schedule::Schedule
  class Day

    # Array of SingleDayEvents
    attr_accessor :events

    def initialize(month, date)
      @date = date
      @previous_month = month > date.month
      @events = []
    end

    def previous_month?
      @previous_month
    end

    # 1-31
    def day_of_month
      @date.day
    end
    
    # Sunday, Monday, ... Saturday
    def day_of_week
    	Date::DAYNAMES[@date.wday]
    end
  end
end
