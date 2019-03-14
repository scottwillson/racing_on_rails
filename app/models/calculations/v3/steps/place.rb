# frozen_string_literal: true

# rubocop:disable Naming/UncommunicativeMethodParamName
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

          diff = compare_by_best_place(x, y)
          return diff if diff != 0

          # Special-case. Tie cannot be broken.
          x.tied = true
          y.tied = true
          0
        end

        def self.compare_by_best_place(x, y)
          return 0 if none?(x.source_results, y.source_results)

          x_places = places(x.source_results)
          y_places = places(y.source_results)

          while any?(x_places, y_places)
            x_place = x_places.pop
            y_place = y_places.pop

            diff = compare(x_place, y_place)
            return diff if diff != 0
          end
          0
        end

        def self.none?(x, y)
          !any?(x, y)
        end

        def self.any?(x, y)
          # Nil-check
          x.present? || y.present?
        end

        def self.compare(x, y)
          if x.nil? && y.nil?
            0
          elsif x.nil?
            1
          elsif y.nil?
            -1
          else
            x <=> y
          end
        end

        # Sort places highest (worst) to lowest (best) so caller can use #pop
        def self.places(source_results)
          (source_results || []).map(&:numeric_place).sort.reverse
        end
      end
    end
  end
end
# rubocop:enable Naming/UncommunicativeMethodParamName
