require_relative "../../../../../app/models/competitions/calculations/calculator"
require_relative "calculations_test"

# :stopdoc:
module Competitions
  module Calculations
    class CalculatorTest < CalculationsTest
      def test_place
        source_results = [ result(points: 1) ]
        expected = [ result(place: 1, points: 1) ]
        actual = Calculator.apply_place(source_results, break_ties: false)
        assert_equal_results expected, actual
      end

      def test_place_by_points
        source_results = [ result(points: 1), result(points: 10), result(points: 2) ]
        expected = [ result(place: 1, points: 10), result(place: 2, points: 2), result(place: 3, points: 1) ]
        actual = Calculator.apply_place(source_results, break_ties: false, most_points_win: true)
        assert_equal expected, actual.sort_by(&:place)
      end

      def test_place_by_points_dont_break_ties
        source_results = [ result(points: 1), result(points: 10), result(points: 2), result(points: 2), result(points: 2) ]
        expected = [ result(place: 1, points: 10), result(place: 2, points: 2), result(place: 2, points: 2), result(place: 2, points: 2), result(place: 5, points: 1) ]
        actual = Calculator.apply_place(source_results, break_ties: false, most_points_win: true)
        assert_equal expected.sort_by(&:place), actual.sort_by(&:place)
      end

      def test_place_by_points_break_ties
        source_results = [
          result(points: 1,  scores: [ { numeric_place: 5, date: Date.new(2012) } ]),
          result(points: 10, scores: [ { numeric_place: 1, date: Date.new(2012) } ]),
          result(points: 2,  scores: [ { numeric_place: 3, date: Date.new(2011) } ]),
          result(points: 2,  scores: [ { numeric_place: 3, date: Date.new(2010) } ]),
          result(points: 2,  scores: [ { numeric_place: 3, date: Date.new(2012) } ])
        ]
        expected = [
          result(place: 1, points: 10, scores: [ { numeric_place: 1, date: Date.new(2012) } ]),
          result(place: 2, points: 2,  scores: [ { numeric_place: 3, date: Date.new(2012) } ]),
          result(place: 3, points: 2,  scores: [ { numeric_place: 3, date: Date.new(2011) } ]),
          result(place: 4, points: 2,  scores: [ { numeric_place: 3, date: Date.new(2010) } ]),
          result(place: 5, points: 1,  scores: [ { numeric_place: 5, date: Date.new(2012) } ])
        ]
        actual = Calculator.apply_place(source_results, break_ties: true)
        assert_equal expected, actual.sort_by(&:place)
      end

      def test_place_by_points_unbreakable_tie
        source_results = [
          result(points: 1, participant_id: 10, scores: [ { numeric_place: 5, date: Date.new(2012) } ]),
          result(points: 10, participant_id: 20, scores: [ { numeric_place: 1, date: Date.new(2012) } ]),
          result(points: 2, participant_id: 30, scores: [ { numeric_place: 3, date: Date.new(2011) } ]),
          result(points: 2, participant_id: 30, scores: [ { numeric_place: 3, date: Date.new(2011) } ]),
          result(points: 2, participant_id: 50, scores: [ { numeric_place: 3, date: Date.new(2012) } ])
        ]
        expected = [
          result(place: 1, participant_id: 20, points: 10, tied: nil, scores: [ { numeric_place: 1, date: Date.new(2012) } ]),
          result(place: 2, participant_id: 50, points: 2, tied: nil, scores: [ { numeric_place: 3, date: Date.new(2012) } ]),
          result(place: 3, participant_id: 30, points: 2, tied: true, scores: [ { numeric_place: 3, date: Date.new(2011) } ]),
          result(place: 3, participant_id: 30, points: 2, tied: true, scores: [ { numeric_place: 3, date: Date.new(2011) } ]),
          result(place: 5, participant_id: 10, points: 1, tied: nil, scores: [ { numeric_place: 5, date: Date.new(2012) } ])
        ]
        actual = Calculator.apply_place(source_results, break_ties: true)

        assert_equal_results expected, actual
      end

      def test_place_by_points_unbreakable_tie_2
        source_results = [
          result(points: 15, participant_id: 11, scores: [ { numeric_place: 1, date: Date.new(2012, 6, 2) } ]),
          result(points: 15, participant_id: 11, scores: [ { numeric_place: 1, date: Date.new(2012, 6, 2) } ]),
          result(points: 15, participant_id: 11, scores: [ { numeric_place: 1, date: Date.new(2012, 6, 2) } ]),
          result(points: 15, participant_id: 11, scores: [ { numeric_place: 1, date: Date.new(2012, 6, 2) } ]),
          result(points: 15, participant_id: 14, scores: [ { numeric_place: 1, date: Date.new(2012, 4, 28) } ]),
          result(points: 15, participant_id: 15, scores: [ { numeric_place: 7, date: Date.new(2012, 1, 1) }, { numeric_place: 8, date: Date.new(2012, 1, 1) } ]),
          result(points: 16, participant_id: 16, scores: [ { numeric_place: 8, date: Date.new(2012, 8, 12) } ]),
          result(points: 14, participant_id: 17, scores: [ { numeric_place: 8, date: Date.new(2012, 6, 4) } ]),
        ]
        expected = [
          result(place: 1, points: 16, tied: nil, participant_id: 16, scores: [ { numeric_place: 8, date: Date.new(2012, 8, 12) } ]),
          result(place: 2, points: 15, tied: true, participant_id: 11, scores: [ { numeric_place: 1, date: Date.new(2012, 6, 2) } ]),
          result(place: 2, points: 15, tied: true, participant_id: 11, scores: [ { numeric_place: 1, date: Date.new(2012, 6, 2) } ]),
          result(place: 2, points: 15, tied: true, participant_id: 11, scores: [ { numeric_place: 1, date: Date.new(2012, 6, 2) } ]),
          result(place: 2, points: 15, tied: true, participant_id: 11, scores: [ { numeric_place: 1, date: Date.new(2012, 6, 2) } ]),
          result(place: 6, points: 15, tied: nil, participant_id: 14, scores: [ { numeric_place: 1, date: Date.new(2012, 4, 28) } ]),
          result(place: 7, points: 15, tied: nil, participant_id: 15, scores: [ { numeric_place: 7, date: Date.new(2012, 1, 1) }, { numeric_place: 8, date: Date.new(2012, 1, 1) } ]),
          result(place: 8, points: 14, tied: nil, participant_id: 17, scores: [ { numeric_place: 8, date: Date.new(2012, 6, 4) } ])
        ]
        actual = Calculator.apply_place(source_results, break_ties: true)

        assert_equal_results expected, actual
      end

      def test_highest_result_breaks_tie
        source_results = [
          result(points: 27, participant_id: 1, scores: [ 
            { numeric_place: 1, date: Date.new(2012, 10, 1) },
            { numeric_place: 2, date: Date.new(2012, 10, 8) } ]),
          result(points: 27, participant_id: 2, scores: [ 
            { numeric_place: 3, date: Date.new(2012, 10, 1) },
            { numeric_place: 1, date: Date.new(2012, 10, 8) } ])
        ]
        expected = [
          result(place: 1, participant_id: 1, points: 27, tied: nil, scores: [ 
            { numeric_place: 1, date: Date.new(2012, 10, 1) },
            { numeric_place: 2, date: Date.new(2012, 10, 8) }
          ]),
          result(place: 2, participant_id: 2, points: 27, tied: nil, scores: [ 
            { numeric_place: 3, date: Date.new(2012, 10, 1) },
            { numeric_place: 1, date: Date.new(2012, 10, 8) }
          ])
        ]
        actual = Calculator.apply_place(source_results, break_ties: true)

        assert_equal_results expected, actual
      end

      def test_highest_result_breaks_three_way_tie
        source_results = [
          result(points: 62, participant_id: 1, scores: [ 
            { numeric_place: 6, date: Date.new(2012, 10, 2) },
            { numeric_place: 2, date: Date.new(2012, 10, 19) },
            { numeric_place: 6, date: Date.new(2012, 11, 1) },
            { numeric_place: 3, date: Date.new(2012, 11, 2) },
          ]),
          result(points: 62, participant_id: 2, scores: [ 
            { numeric_place: 8, date: Date.new(2012, 10, 11) },
            { numeric_place: 4, date: Date.new(2012, 10, 12) },
            { numeric_place: 3, date: Date.new(2012, 10, 19) },
            { numeric_place: 2, date: Date.new(2012, 11, 9) },
          ]),
          result(points: 62, participant_id: 3, scores: [ 
            { numeric_place: 4, date: Date.new(2012, 10, 11) },
            { numeric_place: 2, date: Date.new(2012, 10, 12) },
            { numeric_place: 6, date: Date.new(2012, 10, 19) },
            { numeric_place: 5, date: Date.new(2012, 10, 26) },
          ]),
        ]
        expected = [
          result(place: 1, points: 62, participant_id: 2, tied: nil, scores: [ 
            { numeric_place: 8, date: Date.new(2012, 10, 11) },
            { numeric_place: 4, date: Date.new(2012, 10, 12) },
            { numeric_place: 3, date: Date.new(2012, 10, 19) },
            { numeric_place: 2, date: Date.new(2012, 11, 9) },
          ]),
          result(place: 2, points: 62, participant_id: 1, tied: nil, scores: [ 
            { numeric_place: 6, date: Date.new(2012, 10, 2) },
            { numeric_place: 2, date: Date.new(2012, 10, 19) },
            { numeric_place: 6, date: Date.new(2012, 11, 1) },
            { numeric_place: 3, date: Date.new(2012, 11, 2) },
          ]),
          result(place: 3, points: 62, participant_id: 3, tied: nil, scores: [ 
            { numeric_place: 4, date: Date.new(2012, 10, 11) },
            { numeric_place: 2, date: Date.new(2012, 10, 12) },
            { numeric_place: 6, date: Date.new(2012, 10, 19) },
            { numeric_place: 5, date: Date.new(2012, 10, 26) },
          ]),
        ]
        actual = Calculator.apply_place(source_results, break_ties: true)

        assert_equal_results expected, actual
      end

      def test_highest_place_in_last_race_breaks_tie
        source_results = [
          result(points: 27, participant_id: 1, scores: [ 
            { numeric_place: 1, date: Date.new(2012, 10, 1) },
            { numeric_place: 2, date: Date.new(2012, 10, 8) } ]),
          result(points: 27, participant_id: 2, scores: [ 
            { numeric_place: 2, date: Date.new(2012, 10, 1) },
            { numeric_place: 1, date: Date.new(2012, 10, 8) } ])
        ]
        expected = [
          result(place: 1, participant_id: 2, points: 27, tied: nil, scores: [ 
            { numeric_place: 2, date: Date.new(2012, 10, 1) },
            { numeric_place: 1, date: Date.new(2012, 10, 8) }
          ]),
          result(place: 2, participant_id: 1, points: 27, tied: nil, scores: [ 
            { numeric_place: 1, date: Date.new(2012, 10, 1) },
            { numeric_place: 2, date: Date.new(2012, 10, 8) }
          ])
        ]
        actual = Calculator.apply_place(source_results, break_ties: true)

        assert_equal_results expected, actual
      end

      def test_last_result_should_break_tie
        source_results = [
          result(points: 27, participant_id: 1, scores: [ 
            { numeric_place: 1, date: Date.new(2012, 10, 1) },
            { numeric_place: 2, date: Date.new(2012, 10, 19) } 
          ]),
          result(points: 27, participant_id: 2, scores: [ 
            { numeric_place: 2, date: Date.new(2012, 10, 1) },
            { numeric_place: 1, date: Date.new(2012, 10, 8) }
          ])
        ]
        expected = [
          result(place: 1, participant_id: 1, points: 27, tied: nil, scores: [ 
            { numeric_place: 1, date: Date.new(2012, 10, 1) },
            { numeric_place: 2, date: Date.new(2012, 10, 19) }
          ]),
          result(place: 2, participant_id: 2, points: 27, tied: nil, scores: [ 
            { numeric_place: 2, date: Date.new(2012, 10, 1) },
            { numeric_place: 1, date: Date.new(2012, 10, 8) }
          ]),
        ]
        actual = Calculator.apply_place(source_results, break_ties: true)

        assert_equal_results expected, actual
      end

      def test_place_empty
        expected = []
        actual = Calculator.apply_place([], break_ties: false)
        assert_equal expected, actual
      end
      
      def test_compare_by_best_place
        x = Struct::CalculatorResult.new
        y = Struct::CalculatorResult.new
        assert_equal 0, Calculator.compare_by_best_place(x, y)

        x = result(scores: [ { numeric_place: 1 } ] )
        y = result()
        assert_equal(-1, Calculator.compare_by_best_place(x, y))

        x = result()
        y = result(scores: [ { numeric_place: 1 } ] )
        assert_equal(1, Calculator.compare_by_best_place(x, y))

        x = result(scores: [ { numeric_place: 2 } ] )
        y = result(scores: [ { numeric_place: 3 } ] )
        assert_equal(-1, Calculator.compare_by_best_place(x, y))

        x = result(scores: [ { numeric_place: 5 } ] )
        y = result(scores: [ { numeric_place: 5 } ] )
        assert_equal 0, Calculator.compare_by_best_place(x, y)

        x = result(scores: [ { numeric_place: 9 }, { numeric_place: 2 } ] )
        y = result(scores: [ { numeric_place: 2 } ] )
        assert_equal(-1, Calculator.compare_by_best_place(x, y))

        x = result(scores: [ { numeric_place: 9 }, { numeric_place: 2 }, { numeric_place: 4} ] )
        y = result(scores: [ { numeric_place: 4 }, { numeric_place: 2 }, { numeric_place: 10 } ] )
        assert_equal(-1, Calculator.compare_by_best_place(x, y))

        x = result(scores: [ { numeric_place: 9 }, { numeric_place: 2 }, { numeric_place: 4} ] )
        y = result(scores: [ { numeric_place: 4 }, { numeric_place: 2 }, { numeric_place: 4 } ] )
        assert_equal(1, Calculator.compare_by_best_place(x, y))
      end

      def test_compare_by_most_recent_result
        x = Struct::CalculatorResult.new
        y = Struct::CalculatorResult.new
        assert_equal 0, Calculator.compare_by_most_recent_result(x, y)

        x = result(scores: [ { date: Date.today } ] )
        y = result()
        assert_equal(-1, Calculator.compare_by_most_recent_result(x, y))

        x = result()
        y = result(scores: [ { date: Date.today } ] )
        assert_equal 1, Calculator.compare_by_most_recent_result(x, y)

        x = result(scores: [ { date: Date.new(2012, 2) } ] )
        y = result(scores: [ { date: Date.new(2012, 3) } ] )
        assert_equal(1, Calculator.compare_by_most_recent_result(x, y))

        x = result(scores: [ { date: Date.new(2012) } ] )
        y = result(scores: [ { date: Date.new(2012) } ] )
        assert_equal 0, Calculator.compare_by_most_recent_result(x, y)

        x = result(scores: [ { date: Date.new(2012, 9) }, { date: Date.new(2012, 2) } ] )
        y = result(scores: [ { date: Date.new(2012, 2) } ] )
        assert_equal(-1, Calculator.compare_by_most_recent_result(x, y))

        x = result(scores: [ { date: Date.new(2012, 9) }, { date: Date.new(2012, 2) }, { date: Date.new(2012, 4) } ] )
        y = result(scores: [ { date: Date.new(2012, 4) }, { date: Date.new(2012, 2) }, { date: Date.new(2012, 10) } ] )
        assert_equal 1, Calculator.compare_by_most_recent_result(x, y)

        x = result(scores: [ { date: Date.new(2012, 9) }, { date: Date.new(2012, 2) }, { date: Date.new(2012, 4) } ] )
        y = result(scores: [ { date: Date.new(2012, 4) }, { date: Date.new(2012, 2) }, { date: Date.new(2012, 4) } ] )
        assert_equal(-1, Calculator.compare_by_most_recent_result(x, y))
      end

      def test_numeric_place
        assert_equal 1, Calculator.numeric_place(result(place: "1"))
        assert_equal 1, Calculator.numeric_place(result(place: 1))
        assert_equal 217, Calculator.numeric_place(result(place: "217"))
        assert_equal Float::INFINITY, Calculator.numeric_place(result(place: ""))
        assert_equal Float::INFINITY, Calculator.numeric_place(result(place: nil))
        assert_equal Float::INFINITY, Calculator.numeric_place(result(place: "DNF"))
      end
    end
  end
end
