# frozen_string_literal: true

module Calculations
  module V3
    module Steps
      module AssignPoints
        def self.calculate!(calculator)
          calculator.event_categories.reject(&:rejected?).each do |category|
            category.results.reject(&:rejected?).each do |result|
              result.source_results.reject(&:rejected?).each do |source_result|
                source_result.points = points_for_place(source_result, calculator.rules.points_for_place)
                source_result.points = source_result.points * last_event_multiplier(source_result, calculator.rules)
              end
            end
          end

          calculator.event_categories
        end

        def self.points_for_place(source_result, points_for_place)
          return 1 unless points_for_place
          return 0 unless source_result.placed?

          points_for_place[source_result.numeric_place - 1] || 0
        end

        def self.last_event_multiplier(source_result, rules)
          if rules.double_points_for_last_event? && last_event?(source_result)
            2
          else
            1
          end
        end

        def self.last_event?(source_result)
          raise(ArgumentError, "source_result.date required to check for last event") unless source_result.date
          raise(ArgumentError, "source_result.last_event_date required to check for last event") unless source_result.last_event_date

          source_result.date == source_result.last_event_date
        end
      end
    end
  end
end
