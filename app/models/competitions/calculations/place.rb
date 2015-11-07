module Competitions
  module Calculations
    module Place
      # Set place on array of CalculatorResults
      def apply_place(results, rules)
        results = apply_preliminary(results, rules)

        place = 1
        previous_result = nil

        sort_by_points(results, rules[:break_ties], rules[:most_points_win]).map.with_index do |result, index|
          if index == 0
            place = 1
          elsif result.points != previous_result.points
            place = index + 1
          elsif rules[:break_ties] && (!result.tied || !previous_result.tied)
            place = index + 1
          end
          previous_result = result
          merge_struct result, place: place
        end
      end

      def sort_by_points(results, break_ties, most_points_win)
        if break_ties
          results.sort do |x, y|
            compare_by_points x, y
          end
        elsif most_points_win
          results.sort_by(&:points).reverse
        else
          results.sort_by(&:points)
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

          diff = compare(x_place, y_place)
          return diff if diff != 0
        end
        0
      end

      # Who has the most recent result?
      def compare_by_most_recent_result(x, y)
        return 0 if none?(x.scores, y.scores)

        # Sort scores by most recent date, lowest place
        # "Best" scores last because #pop returns the last item
        x_scores = x.scores.sort_by { |s| [ s.date, -s.numeric_place ] }
        y_scores = y.scores.sort_by { |s| [ s.date, -s.numeric_place ] }

        while any?(x_scores, y_scores) do
          x_score = x_scores.pop
          y_score = y_scores.pop

          return 0 if none?(x_score, y_score)

          diff = compare_by_date(x_score, y_score)
          return diff if diff != 0

          # Most recent race same for both riders, try to break tie by place in that race
          diff = x_score.numeric_place <=> y_score.numeric_place
          return diff if diff != 0
        end

        0
      end

      def compare_by_date(x, y)
        # One participant has more results than the other?
        if x.nil?
          return 1
        elsif y.nil?
          return -1
        end

        # One of the results is more recent?
        y.date <=> x.date
      end

      def none?(x, y)
        !any?(x, y)
      end

      def any?(x, y)
        # Nil-check
        (x && x.size > 0) || (y && y.size > 0)
      end

      def compare(x, y)
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
