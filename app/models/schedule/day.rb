module Schedule
  # Day on a year's Schedule::Schedule
  class Day

    # Array of SingleDayEvents
    attr_accessor :events
    
    attr_reader :month

    def initialize(month, date)
      @date = date
      @month = month
      @events = []
    end

    def other_month?
      @date.month != @month.date.month
    end

    # 1-31
    def day_of_month
      @date.day
    end
    
    # Sunday, Monday, ... Saturday
    def day_of_week
    	Date::DAYNAMES[@date.wday]
    end

    def to_s
      "#<Schedule::Day #{@date.strftime('%x') if @date}>"
    end
  end
end
