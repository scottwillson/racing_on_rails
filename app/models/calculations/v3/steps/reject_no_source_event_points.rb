# frozen_string_literal: true

module Calculations
  module V3
    module Steps
      # Calculations like the Overall BAR. Drop discipline BAR results that don't have points.
      module RejectNoSourceEventPoints
        def self.calculate!(calculator)
          if calculator.rules.source_event_keys.any? && calculator.rules.points_for_place
            calculator.results.each do |result|
              result.source_results.reject! do |source_result|
                source_result.points == 0
              end
            end
          end

          calculator.event_categories
        end
      end
    end
  end
end
