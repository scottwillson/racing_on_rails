require_relative "../../../../../app/models/competitions/calculations/calculator"
require_relative "calculations_test"

# :stopdoc:
# TODO remove noisy member setup
module Competitions
  module Calculations
    class CalculatorTest < CalculationsTest
      def test_calculate_with_no_source_results
        assert_equal [], Calculator.calculate([])
      end

      def test_calculate_with_one_source_result
        source_results = [ { "event_id" => 1, "participant_id" => 1, "place" => "1", "member_from" => Date.new(2012), member_to: end_of_year, "year" => Date.today.year } ]
        expected = [
          result(place: 1, participant_id: 1, points: 1, scores: [ { numeric_place: 1, participant_id: 1, points: 1 } ])
        ]
        actual = Calculator.calculate(source_results)
        assert_equal_results expected, actual
      end

      def test_calculate_with_many_source_results
        source_results = [
          { event_id: 1, participant_id: 1, place: 1, member_from: Date.new(2012), member_to: end_of_year, year: Date.today.year },
          { event_id: 1, participant_id: 2, place: 2, member_from: Date.new(2012), member_to: end_of_year, year: Date.today.year }
        ]
        expected = [
          result(place: 1, participant_id: 1, points: 1, scores: [ { numeric_place: 1, participant_id: 1, points: 1 } ]),
          result(place: 1, participant_id: 2, points: 1, scores: [ { numeric_place: 2, participant_id: 2, points: 1 } ])
        ]
        actual = Calculator.calculate(source_results)
        assert_equal_results expected, actual
      end

      def test_calculate_team_results
        source_results = [
          { race_id: 1, participant_id: 3, place: 1, member_from: Date.new(2012), member_to: end_of_year, year: Date.today.year },
          { race_id: 1, participant_id: 4, place: 1, member_from: Date.new(2012), member_to: end_of_year, year: Date.today.year },
          { race_id: 1, participant_id: 1, place: 2, member_from: Date.new(2012), member_to: end_of_year, year: Date.today.year },
          { race_id: 1, participant_id: 2, place: 2, member_from: Date.new(2012), member_to: end_of_year, year: Date.today.year }
        ]
        expected = [
          result(place: 3, participant_id: 1, points: 4, scores: [ { numeric_place: 2, participant_id: 1, points: 4 } ]),
          result(place: 3, participant_id: 2, points: 4, scores: [ { numeric_place: 2, participant_id: 2, points: 4 } ]),
          result(place: 1, participant_id: 3, points: 10, scores: [ { numeric_place: 1, participant_id: 3, points: 10 } ]),
          result(place: 1, participant_id: 4, points: 10, scores: [ { numeric_place: 1, participant_id: 4, points: 10 } ])
        ]
        actual = Calculator.calculate(source_results, point_schedule: [ 20, 8, 3 ])
        assert_equal_results expected, actual
      end

      def test_calculate_team_results_best_3_for_event
        source_results = [
          { event_id: 1, race_id: 1, participant_id: 1, place: 107 },
          { event_id: 1, race_id: 1, participant_id: 1, place: 7 },
          { event_id: 1, race_id: 1, participant_id: 2, place: 1 },
          { event_id: 1, race_id: 1, participant_id: 1, place: 2 },
          { event_id: 1, race_id: 1, participant_id: 2, place: 8 },
          { event_id: 1, race_id: 1, participant_id: 1, place: 3 },
          { event_id: 1, race_id: 1, participant_id: 1, place: 4 },
          { event_id: 2, race_id: 2, participant_id: 1, place: 1 }
        ]
        expected = [
          result(place: 1, participant_id: 1, points: 34, scores: [
            { numeric_place: 1, participant_id: 1, points: 10 },
            { numeric_place: 2, participant_id: 1, points: 9 },
            { numeric_place: 3, participant_id: 1, points: 8 },
            { numeric_place: 4, participant_id: 1, points: 7 }
          ]),
          result(place: 2, participant_id: 2, points: 13, scores: [
            { numeric_place: 1, participant_id: 2, points: 10 },
            { numeric_place: 8, participant_id: 2, points: 3 }
          ])
        ]
        actual = Calculator.calculate(
          source_results,
          point_schedule: [ 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ],
          results_per_event: 3,
          results_per_race: UNLIMITED,
          members_only: false
        )
        assert_equal_results expected, actual
      end

      def test_calculate_should_ignore_non_scoring_results
        source_results = [
          { event_id: 1, participant_id: 1, place: "", member_from: Date.new(2012), member_to: end_of_year },
          { event_id: 1, participant_id: 2, place: "DNS", member_from: Date.new(2012), member_to: end_of_year },
          { event_id: 1, participant_id: 3, place: "DQ", member_from: Date.new(2012), member_to: end_of_year },
          { event_id: 1, participant_id: 4, place: nil, member_from: Date.new(2012), member_to: end_of_year }
        ]
        expected = []
        actual = Calculator.calculate(source_results)
        assert_equal_results expected, actual
      end

      def test_calculate_ignore_non_starters
        source_results = [
          { event_id: 1, participant_id: 1, place: "", member_from: Date.new(2012), member_to: end_of_year },
          { event_id: 1, participant_id: 2, place: "DNS", member_from: Date.new(2012), member_to: end_of_year },
          { event_id: 1, participant_id: 3, place: "DQ", member_from: Date.new(2012), member_to: end_of_year },
          { event_id: 1, participant_id: 4, place: nil, member_from: Date.new(2012), member_to: end_of_year }
        ]
        expected = []
        actual = Calculator.calculate(source_results)
        assert_equal_results expected, actual
      end

      def test_calculate_with_multiple_events_and_people
        source_results = [
          { id: 1, event_id: 1, race_id: 1, participant_id: 1, place: 1, member_from: Date.new(2012), member_to: end_of_year, "year" => Date.today.year },
          { id: 2, event_id: 1, race_id: 1, participant_id: 2, place: 2, member_from: Date.new(2012), member_to: end_of_year, "year" => Date.today.year },
          { id: 3, event_id: 1, race_id: 1, participant_id: 2, place: 20, member_from: Date.new(2012), member_to: end_of_year, "year" => Date.today.year },
          { id: 4, event_id: 2, race_id: 2, participant_id: 1, place: "DNF", member_from: Date.new(2012), member_to: end_of_year, "year" => Date.today.year }
        ]
        expected = [
          result(place: 1, participant_id: 1, points: 2, scores: [ { numeric_place: 1, source_result_id: 1, points: 1, participant_id: 1 }, { numeric_place: Float::INFINITY, source_result_id: 4, points: 1, participant_id: 1 } ]),
          result(place: 2, participant_id: 2, points: 1, scores: [ { numeric_place: 2, source_result_id: 2, points: 1, participant_id: 2 } ])
        ]
        actual = Calculator.calculate(source_results, dnf_points: 1)
        assert_equal_results expected, actual
      end

      # Cross Crusade team competition
      def test_calculate_most_points_win
        source_results = [
          { event_id: 1, participant_id: 1, place: 2, race_id: 1 },
          { event_id: 1, participant_id: 1, place: 4, race_id: 1 },
          { event_id: 1, participant_id: 2, place: 5, race_id: 1 }
        ]
        expected = [
          result(place: 1, participant_id: 1, points: 2.0, scores: [ { numeric_place: 2, participant_id: 1, points: 2.0 } ]),
          result(place: 2, participant_id: 2, points: 5.0, scores: [ { numeric_place: 5, participant_id: 2, points: 5.0 } ])
        ]
        actual = Calculator.calculate(
          source_results,
          members_only: false,
          most_points_win: false,
          point_schedule: [ 1, 2, 3, 4, 5 ],
          results_per_event: 10,
          results_per_race: 1
        )
        assert_equal_results expected, actual
      end

      # Cross Crusade team competition
      def test_missing_result_penalty
        source_results = [
          { event_id: 1, participant_id: 10, place: 2, race_id: 100 },
          { event_id: 1, participant_id: 10, place: 4, race_id: 100 },
          { event_id: 1, participant_id: 20, place: 5, race_id: 100 },
          { event_id: 1, participant_id: 10, place: 5, race_id: 200 }
        ]
        expected = [
          result(place: 1, participant_id: 10, points: 107.0, scores: [
            { numeric_place: 2, participant_id: 10, points: 2.0 },
            { numeric_place: 5, participant_id: 10, points: 5.0 },
            { numeric_place: 100, participant_id: 10, points: 100.0 }
          ]),
          result(place: 2, participant_id: 20, points: 205.0, scores: [
            { numeric_place: 5, participant_id: 20, points: 5.0 },
            { numeric_place: 100, participant_id: 20, points: 200 }
          ])
        ]
        actual = Calculator.calculate(
          source_results,
          completed_events: 1,
          members_only: false,
          missing_result_penalty: 100,
          most_points_win: false,
          point_schedule: [ 1, 2, 3, 4, 5 ],
          results_per_event: 3,
          results_per_race: 1
        )
        assert_equal_results expected, actual
      end

      def test_map_to_scores
        expected = [ Struct::CalculatorScore.new(nil, 5, 4, 1, 1, nil) ]
        source_results = [ result(id: 1, race_id: 3, participant_id: 4, place: 5, member_from: Date.new(2012)) ]
        actual = Calculator.map_to_scores(source_results, {})
        assert_equal expected, actual
      end

      def test_map_to_scores_empty
        expected = []
        actual = Calculator.map_to_scores([], {})
        assert_equal expected, actual
      end

      def test_map_to_results
        scores = [ Struct::CalculatorScore.new(nil, 2, 3, 4, 5) ]
        expected = [ result(participant_id: 3, points: 4, scores: [ { numeric_place: 2, participant_id: 3, points: 4, source_result_id: 5 } ]) ]
        actual = Calculator.map_to_results(scores, {})
        assert_equal_results expected, actual
      end

      def test_map_to_results_empty
        expected = []
        actual = Calculator.map_to_results([], {})
        assert_equal expected, actual
      end

      def test_map_hashes_to_results
        expected = [ Struct::CalculatorResult.new.tap { |r| r.place = 3 } ]
        actual = Calculator.map_hashes_to_results([{ place: 3 }])
        assert_equal expected, actual
      end

      def test_place_bonus_points
        assert_equal 6, Calculator.place_bonus_points(result(place: "1"), place_bonus: [ 6, 3, 1 ])
        assert_equal 1, Calculator.place_bonus_points(result(place: "3"), place_bonus: [ 6, 3, 1 ])
        assert_equal 0, Calculator.place_bonus_points(result(place: "4"), place_bonus: [ 6, 3, 1 ])
        assert_equal 0, Calculator.place_bonus_points(result(place: "DNF"), place_bonus: [ 6, 3, 1 ])
        assert_equal 0, Calculator.place_bonus_points(result(place: "DQ"), place_bonus: [ 6, 3, 1 ])
      end

      def test_source_events
        source_results = [
          { event_id: 1, participant_id: 1, place: 1 },
          { event_id: 2, participant_id: 2, place: 2 }
        ]
        expected = [
          result(place: 1, participant_id: 2, points: 1, scores: [ { numeric_place: 2, participant_id: 2, points: 1 } ])
        ]
        actual = Calculator.calculate(source_results, source_event_ids: [ 2 ], members_only: false)
        assert_equal_results expected, actual
      end

      def test_ignore_empty_source_events
        source_results = [
          { event_id: 1, participant_id: 1, place: 1 },
          { event_id: 2, participant_id: 2, place: 2 }
        ]
        actual = Calculator.calculate(source_results, source_event_ids: [], members_only: false)
        assert_equal [], actual
      end

      def test_set_preliminary
        rules = { minimum_events: 2, members_only: false, completed_events: 3 }
        source_results = [
          { "place" => "1", "participant_id" => 1, "event_id" => 1, "race_id" => 1 },
          { "place" => "2", "participant_id" => 2, "event_id" => 1, "race_id" => 1 },
          { "place" => "3", "participant_id" => 3, "event_id" => 1, "race_id" => 1 },
          { "place" => "1", "participant_id" => 1, "event_id" => 2, "race_id" => 2 },
          { "place" => "2", "participant_id" => 2, "event_id" => 2, "race_id" => 2 },
          { "place" => "3", "participant_id" => 1, "event_id" => 3, "race_id" => 3 }
        ]
        expected = [
          result(place: 1, participant_id: 1, points: 3, preliminary: false, scores: [
             { numeric_place: 1, participant_id: 1, points: 1 },
             { numeric_place: 1, participant_id: 1, points: 1 },
             { numeric_place: 3, participant_id: 1, points: 1 }
          ]),
          result(place: 2, participant_id: 2, points: 2, preliminary: false, scores: [
             { numeric_place: 2, participant_id: 2, points: 1 },
             { numeric_place: 2, participant_id: 2, points: 1 }
          ]),
          result(place: 3, participant_id: 3, points: 1, preliminary: true, scores: [
             { numeric_place: 3, participant_id: 3, points: 1 }
          ]),
        ]
        actual = Calculator.calculate(source_results, rules)
        assert_equal_results expected, actual
      end

      def test_set_preliminary_before_minimum_events
        rules = { minimum_events: 3, members_only: false, break_ties: true, completed_events: 2 }
        source_results = [
          { "place" => "1", "participant_id" => 1, "event_id" => 1, "race_id" => 1 },
          { "place" => "2", "participant_id" => 2, "event_id" => 1, "race_id" => 1 },
          { "place" => "3", "participant_id" => 3, "event_id" => 1, "race_id" => 1 },
          { "place" => "1", "participant_id" => 1, "event_id" => 2, "race_id" => 2 },
          { "place" => "2", "participant_id" => 2, "event_id" => 2, "race_id" => 2 },
        ]
        expected = [
          result(place: 1, participant_id: 1, points: 2, preliminary: nil, scores: [
             { numeric_place: 1, participant_id: 1, points: 1 },
             { numeric_place: 1, participant_id: 1, points: 1 },
          ]),
          result(place: 2, participant_id: 2, points: 2, preliminary: nil, scores: [
             { numeric_place: 2, participant_id: 2, points: 1 },
             { numeric_place: 2, participant_id: 2, points: 1 }
          ]),
          result(place: 3, participant_id: 3, points: 1, preliminary: nil, scores: [
             { numeric_place: 3, participant_id: 3, points: 1 }
          ]),
        ]
        actual = Calculator.calculate(source_results, rules)
        assert_equal_results expected, actual
      end

      def test_set_preliminary_when_event_complete
        rules = { minimum_events: 2, members_only: false, completed_events: 3, source_event_ids: [ 1, 2, 3 ] }
        source_results = [
          { "place" => "1", "participant_id" => 1, "event_id" => 1, "race_id" => 1 },
          { "place" => "2", "participant_id" => 2, "event_id" => 1, "race_id" => 1 },
          { "place" => "3", "participant_id" => 3, "event_id" => 1, "race_id" => 1 },
          { "place" => "1", "participant_id" => 1, "event_id" => 2, "race_id" => 2 },
          { "place" => "2", "participant_id" => 2, "event_id" => 2, "race_id" => 2 },
          { "place" => "3", "participant_id" => 1, "event_id" => 3, "race_id" => 3 }
        ]
        expected = [
          result(place: 1, participant_id: 1, points: 3, preliminary: nil, scores: [
             { numeric_place: 1, participant_id: 1, points: 1 },
             { numeric_place: 1, participant_id: 1, points: 1 },
             { numeric_place: 3, participant_id: 1, points: 1 }
          ]),
          result(place: 2, participant_id: 2, points: 2, preliminary: nil, scores: [
             { numeric_place: 2, participant_id: 2, points: 1 },
             { numeric_place: 2, participant_id: 2, points: 1 }
          ])
        ]
        actual = Calculator.calculate(source_results, rules)
        assert_equal_results expected, actual
      end
    end
  end
end
