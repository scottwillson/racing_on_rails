# frozen_string_literal: true

module Calculations
  module V3
    module Steps
      module Place
        def self.calculate!(calculator)
          calculator.event_categories.each do |category|
            place = 1
            previous_result = nil

            sort_by_points(category.results).map.with_index do |result, index|
              next if category.rejected?

              if index == 0
                place = 1
              elsif result.points != previous_result.points
                place = index + 1
              elsif !result.tied || !previous_result.tied
                place = index + 1
              end
              previous_result = result
              result.place = place.to_s
            end
          end
        end

        def self.sort_by_points(results)
          results.sort do |x, y|
            compare_by_points x, y
          end
        end

        def self.compare_by_points(x, y)
          diff = y.points <=> x.points
          return diff if diff != 0

          # Special-case. Tie cannot be broken.
          x.tied = true
          y.tied = true
          0
        end
      end
    end
  end
end
