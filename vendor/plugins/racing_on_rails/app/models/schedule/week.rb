module Schedule
  class Week

    attr_reader :days

    # start_date must be Sunday
    # month is the owning month, and may be the different (next) month
    def initialize(month, start_date)
      if start_date.wday != 0
        raise(ArgumentError, "Must start on Sunday")
      end
      @days = []
      for date in start_date..start_date + 6
        @days << Day.new(month, date)    
      end
    end
  end
end
