# frozen_string_literal: true

module Calculations
  module V3
    module Steps
      # Calculations that pass-through/reuse the source results points
      module RejectNoPoints
        def self.calculate!(calculator)
          return calculator.event_categories if calculator.rules.points_for_place

          calculator.unrejected_source_results.each do |source_result|
            if source_result.points == 0
              source_result.reject :no_points
            end
          end

          calculator.event_categories
        end
      end
    end
  end
end
