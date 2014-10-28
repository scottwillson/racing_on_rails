module Competitions
  module Calculations
    module Calculator
      # Set place on array of CalculatorResults
      def self.place(results, rules)
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

      def self.sort_by_points(results, break_ties = false)
        if break_ties
          results.sort do |x, y|
            compare_by_points x, y
          end
        else
          results.sort_by(&:points).reverse
        end
      end

      def self.compare_by_points(x, y)
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

      def self.compare_by_best_place(x, y)
        return 0 if x.scores.nil? && y.scores.nil?
        return 0 if x.scores.size == 0 && y.scores.size == 0

        x_places = (x.scores || []).map(&:numeric_place).sort.reverse
        y_places = (y.scores || []).map(&:numeric_place).sort.reverse

        while x_places.size > 0 || y_places.size > 0 do
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

      def self.compare_by_most_recent_result(x, y)
        return 0 if x.scores.nil? && y.scores.nil?

        x_date = x.scores.map(&:date).max
        y_date = y.scores.map(&:date).max

        if x_date.nil? && y_date.nil?
          0
        elsif x_date.nil?
          1
        elsif y_date.nil?
          -1
        else
          y_date <=> x_date
        end
      end

      # Result places are represented as Strings, even "1", "2", etc. Convert "1" to 1 and DNF, DQ, etc. to Infinity.
      # Infinity convention is handy for sorting.
      def self.numeric_place(result)
        if result.place && result.place.to_i > 0
          result.place.to_i
        else
          Float::INFINITY
        end
      end
    end
  end
end
