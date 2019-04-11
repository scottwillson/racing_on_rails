# frozen_string_literal: true

module Calculations
  module V3
    module Steps
      module RejectWeekdayEvents
        def self.calculate!(calculator)
          return calculator.event_categories if calculator.rules.weekday_events?

          calculator.source_results.each do |source_result|
            if weekday?(source_result.event)
              source_result.reject :weekday
            end
          end

          calculator.event_categories
        end

        def self.weekday?(event)
          raise(ArgumentError, "Event date required to check for weekday") unless event.date

          !(event.date.saturday? || event.date.sunday?)
        end
      end
    end
  end
end
