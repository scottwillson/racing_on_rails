# frozen_string_literal: true

module Calculations
  module V3
    module Steps
      module RejectCalculatedEvents
        def self.calculate!(calculator)
          return calculator.event_categories if calculator.rules.source_event_keys.any?

          calculator.unrejected_source_results.each do |source_result|
            if source_result.event.calculated? && (calculator.rules.weekday_events? || !series_overall?(source_result.event))
              source_result.reject :calculated
            end
          end

          calculator.event_categories
        end

        def self.series_overall?(event)
          pp event
          date = event.date
          end_date = event.end_date
          child_dates = event.children.map(&:date).uniq

          x = event.calculated? &&
            end_date != date &&
            (end_date - date).to_i > child_dates.size &&
            end_date == child_dates.max

            puts x
            x
        end
      end
    end
  end
end
