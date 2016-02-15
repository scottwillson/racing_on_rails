require_relative "../../../../../app/models/competitions/calculations/calculator"
require_relative "calculations_test"

# :stopdoc:
module Competitions
  module Calculations
    class PointsTest < CalculationsTest
      def test_points
        assert_equal 1, Calculator.points(result(place: 20), break_ties: false)
      end

      def test_points_with_point_schedule
        rules = { point_schedule: [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ] }
        assert_equal 0, Calculator.points(result(place: "20"), rules)
        assert_equal 1, Calculator.points(result(place: "15"), rules)
        assert_equal 14, Calculator.points(result(place: 2), rules)
        assert_equal 0, Calculator.points(result(place: ""), rules)
        assert_equal 0, Calculator.points(result(place: nil), rules)
        assert_equal 0, Calculator.points(result(place: "DNF"), rules)
        assert_equal 0, Calculator.points(result(place: "DQ"), rules)
      end

      def test_points_with_point_schedule_hash
        rules = {
          point_schedule: {
            0 => [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ],
            1 => [ 8, 5, 3 ]
          }
        }
        assert_equal 13, Calculator.points(result(event_id: 0, place: "3"), rules)
        assert_equal 3, Calculator.points(result(event_id: 1, place: "3"), rules)
      end

      def test_points_considers_team_size
        rules = { point_schedule: [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ] }
        assert_equal 0, Calculator.points(result(place: "20", team_size: 2), rules)
        assert_equal 0.5, Calculator.points(result(place: "15", team_size: 2), rules)
        assert_equal 7, Calculator.points(result(place: 2, team_size: 2), rules)
        assert_equal 0, Calculator.points(result(place: "", team_size: 2), rules)
        assert_equal 0, Calculator.points(result(place: nil, team_size: 2), rules)
        assert_equal 0, Calculator.points(result(place: "DNF", team_size: 2), rules)
        assert_equal 0, Calculator.points(result(place: "DQ", team_size: 2), rules)
        assert_equal 0, Calculator.points(result(place: "20", team_size: 3), rules)
        assert_in_delta 0.333, Calculator.points(result(place: "15", team_size: 3), rules)
        assert_in_delta 4.666, Calculator.points(result(place: 2, team_size: 3), rules)
        assert_equal 0, Calculator.points(result(place: "", team_size: 3), rules)
        assert_equal 0, Calculator.points(result(place: nil, team_size: 3), rules)
        assert_equal 0, Calculator.points(result(place: "DNF", team_size: 3), rules)
        assert_equal 0, Calculator.points(result(place: "DQ", team_size: 3), rules)
      end

      def test_points_considers_multiplier
        assert_equal 27, Calculator.points(result(place: "7", multiplier: 3), point_schedule: [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ])
        assert_equal 0, Calculator.points(result(place: "7", multiplier: 0), point_schedule: [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ])
      end

      def test_points_considers_multiplier_and_team_size
        assert_in_delta 9.333, 0.1, Calculator.points(
          result(place: "2", multiplier: 2, team_size: 3),
          point_schedule: [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ]
        )
      end

      def test_points_considers_field_size
        assert_equal 9, Calculator.points(result(place: "7", field_size: 74), point_schedule: [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ], field_size_bonus: true)
        assert_equal 13.5, Calculator.points(result(place: "7", field_size: 75), point_schedule: [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ], field_size_bonus: true)
        assert_equal 13.5, Calculator.points(result(place: "7", field_size: 76), point_schedule: [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ], field_size_bonus: true)
      end

      def test_points_ignore_field_size_if_multipler
        assert_equal 27, Calculator.points(result(place: "7", multiplier: 3, field_size: 74), point_schedule: [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ], field_size_bonus: true)
        assert_equal 27, Calculator.points(result(place: "7", multiplier: 3, field_size: 75), point_schedule: [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ], field_size_bonus: true)
        assert_equal 27, Calculator.points(result(place: "7", multiplier: 3, field_size: 76), point_schedule: [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ], field_size_bonus: true)
      end

      def test_points_use_source_result_points
        assert_equal 11, Calculator.points(
          result(place: "2", multiplier: 2, points: 11),
          point_schedule: [ 3, 2, 1 ],
          use_source_result_points: true
        )
      end

      def test_points_upgrade
        assert_equal 5.5, Calculator.points(
          result(place: "2", points: 11, upgrade: true),
          maximum_upgrade_points: 100,
          point_schedule: [ 3, 2, 1 ],
          use_source_result_points: false
        )
      end

      def test_calculate_double_points_for_last_event
        rules = { double_points_for_last_event: true, end_date: Date.new(2014, 10), point_schedule: [ 15, 14, 13 ], members_only: false }
        source_results = [
          { "event_id" => 1, "race_id" => 1, "participant_id" => 1, "place" => "1", "date" => Date.new(2014, 9) },
          { "event_id" => 2, "race_id" => 2, "participant_id" => 1, "place" => "2", "date" => Date.new(2014, 10) }
        ]
        expected = [
          result(place: 1, participant_id: 1, points: 43.0, scores: [
             { numeric_place: 1, participant_id: 1, points: 15.0, date: Date.new(2014, 9), event_id: 1 },
             { numeric_place: 2, participant_id: 1, points: 28.0, date: Date.new(2014, 10), event_id: 2 }
          ])
        ]
        actual = Calculator.calculate(source_results, rules)
        assert_equal_results expected, actual
      end

      def test_double_points_and_maximum_events
        rules = { double_points_for_last_event: true, maximum_events: 5, end_date: Date.new(2014, 7, 9), point_schedule: [ 100, 70, 50, 40, 36, 32, 28, 24, 20, 16, 15, 14, 13, 12, 11 ], members_only: false }
        source_results = [
          { "place" => "10", "date" => Date.new(2014, 6, 4), "event_id" => 1, "race_id" => 1, "participant_id" => 1 },
          { "place" => "9", "date" => Date.new(2014, 6, 11), "event_id" => 2, "race_id" => 2, "participant_id" => 1 },
          { "place" => "3", "date" => Date.new(2014, 6, 18), "event_id" => 3, "race_id" => 3, "participant_id" => 1 },
          { "place" => "4", "date" => Date.new(2014, 6, 25), "event_id" => 4, "race_id" => 4, "participant_id" => 1 },
          { "place" => "2", "date" => Date.new(2014, 7, 2), "event_id" => 5, "race_id" => 5, "participant_id" => 1 },
          { "place" => "1", "date" => Date.new(2014, 7, 9), "event_id" => 6, "race_id" => 6, "participant_id" => 1 }
        ]
        expected = [
          result(place: 1, participant_id: 1, points: 380, scores: [
             { numeric_place: 1, participant_id: 1, points: 200, date: Date.new(2014, 7, 9), event_id: 6 },
             { numeric_place: 2, participant_id: 1, points: 70, date: Date.new(2014, 7, 2), event_id: 5 },
             { numeric_place: 3, participant_id: 1, points: 50, date: Date.new(2014, 6, 18), event_id: 3 },
             { numeric_place: 4, participant_id: 1, points: 40, date: Date.new(2014, 6, 25), event_id: 4 },
             { numeric_place: 9, participant_id: 1, points: 20, date: Date.new(2014, 6, 11), event_id: 2 }
          ])
        ]
        actual = Calculator.calculate(source_results, rules)
        assert_equal_results expected, actual
      end

      def test_last_event_should_be_more_points
        rules = { double_points_for_last_event: true, maximum_events: 5, end_date: Date.new(2014, 7, 9), point_schedule: [ 100, 70, 50, 40, 36, 32, 28, 24, 20, 16, 15, 14, 13, 12, 11 ], members_only: false }
        source_results = [
          { "place" => "1", "date" => Date.new(2014, 6, 4), "event_id" => 1, "race_id" => 1, "participant_id" => 1 },
          { "place" => "3", "date" => Date.new(2014, 6, 11), "event_id" => 2, "race_id" => 2, "participant_id" => 1 },
          { "place" => "1", "date" => Date.new(2014, 6, 18), "event_id" => 3, "race_id" => 3, "participant_id" => 1 },
          { "place" => "1", "date" => Date.new(2014, 6, 25), "event_id" => 4, "race_id" => 4, "participant_id" => 1 },
          { "place" => "1", "date" => Date.new(2014, 7, 2), "event_id" => 5, "race_id" => 5, "participant_id" => 1 },
          { "place" => "2", "date" => Date.new(2014, 7, 9), "event_id" => 6, "race_id" => 6, "participant_id" => 1 }
        ]
        expected = [
          result(place: 1, participant_id: 1, points: 540, scores: [
             { numeric_place: 1, participant_id: 1, points: 100, date: Date.new(2014, 6, 4), event_id: 1 },
             { numeric_place: 1, participant_id: 1, points: 100, date: Date.new(2014, 6, 18), event_id: 3 },
             { numeric_place: 1, participant_id: 1, points: 100, date: Date.new(2014, 6, 25), event_id: 4 },
             { numeric_place: 1, participant_id: 1, points: 100, date: Date.new(2014, 7, 2), event_id: 5 },
             { numeric_place: 2, participant_id: 1, points: 140, date: Date.new(2014, 7, 9), event_id: 6 },
          ])
        ]
        actual = Calculator.calculate(source_results, rules)
        assert_equal_results expected, actual
      end

      def test_double_points_for_last_event
        assert_equal 6, Calculator.points(
          result(place: "3", date: Date.new(2015, 4, 2)),
          end_date: Date.new(2015, 4, 2),
          point_schedule: [ 7, 5, 3 ],
          double_points_for_last_event: true
        )
      end

      def test_points_schedule_from_field_size
        assert_equal 26, Calculator.points(
          result(place: "4", field_size: 29),
          points_schedule_from_field_size: true
        )

        assert_equal 75, Calculator.points(
          result(place: "1", field_size: 75),
          points_schedule_from_field_size: true
        )

        assert_equal 1, Calculator.points(
          result(place: "75", field_size: 75),
          points_schedule_from_field_size: true
        )
      end

      def test_place_bonus
        assert_equal 26, Calculator.points(
          result(place: "4", field_size: 29),
          place_bonus: [ 7, 5, 3 ],
          points_schedule_from_field_size: true
        )

        assert_equal 82, Calculator.points(
          result(place: "1", field_size: 75),
          place_bonus: [ 7, 5, 3 ],
          points_schedule_from_field_size: true
        )

        assert_equal 1, Calculator.points(
          result(place: "75", field_size: 75),
          place_bonus: [ 7, 5, 3 ],
          points_schedule_from_field_size: true
        )

        assert_equal 76, Calculator.points(
          result(place: "3", field_size: 75),
          place_bonus: [ 7, 5, 3 ],
          points_schedule_from_field_size: true
        )
      end
    end
  end
end
