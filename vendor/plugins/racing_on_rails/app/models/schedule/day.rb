module Schedule
  class Day

    attr_reader :events
    attr_writer :events

    def initialize(month, date)
      @date = date
      @previous_month = month > date.month
      @events = []
    end

    def previous_month?
      @previous_month
    end

    def day_of_month
      @date.day
    end

    def day_of_week
    	Date::DAYNAMES[@date.wday]
    end
  end
end
