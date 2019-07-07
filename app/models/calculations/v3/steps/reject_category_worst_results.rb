# frozen_string_literal: true

module Calculations
  module V3
    module Steps
      # Specific rule for PDX STXC and GPCD: drop worst 10% from "highest" categories
      module RejectWorstResults
        def self.calculate!(calculator)
          return calculator.event_categories unless calculator.rules.place_by == "place"

          calculator.event_categories.each do |category|
            category.results
              .group_by(&:source_result_ability)
              .map do |category_ability, category_results|
                if category_ability < 3
                  size = category_results.size
                  keep = (size * 0.9).floor
                  category_results[keep, size - keep].each do |result|
                    result.reject(:category_worst_result)
                  end
                end
              end
            end

          calculator.event_categories
        end
      end
    end
  end
end
