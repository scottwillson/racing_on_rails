# frozen_string_literal: true

module Calculations
  module V3
    module Steps
      module RejectWeekdayEvents
        def self.calculate!(calculator)
          return calculator.event_categories if calculator.rules.weekday_events?

          calculator.unrejected_source_results.each do |source_result|
            if weekday?(source_result.event) &&
               !source_result.event.series_overall? &&
               !omnium_or_stage_race?(source_result.event.parent)

              source_result.reject :weekday
            end
          end

          calculator.event_categories
        end

        def self.weekday?(event)
          raise(ArgumentError, "Event date required to check for weekday") unless event.date

          !(event.date.saturday? || event.date.sunday?)
        end

        def self.omnium_or_stage_race?(parent_event)
          parent_event &&
            parent_event.end_date != parent_event.date &&
            parent_event.children.map(&:date).uniq.size == (parent_event.end_date - parent_event.date).to_i + 1
        end
      end
    end
  end
end
