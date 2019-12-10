# frozen_string_literal: true

module Calculations
  module V3
    module Steps
      module RejectCalculatedEvents
        def self.calculate!(calculator)
          return calculator.event_categories if calculator.rules.source_event_keys.any?

          calculator.unrejected_source_results.each do |source_result|
            next unless source_result.event.calculated?
            next if !calculator.rules.weekday_events? && series_overall?(source_result.event)
            next if calculator.rules.calculations_events.include?(source_result.event) && !source_result.event.zero_points?

            source_result.reject :calculated
          end

          reject_calculated_results_in_different_discipline calculator

          calculator.event_categories
        end

        def self.reject_calculated_results_in_different_discipline(calculator)
          return if calculator.rules.disciplines.empty?

          calculator.results.each do |result|
            result.source_results.reject! do |source_result|
              source_result.rejection_reason == :calculated &&
                !source_result.discipline.in?(calculator.rules.disciplines)
            end
          end
        end

        def self.series_overall?(event)
          date = event.date
          end_date = event.end_date
          child_dates = if event.calculated? && event.parent
                          event.parent.days
                        else
                          event.days
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
