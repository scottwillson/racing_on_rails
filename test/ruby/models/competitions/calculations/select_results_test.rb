require_relative "../../../../../app/models/competitions/calculations/calculator"
require_relative "calculations_test"

# :stopdoc:
module Competitions
  module Calculations
    class SelectResultsTest < CalculationsTest
      def test_select_results_empty
        expected = []
        actual = Calculator.select_results([], {})
        assert_equal_results expected, actual
      end

      def test_select_results
        source_results = [
          result(id: 1, event_id: 1, race_id: 1, place: 1, member_from: Date.new(2012), "year" => Date.today.year),
          result(id: 2, event_id: 1, race_id: 1, participant_id: 1, place: nil, member_from: Date.new(2012), member_to: end_of_year, "year" => Date.today.year),
          result(id: 3, event_id: 1, race_id: 1, participant_id: 1, place: "", member_from: Date.new(2012), member_to: end_of_year, "year" => Date.today.year),
          result(id: 4, event_id: 1, race_id: 1, participant_id: 1, place: "DQ", member_from: Date.new(2012), member_to: end_of_year, "year" => Date.today.year),
          result(id: 5, event_id: 1, race_id: 1, participant_id: 1, place: "DNF", member_from: Date.new(2012), member_to: end_of_year, "year" => Date.today.year),
          result(id: 6, event_id: 1, race_id: 1, participant_id: 1, place: "6", member_from: Date.new(2012), member_to: end_of_year, "year" => Date.today.year),
          result(id: 7, event_id: 1, race_id: 1, participant_id: 1, place: "2", member_from: Date.new(2012), member_to: end_of_year, "year" => Date.today.year),
          result(id: 8, event_id: 1, race_id: 1, participant_id: 1, place: "13", member_from: Date.new(2012), member_to: end_of_year, "year" => Date.today.year),
          result(id: 9, event_id: 1, race_id: 1, participant_id: 1, place: "1", member_from: Date.new(2010), member_to: Date.new(2011), "year" => Date.today.year),
          result(id: 10, event_id: 1, race_id: 1, participant_id: 1, place: "1", member_from: Date.new(Date.today.year + 1), member_to: Date.new(Date.today.year + 2), "year" => Date.today.year)
        ]
        expected = [ result(id: 7, event_id: 1, race_id: 1, participant_id: 1, place: "2", member_from: Date.new(2012), member_to: end_of_year, year: Date.today.year)]
        actual = Calculator.select_results(
          source_results,
          results_per_event: UNLIMITED,
          results_per_race: 1,
          dnf: false,
          members_only: true
        )
        assert_equal_results expected, actual
      end

      def test_select_results_with_results_per_event
        source_results = [
          result(id: 1, event_id: 1, race_id: 1, place: 1),
          result(id: 2, event_id: 1, race_id: 1, participant_id: 1, place: nil),
          result(id: 3, event_id: 1, race_id: 1, participant_id: 1, place: ""),
          result(id: 4, event_id: 1, race_id: 1, participant_id: 1, place: "DQ"),
          result(id: 5, event_id: 1, race_id: 1, participant_id: 1, place: "DNF"),
          result(id: 6, event_id: 1, race_id: 1, participant_id: 1, place: "6"),
          result(id: 7, event_id: 1, race_id: 1, participant_id: 1, place: "2"),
          result(id: 8, event_id: 1, race_id: 1, participant_id: 1, place: "13"),
          result(id: 11, event_id: 1, race_id: 1, participant_id: 2, place: "3")
        ]
        expected = [
          result(id: 6, event_id: 1, race_id: 1, participant_id: 1, place: "6"),
          result(id: 7, event_id: 1, race_id: 1, participant_id: 1, place: "2"),
          result(id: 11, event_id: 1, race_id: 1, participant_id: 2, place: "3")
        ]
        actual = Calculator.select_results(
          source_results,
          results_per_event: 2,
          results_per_race: UNLIMITED
        )
        assert_equal_results expected, actual
      end

      def test_select_results_with_results_per_race_1
        source_results = [
          result(id: 1, event_id: 1, race_id: 1, place: 1),
          result(id: 2, event_id: 1, race_id: 1, participant_id: 1, place: nil),
          result(id: 3, event_id: 1, race_id: 1, participant_id: 1, place: ""),
          result(id: 4, event_id: 1, race_id: 1, participant_id: 1, place: "DQ"),
          result(id: 5, event_id: 1, race_id: 1, participant_id: 1, place: "DNF"),
          result(id: 6, event_id: 1, race_id: 1, participant_id: 1, place: "6"),
          result(id: 7, event_id: 1, race_id: 1, participant_id: 1, place: "2"),
          result(id: 8, event_id: 1, race_id: 1, participant_id: 1, place: "13"),
          result(id: 11, event_id: 1, race_id: 1, participant_id: 2, place: "3")
        ]
        expected = [
          result(id: 7, event_id: 1, race_id: 1, participant_id: 1, place: "2"),
          result(id: 11, event_id: 1, race_id: 1, participant_id: 2, place: "3")
        ]
        actual = Calculator.select_results(source_results, results_per_event: 1, results_per_race: 1)
        assert_equal_results expected, actual
      end

      def test_select_results_with_results_per_race_2
        source_results = [
          result(id: 1, event_id: 1, race_id: 1, place: 1),
          result(id: 2, event_id: 1, race_id: 1, participant_id: 1, place: nil),
          result(id: 3, event_id: 1, race_id: 1, participant_id: 1, place: ""),
          result(id: 4, event_id: 1, race_id: 1, participant_id: 1, place: "DQ"),
          result(id: 5, event_id: 1, race_id: 1, participant_id: 1, place: "DNF"),
          result(id: 6, event_id: 1, race_id: 1, participant_id: 1, place: "6"),
          result(id: 7, event_id: 1, race_id: 1, participant_id: 1, place: "2"),
          result(id: 8, event_id: 1, race_id: 1, participant_id: 1, place: "13"),
          result(id: 11, event_id: 1, race_id: 1, participant_id: 2, place: "3")
        ]
        expected = [
          result(id: 7, event_id: 1, race_id: 1, participant_id: 1, place: "2"),
          result(id: 6, event_id: 1, race_id: 1, participant_id: 1, place: "6"),
          result(id: 11, event_id: 1, race_id: 1, participant_id: 2, place: "3")
        ]
        actual = Calculator.select_results(
          source_results, {
            results_per_event: UNLIMITED,
            results_per_race: 2
          }
        )
        assert_equal_results expected, actual
      end

      def test_select_results_should_sort_choose_best_results
        source_results = [
          result(id: 1, event_id: 1, race_id: 1, participant_id: 1, place: "200"),
          result(id: 2, event_id: 1, race_id: 1, participant_id: 1, place: "6"),
          result(id: 3, event_id: 1, race_id: 1, participant_id: 1, place: "2"),
          result(id: 4, event_id: 1, race_id: 1, participant_id: 1, place: "13"),
          result(id: 5, event_id: 1, race_id: 1, participant_id: 1, place: "101"),
        ]
        expected = [
          result(id: 2, event_id: 1, race_id: 1, participant_id: 1, place: "6"),
          result(id: 3, event_id: 1, race_id: 1, participant_id: 1, place: "2")
        ]
        actual = Calculator.select_results(
          source_results,
          results_per_event: 2,
          results_per_race: UNLIMITED
        )
        assert_equal_results expected, actual
      end

      def test_member_in_year
        assert !Calculator.member_in_year?(result(year: 2005))
        assert !Calculator.member_in_year?(result(year: 2005, member_from: Date.new(2001)))
        assert !Calculator.member_in_year?(result(year: 2005, member_from: Date.new(2012)))
        assert !Calculator.member_in_year?(result(year: 2005, member_from: Date.new(2006), member_to: Date.new(2007)))
        assert !Calculator.member_in_year?(result(year: 2005, member_from: Date.new(1999), member_to: Date.new(2004)))
        assert  Calculator.member_in_year?(result(year: 2005, member_from: Date.new(1999), member_to: Date.new(2014)))
      end

      def test_minimum_events_before_event_complete
        source_results = [
          result(id: 1, event_id: 1, race_id: 1, participant_id: 1, place: "1"),
          result(id: 2, event_id: 2, race_id: 2, participant_id: 1, place: "6"),
          result(id: 3, event_id: 2, race_id: 2, participant_id: 2, place: "2"),
          result(id: 4, event_id: 2, race_id: 3, participant_id: 3, place: "13"),
          result(id: 5, event_id: 3, race_id: 3, participant_id: 1, place: "101"),
          result(id: 6, event_id: 3, race_id: 3, participant_id: 2, place: "101")
        ]
        expected = [
          result(id: 1, event_id: 1, race_id: 1, participant_id: 1, place: "1"),
          result(id: 2, event_id: 2, race_id: 2, participant_id: 1, place: "6"),
          result(id: 3, event_id: 2, race_id: 2, participant_id: 2, place: "2"),
          result(id: 4, event_id: 2, race_id: 3, participant_id: 3, place: "13"),
          result(id: 5, event_id: 3, race_id: 3, participant_id: 1, place: "101"),
          result(id: 6, event_id: 3, race_id: 3, participant_id: 2, place: "101")
        ]

        actual = Calculator.select_results(
          source_results,
          completed_events: 3,
          minimum_events: 3,
          members_only: false,
          results_per_event: 1,
          results_per_race: UNLIMITED,
          source_event_ids: [ 1, 2, 3, 4, 5, 6, 7, 8 ]
        )
        assert_equal_results expected, actual
      end

      def test_minimum_events_when_event_complete
        source_results = [
          result(id: 1, event_id: 1, race_id: 1, participant_id: 1, place: "1", date: Date.new(2014, 10, 1)),
          result(id: 2, event_id: 2, race_id: 2, participant_id: 1, place: "6", date: Date.new(2014, 10, 1)),
          result(id: 3, event_id: 2, race_id: 2, participant_id: 2, place: "2", date: Date.new(2014, 10, 1)),
          result(id: 4, event_id: 2, race_id: 3, participant_id: 3, place: "13", date: Date.new(2014, 10, 8)),
          result(id: 5, event_id: 3, race_id: 3, participant_id: 1, place: "101", date: Date.new(2014, 10, 15)),
          result(id: 6, event_id: 4, race_id: 3, participant_id: 2, place: "101", date: Date.new(2014, 10, 21))
        ]
        expected = [
          result(id: 1, event_id: 1, race_id: 1, participant_id: 1, place: "1", date: Date.new(2014, 10, 1)),
          result(id: 2, event_id: 2, race_id: 2, participant_id: 1, place: "6", date: Date.new(2014, 10, 1)),
          result(id: 5, event_id: 3, race_id: 3, participant_id: 1, place: "101", date: Date.new(2014, 10, 15)),
        ]

        actual = Calculator.select_results(
          source_results,
          minimum_events: 3,
          completed_events: 4,
          members_only: false,
          results_per_event: 1,
          results_per_race: UNLIMITED,
          source_event_ids: [ 1, 2, 3, 4 ]
        )
        assert_equal_results expected, actual
      end

      def test_team_membership
        source_results = [
          result(id: 1, event_id: 1, race_id: 1, participant_id: 1, place: "200",
            member_from: Date.new(2012), member_to: end_of_year, year: 2013, team_member: false),

          result(id: 2, event_id: 1, race_id: 1, participant_id: 1, place: "6",
            member_from: Date.new(2012), member_to: end_of_year, year: 2013, team_member: true)
        ]
        actual = Calculator.select_results(source_results, { results_per_event: 1, results_per_race: 1 })
        assert_equal [ 2 ], actual.map(&:id)
      end

      def test_no_team_membership
        source_results = [
          result(id: 1, event_id: 1, race_id: 1, participant_id: 1, place: "200",
            member_from: Date.new(2012), member_to: end_of_year, year: 2013, team_member: false),

          result(id: 2, event_id: 1, race_id: 1, participant_id: 1, place: "6",
            member_from: Date.new(2012), member_to: end_of_year, year: 2013, team_member: true)
        ]
        actual = Calculator.select_results(
          source_results, {
            results_per_event: UNLIMITED,
            results_per_race: UNLIMITED
        })
        assert_equal [ 1, 2 ], actual.map(&:id).sort
      end
    end
  end
end
