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

          diff = compare_by_most_recent_result(x, y)
          return diff if diff != 0

          # Special case. Tie cannot be broken.
          x.tied = true
          y.tied = true
          0
        end

        def self.compare_by_best_place(x, y)
          return 0 if none?(x.placed_source_results_with_points, y.placed_source_results_with_points)

          x_places = places(x.placed_source_results_with_points)
          y_places = places(y.placed_source_results_with_points)

          while any?(x_places, y_places)
            x_place = x_places.pop
            y_place = y_places.pop

            diff = compare(x_place, y_place)
            return diff if diff != 0
          end
          0
        end

        # Who has the most recent result?
        def self.compare_by_most_recent_result(x, y)
          return 0 if none?(x.placed_source_results_with_points, y.placed_source_results_with_points)

          # Sort source_results by most recent date, lowest place
          # "Best" source_results last because #pop returns the last item
          x_source_results = x.placed_source_results_with_points.sort_by { |s| [s.date, -s.numeric_place] }
          y_source_results = y.placed_source_results_with_points.sort_by { |s| [s.date, -s.numeric_place] }

          while any?(x_source_results, y_source_results)
            x_source_result = x_source_results.pop
            y_source_result = y_source_results.pop

            return 0 if none?(x_source_result, y_source_result)

            diff = compare_by_date(x_source_result, y_source_result)
            return diff if diff != 0

            # Most recent race same for both riders, try to break tie by place in that race
            diff = x_source_result.numeric_place <=> y_source_result.numeric_place
            return diff if diff != 0
          end

          0
        end

        def self.compare_by_date(x, y)
          raise(ArgumentError, "source_result.date required to check for most rescent result") unless x.date && y.date

          # One result is a DNF, DQ, etc. Sort it last. It can't be "most recent".
          if !x.points? || !y.points?
            return x.date <=> y.date
          end

          # One of the results is more recent?
          y.date <=> x.date
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
