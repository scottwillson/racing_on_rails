module RacingOnRails
  module Schedule
    class Month

      attr_reader :name, :weeks
  
      def initialize(year, month)
        @year = year
        @month = month
        @name = Date::MONTHNAMES[month]
        @weeks = []
        day = Date.new(year, month, 1)
        day = monday_of_week(day)
        until day.month > month || day.year > year
          @weeks << Week.new(month, day)
          day = day + 7
        end
      end

      def monday_of_week(day)
        until day.wday == 0
          day = day - 1
        end
        return day
      end
  
      def add(event)
        day_of_month = event.date.day
        for week in @weeks
          for day in week.days
            if !day.previous_month? && day_of_month == day.day_of_month
              day.events << event
              return
            end
          end
        end
      end
    end
  end
end
    