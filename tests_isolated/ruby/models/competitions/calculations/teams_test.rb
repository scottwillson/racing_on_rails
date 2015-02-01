require_relative "../../../../../app/models/competitions/calculations/calculator"
require_relative "calculations_test"

# :stopdoc:
module Competitions
  module Calculations
    class TeamsTest < CalculationsTest
      def test_apply_team_sizes_empty
        assert_equal [], Calculator.apply_team_sizes([], {})
      end

      def test_apply_team_sizes
        expected = [
          result(place: 1, race_id: 1, team_size: 2),
          result(place: 1, race_id: 1, team_size: 2),
          result(place: 2, race_id: 1, team_size: 1),
          result(place: 3, race_id: 1, team_size: 3),
          result(place: 3, race_id: 1, team_size: 3),
          result(place: 3, race_id: 1, team_size: 3),
          result(place: 1, race_id: 2, team_size: 1)
        ]
        results = [
          result(place: 1, race_id: 1),
          result(place: 1, race_id: 1),
          result(place: 2, race_id: 1),
          result(place: 3, race_id: 1),
          result(place: 3, race_id: 1),
          result(place: 3, race_id: 1),
          result(place: 1, race_id: 2)
        ]
        assert_equal expected, Calculator.apply_team_sizes(results, {})
      end

      # Don't mistake ties for teams
      def test_apply_team_sizes_not_team_event
        expected = [
          result(place: 1, race_id: 1, team_size: 1, participant_id: 1, field_size: 5),
          result(place: 2, race_id: 1, team_size: 1, participant_id: 2, field_size: 5),
          result(place: 2, race_id: 1, team_size: 1, participant_id: 3, field_size: 5),
          result(place: 3, race_id: 1, team_size: 1, participant_id: 4, field_size: 5),
          result(place: 4, race_id: 1, team_size: 1, participant_id: 5, field_size: 5),
          result(place: 1, race_id: 2, team_size: 1, participant_id: 6, field_size: 1)
        ]
        results = [
          result(place: 1, race_id: 1, participant_id: 1, field_size: 5),
          result(place: 2, race_id: 1, participant_id: 2, field_size: 5),
          result(place: 2, race_id: 1, participant_id: 3, field_size: 5),
          result(place: 3, race_id: 1, participant_id: 4, field_size: 5),
          result(place: 4, race_id: 1, participant_id: 5, field_size: 5),
          result(place: 1, race_id: 2, participant_id: 6, field_size: 1)
        ]
        assert_equal_results expected, Calculator.apply_team_sizes(results, {})
      end

      def test_apply_team_sizes_not_team_event_small_event
        expected = [
          result(place: 1, race_id: 1, team_size: 3, participant_id: 1, field_size: 3),
          result(place: 1, race_id: 1, team_size: 3, participant_id: 2, field_size: 3),
          result(place: 1, race_id: 1, team_size: 3, participant_id: 3, field_size: 3),
        ]
        results = [
          result(place: 1, race_id: 1, participant_id: 1, field_size: 3),
          result(place: 1, race_id: 1, participant_id: 2, field_size: 3),
          result(place: 1, race_id: 1, participant_id: 3, field_size: 3),
        ]
        assert_equal_results expected, Calculator.apply_team_sizes(results, {})

        expected = [
          result(place: 1, race_id: 1, team_size: 3, participant_id: 1, field_size: 4),
          result(place: 1, race_id: 1, team_size: 3, participant_id: 2, field_size: 4),
          result(place: 1, race_id: 1, team_size: 3, participant_id: 3, field_size: 4),
          result(place: 2, race_id: 1, team_size: 1, participant_id: 4, field_size: 4),
        ]
        results = [
          result(place: 1, race_id: 1, participant_id: 1, field_size: 4),
          result(place: 1, race_id: 1, participant_id: 2, field_size: 4),
          result(place: 1, race_id: 1, participant_id: 3, field_size: 4),
          result(place: 2, race_id: 1, participant_id: 4, field_size: 4),
        ]
        assert_equal_results expected, Calculator.apply_team_sizes(results, {})

        expected = [
          result(place: 1, race_id: 1, team_size: 2, participant_id: 1, field_size: 1),
          result(place: 1, race_id: 1, team_size: 2, participant_id: 2, field_size: 1),
          result(place: 1, race_id: 2, team_size: 1, participant_id: 1, field_size: 1),
          result(place: 2, race_id: 3, team_size: 1, participant_id: 2, field_size: 4),
          result(place: 3, race_id: 4, team_size: 1, participant_id: 3, field_size: 4),
          result(place: 4, race_id: 4, team_size: 1, participant_id: 4, field_size: 4),
        ]
        results = [
          result(place: 1, race_id: 1, participant_id: 1, field_size: 1),
          result(place: 1, race_id: 1, participant_id: 2, field_size: 1),
          result(place: 1, race_id: 2, participant_id: 1, field_size: 1),
          result(place: 2, race_id: 3, participant_id: 2, field_size: 4),
          result(place: 3, race_id: 4, participant_id: 3, field_size: 4),
          result(place: 4, race_id: 4, participant_id: 4, field_size: 4),
        ]
        assert_equal_results expected, Calculator.apply_team_sizes(results, {})
      end
    end
  end
end
