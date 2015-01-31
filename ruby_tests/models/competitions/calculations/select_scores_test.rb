require_relative "../../../../../app/models/competitions/calculations/calculator"
require_relative "calculations_test"

# :stopdoc:
module Competitions
  module Calculations
    class SelectScoresTest < CalculationsTest
      def test_reject_scores_greater_than_maximum_events
        scores = [
          score(numeric_place: 10, participant_id: 1, points: 1),
          score(numeric_place: 1, participant_id: 2, points: 10),
          score(numeric_place: 1, participant_id: 1, points: 10),
          score(numeric_place: 2, participant_id: 2, points: 9),
          score(numeric_place: 3, participant_id: 2, points: 8),
          score(numeric_place: 1, participant_id: 3, points: 10),
          score(numeric_place: 1, participant_id: 1, points: 10)
        ]
        expected = [
          score(numeric_place: 1, participant_id: 2, points: 10),
          score(numeric_place: 1, participant_id: 1, points: 10),
          score(numeric_place: 2, participant_id: 2, points: 9),
          score(numeric_place: 1, participant_id: 3, points: 10),
          score(numeric_place: 1, participant_id: 1, points: 10)
        ]
        actual = Calculator.reject_scores_greater_than_maximum_events(scores, maximum_events: 2)
        assert_equal_scores expected, actual
      end

      def test_reject_scores_keep_upgrades
        scores = [
          score(numeric_place: 10, participant_id: 1, points: 1, upgrade: true),
          score(numeric_place: 1, participant_id: 1, points: 10),
        ]
        expected = [
          score(numeric_place: 10, participant_id: 1, points: 1, upgrade: true),
          score(numeric_place: 1, participant_id: 1, points: 10),
        ]
        actual = Calculator.select_scores(scores, maximum_events: 1)
        assert_equal_scores expected, actual
      end
    end
  end
end

