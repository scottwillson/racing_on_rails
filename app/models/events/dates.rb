require_dependency "human_date/parser"

module Events
  module Dates
    extend ActiveSupport::Concern

    included do
      before_save :set_end_date
    end

    module ClassMethods
      # Return list of every year that has at least one event
      def find_all_years
        years = [ ::RacingAssociation.current.effective_year ] +
        connection.select_values(
          "select distinct extract(year from date) from events"
        ).map(&:to_i)
        years = years.uniq.sort

        if years.size == 1
          years
        else
          ((years.first)..(years.last)).to_a.reverse
        end
      end
    end

    def default_date
      if parent.present?
        parent.date
      else
        Time.zone.today
      end
    end

    # Format for schedule page primarily
    def short_date
      return '' unless date
      prefix = ' ' if date.month < 10
      suffix = ' ' if date.day < 10
      "#{prefix}#{date.month}/#{date.day}#{suffix}"
    end

    def date_range_s(format = :short)
      if format == :long
        date.strftime('%-m/%-d/%Y')
      else
        "#{date.month}/#{date.day}"
      end
    end

    def date_range_long_s=(value)
      # Ignore
    end

    def date_range_long_s
      date.to_s :long_with_week_day
    end

    def human_date
      if @human_date
        @human_date
      elsif date
        date.to_s(:long_with_week_day)
      else
        nil
      end
    end

    # Handle 7/25/2013, 7-25-2013, 7/25/13, 7-25-13
    def human_date=(value)
      @human_date = value.try(:strip)
      set_date_from_human_date
    end

    def set_date_from_human_date
      parsed_date = HumanDate::Parser.new.parse(@human_date)

      if parsed_date
        self.date = parsed_date
      else
        errors.add :human_date
      end
    end

    # +date+
    def start_date
      date
    end

    def start_date=(date)
      self.date = date
    end

    def end_date
      set_end_date
      self[:end_date]
    end

    def year
      return nil unless date
      date.year
    end

    def multiple_days?
      end_date > start_date
    end

    def set_end_date
      if self[:end_date].nil? || date != self[:end_date]
        self.end_date = date
      end
    end

    # Does nothing. Allows us to treat Events and MultiDayEvents the same.
    def update_date
    end
  end
end
