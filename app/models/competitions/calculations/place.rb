module Competitions
  module Calculations
    module Place
      # Set place on array of CalculatorResults
      def apply_place(results, rules)
        place = 1
        previous_result = nil

        sort_by_points(results, rules[:break_ties]).map.with_index do |result, index|
          if index == 0
            place = 1
          elsif result.points < previous_result.points
            place = index + 1
          elsif rules[:break_ties] && (!result.tied || !previous_result.tied)
            place = index + 1
          end

          previous_result = result
          merge_struct result, place: place
        end
      end

      def sort_by_points(results, break_ties = false)
        if break_ties
          results.sort do |x, y|
            compare_by_points x, y
          end
        else
          results.sort_by(&:points).reverse
        end
      end

      def compare_by_points(x, y)
        diff = y.points <=> x.points
        return diff if diff != 0

        diff = compare_by_best_place(x, y)
        return diff if diff != 0

        diff = compare_by_most_recent_result(x, y)
        return diff if diff != 0

        # Special-case. Tie cannot be broken.
        x.tied = true
        y.tied = true
        0
      end

      def compare_by_best_place(x, y)
        return 0 if none?(x.scores, y.scores)

        x_places = places(x.scores)
        y_places = places(y.scores)

        while any?(x_places, y_places) do
          x_place = x_places.pop
          y_place = y_places.pop

          if x_place.nil? && y_place.nil?
            return 0
          elsif x_place.nil?
            return 1
          elsif y_place.nil?
            return -1
          else
            diff = x_place <=> y_place
            return diff if diff != 0
          end
        end
        0
      end

      # Who has the most recent result?
      def compare_by_most_recent_result(x, y)
        return 0 if none?(x.scores, y.scores)

        x_date = x.scores.map(&:date).max
        y_date = y.scores.map(&:date).max

        if x_date.nil? && y_date.nil?
          0
        elsif x_date.nil?
          1
        elsif y_date.nil?
          -1
        else
          if (y_date <=> x_date) == 0
            # Most recent race same for both riders, so break tie by place in that race
            compare_by_most_recent_result_place x, y
          else
            y_date <=> x_date
          end
        end
      end
      
      def compare_by_most_recent_result_place(x, y)
        x.scores.max_by(&:date).numeric_place <=> y.scores.max_by(&:date).numeric_place
      end
      
      def none?(x, y)
        !any?(x, y)
      end
      
      def any?(x, y)
        # Nil-check
        (x || y) && (x.size > 0 || y.size > 0)
      end
      
      def places(scores)
        (scores || []).map(&:numeric_place).sort.reverse
      end

      # Result places are represented as Strings, even "1", "2", etc. Convert "1" to 1 and DNF, DQ, etc. to Infinity.
      # Infinity convention is handy for sorting.
      def numeric_place(result)
        if result.place && result.place.to_i > 0
          result.place.to_i
        else
          Float::INFINITY
        end
      end
    end
  end
end
