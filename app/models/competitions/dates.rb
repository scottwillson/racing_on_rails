# frozen_string_literal: true

module Competitions
  module Dates
    extend ActiveSupport::Concern

    included do
      before_validation :set_date
      validate :valid_dates
    end

    def default_date
      Time.zone.now.beginning_of_year
    end

    def set_date
      unless all_year?
        if source_events.any?
          self.date = source_events.minimum(:date)
        elsif parent
          self.date = parent.start_date
        end
      end

      date
    end

    # Same as +date+. Should always be January 1st
    def start_date
      date
    end

    # Last day of year for +date+
    def end_date
      return Time.zone.local(year).end_of_year if all_year?

      if source_events.present?
        source_events.max.date
      elsif parent
        parent.end_date
      else
        Time.zone.local(year).end_of_year
      end
    end

    # +format+:
    # * :short: 6/7-6/12
    # * :long: 6/7/2010-6/12/2010
    def date_range_s(format = :short)
      if format == :long
        if start_date == end_date
          date.strftime("%-m/%-d/%Y")
        else
          "#{start_date.strftime('%-m/%-d/%Y')}-#{end_date.strftime('%-m/%-d/%Y')}"
        end
      else
        return start_date.year.to_s if all_year?

        start_date_s = "#{start_date.month}/#{start_date.day}"
        if start_date == end_date
          start_date_s
        elsif start_date.month == end_date.month
          "#{start_date_s}-#{end_date.day}"
        else
          "#{start_date_s}-#{end_date.month}/#{end_date.day}"
        end
      end
    end

    def date_range_long_s
      if multiple_days?
        "#{start_date.strftime('%a, %B %-d')} to #{end_date.strftime('%a, %B %-d, %Y')}"
      else
        start_date.strftime("%a, %B %-d")
      end
    end

    def all_year?
      if source_events?
        false
      else
        true
      end
    end

    # Assert start and end dates are first and last days of the year
    def valid_dates
      if all_year?
        errors.add "start_date", "must be January 1st, but was: '#{start_date}'" if start_date.nil? || start_date != start_date.beginning_of_year
        errors.add "end_date", "must be December 31st, but was: '#{end_date}'" if end_date.nil? || end_date != end_date.end_of_year
      end

      if start_date && end_date && start_date.to_date.year != end_date.to_date.year
        errors.add :date, "and end date must be in same year but are #{start_date} and #{end_date}"
      end
    end

    def years(target_year)
      (self.class.select(:date).map(&:year) << year.to_i << target_year.to_i).uniq.sort.reverse
    end
  end
end
