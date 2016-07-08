require_relative "../../../../../app/models/competitions/calculations/calculator"
require_relative "calculations_test"

# :stopdoc:
module Competitions
  module Calculations
    class SelectScoresTest < CalculationsTest
      def test_reject_scores_greater_than_maximum_events
        scores = [
          score(numeric_place: 10, participant_id: 1, points: 3, event_id: 1),
          score(numeric_place: 1, participant_id: 2, points: 10, event_id: 1),
          score(numeric_place: 1, participant_id: 1, points: 10, event_id: 2),
          score(numeric_place: 2, participant_id: 2, points: 9, event_id: 2),
          score(numeric_place: 3, participant_id: 2, points: 8, event_id: 3),
          score(numeric_place: 1, participant_id: 3, points: 10, event_id: 3),
          score(numeric_place: 1, participant_id: 1, points: 10, event_id: 3),
          score(numeric_place: 11, participant_id: 1, points: 2, event_id: 4),
          score(numeric_place: 12, participant_id: 1, points: 1, event_id: 5),
        ]
        expected = [
          score(numeric_place: 1, participant_id: 2, points: 10, event_id: 1),
          score(numeric_place: 1, participant_id: 1, points: 10, event_id: 2),
          score(numeric_place: 2, participant_id: 2, points: 9, event_id: 2),
          score(numeric_place: 1, participant_id: 3, points: 10, event_id: 3),
          score(numeric_place: 1, participant_id: 1, points: 10, event_id: 3)
        ]
        actual = Calculator.reject_scores_greater_than_maximum_events(scores, maximum_events: 2)
        assert_equal_scores expected, actual
      end

      def test_multiple_results_per_event
        scores = [
          score(numeric_place: 1, participant_id: 1, points: 9, event_id: 1),
          score(numeric_place: 2, participant_id: 1, points: 8, event_id: 1),
          score(numeric_place: 3, participant_id: 1, points: 7, event_id: 1),
          score(numeric_place: 1, participant_id: 1, points: 9, event_id: 2),
          score(numeric_place: 2, participant_id: 2, points: 8, event_id: 2),
          score(numeric_place: 3, participant_id: 3, points: 7, event_id: 2),
          score(numeric_place: 2, participant_id: 1, points: 8, event_id: 3),
          score(numeric_place: 3, participant_id: 1, points: 7, event_id: 3),
        ]
        expected = [
          score(numeric_place: 1, participant_id: 1, points: 9, event_id: 1),
          score(numeric_place: 2, participant_id: 1, points: 8, event_id: 1),
          score(numeric_place: 2, participant_id: 2, points: 8, event_id: 2),
          score(numeric_place: 2, participant_id: 1, points: 8, event_id: 3),
          score(numeric_place: 3, participant_id: 1, points: 7, event_id: 3),
          score(numeric_place: 3, participant_id: 1, points: 7, event_id: 1),
          score(numeric_place: 3, participant_id: 3, points: 7, event_id: 2),
        ]
        actual = Calculator.reject_scores_greater_than_maximum_events(scores, maximum_events: 2)
        assert_equal_scores expected, actual
      end

      def test_apply_results_per_event_to_oldest_results_first
        scores = [
          score(numeric_place: 1, points: 30, participant_id: 1, date: Date.new(2015, 9, 13), event_id: 1),
          score(numeric_place: 2, points: 29, participant_id: 1, date: Date.new(2015, 9, 13), event_id: 1),
          score(numeric_place: 2, points: 29, participant_id: 1, date: Date.new(2015, 9, 13), event_id: 1),
          score(numeric_place: 1, points: 30, participant_id: 1, date: Date.new(2015, 9, 19), event_id: 2),
          score(numeric_place: 1, points: 30, participant_id: 1, date: Date.new(2015, 9, 19), event_id: 2),
          score(numeric_place: 2, points: 29, participant_id: 1, date: Date.new(2015, 9, 19), event_id: 2),
          score(numeric_place: 1, points: 30, participant_id: 1, date: Date.new(2015, 10, 3), event_id: 3),
          score(numeric_place: 1, points: 30, participant_id: 1, date: Date.new(2015, 10, 3), event_id: 3),
          score(numeric_place: 2, points: 29, participant_id: 1, date: Date.new(2015, 10, 3), event_id: 3),
          score(numeric_place: 3, points: 28, participant_id: 1, date: Date.new(2015, 10, 18), event_id: 4),
          score(numeric_place: 3, points: 28, participant_id: 1, date: Date.new(2015, 10, 18), event_id: 4),
          score(numeric_place: 1, points: 30, participant_id: 1, date: Date.new(2015, 10, 25), event_id: 5),
          score(numeric_place: 1, points: 30, participant_id: 1, date: Date.new(2015, 10, 25), event_id: 5),
          score(numeric_place: 2, points: 29, participant_id: 1, date: Date.new(2015, 10, 25), event_id: 5),
          score(numeric_place: 1, points: 30, participant_id: 1, date: Date.new(2015, 10, 31), event_id: 6),
          score(numeric_place: 2, points: 29, participant_id: 1, date: Date.new(2015, 10, 31), event_id: 6),
          score(numeric_place: 2, points: 29, participant_id: 1, date: Date.new(2015, 10, 31), event_id: 6),
        ]
        expected = [
          score(numeric_place: 1, points: 30, participant_id: 1, date: Date.new(2015, 9, 19), event_id: 2),
          score(numeric_place: 1, points: 30, participant_id: 1, date: Date.new(2015, 9, 19), event_id: 2),
          score(numeric_place: 2, points: 29, participant_id: 1, date: Date.new(2015, 9, 19), event_id: 2),
          score(numeric_place: 1, points: 30, participant_id: 1, date: Date.new(2015, 10, 3), event_id: 3),
          score(numeric_place: 1, points: 30, participant_id: 1, date: Date.new(2015, 10, 3), event_id: 3),
          score(numeric_place: 2, points: 29, participant_id: 1, date: Date.new(2015, 10, 3), event_id: 3),
          score(numeric_place: 1, points: 30, participant_id: 1, date: Date.new(2015, 10, 25), event_id: 5),
          score(numeric_place: 1, points: 30, participant_id: 1, date: Date.new(2015, 10, 25), event_id: 5),
          score(numeric_place: 2, points: 29, participant_id: 1, date: Date.new(2015, 10, 25), event_id: 5),
          score(numeric_place: 1, points: 30, participant_id: 1, date: Date.new(2015, 10, 31), event_id: 6),
          score(numeric_place: 2, points: 29, participant_id: 1, date: Date.new(2015, 10, 31), event_id: 6),
          score(numeric_place: 2, points: 29, participant_id: 1, date: Date.new(2015, 10, 31), event_id: 6),
        ]
        actual = Calculator.reject_scores_greater_than_maximum_events(scores, maximum_events: 4)
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
