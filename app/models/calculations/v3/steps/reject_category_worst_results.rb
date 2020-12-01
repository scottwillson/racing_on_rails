# frozen_string_literal: true

module Calculations
  module V3
    module Steps
      # Specific rule for PDX STXC and GPCD: drop worst 10% from "highest" categories
      module RejectCategoryWorstResults
        def self.calculate!(calculator)
          return calculator.event_categories unless calculator.rules.place_by == "place"

          calculator.event_categories.each do |category|
            category.results
                    .reject(&:rejected?)
                    .select { |result| result.source_result_ability > 0 && result.source_result_ability < 3 }
                    .group_by(&:source_result_ability_group).each_value do |category_results|
              size = category_results.size
              next if size < 10

              cutoff_index = (size * 0.9).ceil - 1
              cutoff_place = category_results[cutoff_index].numeric_place
              next if cutoff_place == Float::INFINITY

              category_results.select { |result| result.numeric_place > cutoff_place }
                              .each { |result| result.reject(:category_worst_result) }
            end
          end

          calculator.event_categories
        end
      end
    end
  end
end
