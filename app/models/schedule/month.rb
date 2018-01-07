# frozen_string_literal: true

module Schedule
  # Month in yearly Schedule::Schedule
  class Month
    # January, February ...
    attr_reader :name

    # List of Weeks
    attr_reader :weeks

    attr_reader :date

    def initialize(year, month)
      @year = year
      @month = month
      @name = Date::MONTHNAMES[month]
      @name_abbr = Date::ABBR_MONTHNAMES[month]
      @weeks = []
      @date = Date.new(year, month, 1)
      day = monday_of_week(@date)
      end_of_month = Date.new(year, month).to_time.at_end_of_month
      until day.to_time > end_of_month
        @weeks << Week.new(self, day)
        day += 7
      end
    end

    attr_reader :name_abbr

    # Monday of this week's day as a number
    def monday_of_week(day)
      day -= 1 until day.wday == 0
      day
    end

    def add(event)
      day_of_month = event.date.day
      @weeks.each do |week|
        week.days.each do |day|
          if !day.other_month? && day_of_month == day.day_of_month
            day.events << event
            return
          end
        end
      end
    end

    def updated_at
      weeks
        .map(&:days)
        .flatten
        .map(&:events)
        .flatten
        .max_by(&:updated_at)
    end

    def to_s
      "#<Schedule::Month #{name} #{date&.strftime('%x')}>"
    end
  end
end
