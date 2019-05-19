# frozen_string_literal: true

module Calculations
  module V3
    module Steps
      module RejectWeekdayEvents
        def self.calculate!(calculator)
          return calculator.event_categories if calculator.rules.weekday_events?

          calculator.unrejected_source_results.each do |source_result|
            next if !weekday?(source_result.event) ||
                    omnium_or_stage_race?(source_result.event.parent) ||
                    omnium_or_stage_race?(source_result.event) ||
                    series_overall?(source_result.event)

            source_result.reject :weekday
          end

          calculator.event_categories
        end

        def self.weekday?(event)
          raise(ArgumentError, "Event date required to check for weekday") unless event.date

          !(event.date.saturday? || event.date.sunday?)
        end

        def self.omnium_or_stage_race?(event)
          event &&
            event.end_date != event.date &&
            event.children.map(&:date).uniq.size == (event.end_date - event.date).to_i + 1
        end

        def self.series_overall?(event)
          date = event.date
          end_date = event.end_date
          child_dates = if event.calculated? && event.parent
                          event.parent.children.map(&:date).uniq
                        else
                          event.children.map(&:date).uniq
                        end

          event.calculated? &&
            end_date != date &&
            (end_date - date).to_i > child_dates.size &&
            end_date == child_dates.max
        end
      end
    end
  end
end
