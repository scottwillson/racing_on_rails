# frozen_string_literal: true

module Schedule
  # Week in yearly Schedule::Schedule
  class Week
    # Array of Days
    attr_reader :days

    # start_date must be Sunday
    # month is the owning month, and may be the different (next) month
    def initialize(month, start_date)
      @start_date = start_date
      raise(ArgumentError, "Must start on Sunday") if start_date.wday != 0

      @days = []
      (start_date..start_date + 6).each do |date|
        @days << Day.new(month, date)
      end
    end

    def to_s
      "#<Schedule::Week #{@start_date&.strftime('%x')}>"
    end
  end
end
