require_relative "../../test_case"
require_relative "../../../../app/models/competitions/calculator"

# :stopdoc:
# TODO remove noisy member setup
class Competitions::CalculatorTest < Ruby::TestCase
  def test_calculate_with_no_source_results
    assert_equal [], Competitions::Calculator.calculate([])
  end

  def test_calculate_with_one_source_result
    source_results = [ { "event_id" => 1, "participant_id" => 1, "place" => "1", "member_from" => Date.new(2012), member_to: end_of_year, "year" => Date.today.year } ]
    expected = [
      result(place: 1, participant_id: 1, points: 1, scores: [ { numeric_place: 1, participant_id: 1, points: 1 } ])
    ]
    actual = Competitions::Calculator.calculate(source_results)
    assert_equal expected, actual
  end

  def test_calculate_with_many_source_results
    source_results = [ 
      { event_id: 1, participant_id: 1, place: 1, member_from: Date.new(2012), member_to: end_of_year, "year" => Date.today.year },
      { event_id: 1, participant_id: 2, place: 2, member_from: Date.new(2012), member_to: end_of_year, "year" => Date.today.year }
    ]
    expected = [
      result(place: 1, participant_id: 1, points: 1, scores: [ { numeric_place: 1, participant_id: 1, points: 1 } ]),
      result(place: 1, participant_id: 2, points: 1, scores: [ { numeric_place: 2, participant_id: 2, points: 1 } ])
    ]
    actual = Competitions::Calculator.calculate(source_results)
    assert_equal expected.sort_by(&:participant_id), actual.sort_by(&:participant_id)
  end

  def test_calculate_team_results
    source_results = [ 
      { race_id: 1, participant_id: 3, place: 1, member_from: Date.new(2012), member_to: end_of_year, "year" => Date.today.year },
      { race_id: 1, participant_id: 4, place: 1, member_from: Date.new(2012), member_to: end_of_year, "year" => Date.today.year },
      { race_id: 1, participant_id: 1, place: 2, member_from: Date.new(2012), member_to: end_of_year, "year" => Date.today.year },
      { race_id: 1, participant_id: 2, place: 2, member_from: Date.new(2012), member_to: end_of_year, "year" => Date.today.year }
    ]
    expected = [
      result(place: 3, participant_id: 1, points: 4, scores: [ { numeric_place: 2, participant_id: 1, points: 4 } ]),
      result(place: 3, participant_id: 2, points: 4, scores: [ { numeric_place: 2, participant_id: 2, points: 4 } ]),
      result(place: 1, participant_id: 3, points: 10, scores: [ { numeric_place: 1, participant_id: 3, points: 10 } ]),
      result(place: 1, participant_id: 4, points: 10, scores: [ { numeric_place: 1, participant_id: 4, points: 10 } ])
    ]
    actual = Competitions::Calculator.calculate(source_results, point_schedule: [ 20, 8, 3 ])
    assert_equal expected.sort_by(&:participant_id), actual.sort_by(&:participant_id)
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
    actual = Competitions::Calculator.calculate(
      source_results, point_schedule: [ 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ], results_per_event: 3, results_per_race: Competitions::Calculator::UNLIMITED, members_only: false
    )
    assert_equal_results expected.sort_by(&:participant_id), actual.sort_by(&:participant_id)
  end

  def test_calculate_should_ignore_non_scoring_results
    source_results = [ 
      { event_id: 1, participant_id: 1, place: "", member_from: Date.new(2012), member_to: end_of_year },
      { event_id: 1, participant_id: 2, place: "DNS", member_from: Date.new(2012), member_to: end_of_year },
      { event_id: 1, participant_id: 3, place: "DQ", member_from: Date.new(2012), member_to: end_of_year },
      { event_id: 1, participant_id: 4, place: nil, member_from: Date.new(2012), member_to: end_of_year }
    ]
    expected = []
    actual = Competitions::Calculator.calculate(source_results)
    assert_equal expected, actual
  end

  def test_calculate_ignore_non_starters
    source_results = [ 
      { event_id: 1, participant_id: 1, place: "", member_from: Date.new(2012), member_to: end_of_year },
      { event_id: 1, participant_id: 2, place: "DNS", member_from: Date.new(2012), member_to: end_of_year },
      { event_id: 1, participant_id: 3, place: "DQ", member_from: Date.new(2012), member_to: end_of_year },
      { event_id: 1, participant_id: 4, place: nil, member_from: Date.new(2012), member_to: end_of_year }
    ]
    expected = []
    actual = Competitions::Calculator.calculate(source_results)
    assert_equal expected, actual
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
    actual = Competitions::Calculator.calculate(source_results, dnf: true)
    assert_equal expected.sort_by(&:participant_id), actual.sort_by(&:participant_id)
  end

  def test_select_eligible_empty
    expected = []
    actual = Competitions::Calculator.select_eligible([])
    assert_equal expected, actual
  end

  def test_select_eligible
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
    actual = Competitions::Calculator.select_eligible(source_results)
    assert_equal_results expected, actual
  end
  
  def test_select_eligible_with_results_per_event
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
    actual = Competitions::Calculator.select_eligible(source_results, 2, Competitions::Calculator::UNLIMITED, false)
    assert_equal_results expected, actual
  end
  
  def test_select_eligible_with_results_per_race_1
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
    actual = Competitions::Calculator.select_eligible(source_results, 1, 1, false)
    assert_equal_results expected, actual
  end
  
  def test_select_eligible_with_results_per_race_2
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
    actual = Competitions::Calculator.select_eligible(source_results, Competitions::Calculator::UNLIMITED, 2, false)
    assert_equal_results expected, actual
  end
  
  def test_select_eligible_should_sort_choose_best_results
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
    actual = Competitions::Calculator.select_eligible(source_results, 2, Competitions::Calculator::UNLIMITED, false)
    assert_equal expected.sort_by(&:id), actual.sort_by(&:id)
  end

  def test_map_to_scores
    expected = [ Struct::CalculatorScore.new(nil, 1, 1, 1, 1) ]
    source_results = [ result(id: 1, event_id: 1, race_id: 1, participant_id: 1, place: 1, member_from: Date.new(2012)) ]
    actual = Competitions::Calculator.map_to_scores(source_results, nil, true)
    assert_equal expected, actual
  end

  def test_map_to_scores_empty
    expected = []
    actual = Competitions::Calculator.map_to_scores([], nil, true)
    assert_equal expected, actual
  end

  def test_map_to_results
    scores = [ Struct::CalculatorScore.new(nil, 1, 1, 1, 1) ]
    expected = [ result(participant_id: 1, points: 1, scores: [ { numeric_place: 1, participant_id: 1, points: 1, source_result_id: 1 } ]) ]
    actual = Competitions::Calculator.map_to_results(scores)
    assert_equal expected, actual
  end

  def test_map_to_results_empty
    expected = []
    actual = Competitions::Calculator.map_to_results([])
    assert_equal expected, actual
  end

  def test_place
    source_results = [ result(points: 1) ]
    expected = [ result(place: 1, points: 1) ]
    actual = Competitions::Calculator.place(source_results)
    assert_equal expected, actual
  end

  def test_place_by_points
    source_results = [ result(points: 1), result(points: 10), result(points: 2) ]
    expected = [ result(place: 1, points: 10), result(place: 2, points: 2), result(place: 3, points: 1) ]
    actual = Competitions::Calculator.place(source_results)
    assert_equal expected, actual.sort_by(&:place)
  end

  def test_place_by_points_with_ties
    source_results = [ result(points: 1), result(points: 10), result(points: 2), result(points: 2), result(points: 2) ]
    expected = [ result(place: 1, points: 10), result(place: 2, points: 2), result(place: 2, points: 2), result(place: 2, points: 2), result(place: 5, points: 1) ]
    actual = Competitions::Calculator.place(source_results)
    assert_equal expected, actual.sort_by(&:place)
  end

  def test_place_by_points_break_ties
    source_results = [ 
      result(points: 1, scores: [ { numeric_place: 5, date: Date.new(2012) } ]), 
      result(points: 10, scores: [ { numeric_place: 1, date: Date.new(2012) } ]), 
      result(points: 2, scores: [ { numeric_place: 3, date: Date.new(2011) } ]), 
      result(points: 2, scores: [ { numeric_place: 3, date: Date.new(2010) } ]), 
      result(points: 2, scores: [ { numeric_place: 3, date: Date.new(2012) } ])
    ]
    expected = [ 
      result(place: 1, points: 10, scores: [ { numeric_place: 1, date: Date.new(2012) } ]), 
      result(place: 2, points: 2, scores: [ { numeric_place: 3, date: Date.new(2012) } ]),
      result(place: 3, points: 2, scores: [ { numeric_place: 3, date: Date.new(2011) } ]), 
      result(place: 4, points: 2, scores: [ { numeric_place: 3, date: Date.new(2010) } ]), 
      result(place: 5, points: 1, scores: [ { numeric_place: 5, date: Date.new(2012) } ]) 
    ]
    actual = Competitions::Calculator.place(source_results, true)
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
    actual = Competitions::Calculator.place(source_results, true)

    assert_equal expected.sort_by(&:participant_id), actual.sort_by(&:participant_id)
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
    actual = Competitions::Calculator.place(source_results, true)

    assert_equal expected.sort_by(&:participant_id), actual.sort_by(&:participant_id)
  end

  def test_place_empty
    expected = []
    actual = Competitions::Calculator.place([])
    assert_equal expected, actual
  end

  def test_points
    assert_equal 1, Competitions::Calculator.points(result(place: 20))
  end
  
  def test_points_with_point_schedule
    assert_equal 0, Competitions::Calculator.points(result(place: "20"), [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ], false)
    assert_equal 1, Competitions::Calculator.points(result(place: "15"), [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ], false)
    assert_equal 14, Competitions::Calculator.points(result(place: 2), [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ], false)
    assert_equal 0, Competitions::Calculator.points(result(place: ""), [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ], false)
    assert_equal 0, Competitions::Calculator.points(result(place: nil), [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ], false)
    assert_equal 0, Competitions::Calculator.points(result(place: "DNF"), [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ], false)
    assert_equal 0, Competitions::Calculator.points(result(place: "DQ"), [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ], false)
  end
  
  def test_points_considers_team_size
    assert_equal 0, Competitions::Calculator.points(result(place: "20", team_size: 2), [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ], false)
    assert_equal 0.5, Competitions::Calculator.points(result(place: "15", team_size: 2), [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ], false)
    assert_equal 7, Competitions::Calculator.points(result(place: 2, team_size: 2), [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ], false)
    assert_equal 0, Competitions::Calculator.points(result(place: "", team_size: 2), [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ], false)
    assert_equal 0, Competitions::Calculator.points(result(place: nil, team_size: 2), [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ], false)
    assert_equal 0, Competitions::Calculator.points(result(place: "DNF", team_size: 2), [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ], false)
    assert_equal 0, Competitions::Calculator.points(result(place: "DQ", team_size: 2), [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ], false)
    assert_equal 0, Competitions::Calculator.points(result(place: "20", team_size: 3), [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ], false)
    assert_in_delta 0.333, Competitions::Calculator.points(result(place: "15", team_size: 3), [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ], false), 0.1
    assert_in_delta 4.666, Competitions::Calculator.points(result(place: 2, team_size: 3), [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ], false), 0.1
    assert_equal 0, Competitions::Calculator.points(result(place: "", team_size: 3), [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ], false)
    assert_equal 0, Competitions::Calculator.points(result(place: nil, team_size: 3), [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ], false)
    assert_equal 0, Competitions::Calculator.points(result(place: "DNF", team_size: 3), [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ], false)
    assert_equal 0, Competitions::Calculator.points(result(place: "DQ", team_size: 3), [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ], false)
  end
  
  def test_points_considers_multiplier
    assert_equal 27, Competitions::Calculator.points(result(place: "7", multiplier: 3), [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ], false)
    assert_equal 0, Competitions::Calculator.points(result(place: "7", multiplier: 0), [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ], false)
  end
  
  def test_points_considers_multiplier_and_team_size
    assert_in_delta 9.333, 0.1, Competitions::Calculator.points(result(place: "2", multiplier: 2, team_size: 3),  [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ], false)
  end
  
  def test_points_considers_field_size
    assert_equal 9, Competitions::Calculator.points(result(place: "7", field_size: 74), [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ], false, true)
    assert_equal 13.5, Competitions::Calculator.points(result(place: "7", field_size: 75), [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ], false, true)
    assert_equal 13.5, Competitions::Calculator.points(result(place: "7", field_size: 76), [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ], false, true)
  end
  
  def test_points_ignore_field_size_if_multipler
    assert_equal 27, Competitions::Calculator.points(result(place: "7", multiplier: 3, field_size: 74), [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ], false, true)
    assert_equal 27, Competitions::Calculator.points(result(place: "7", multiplier: 3, field_size: 75), [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ], false, true)
    assert_equal 27, Competitions::Calculator.points(result(place: "7", multiplier: 3, field_size: 76), [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ], false, true)
  end
  
  def test_points_use_source_result_points
    assert_equal 11, Competitions::Calculator.points(result(place: "2", multiplier: 2, points: 11), [ 3, 2, 1 ], false, false, true)
  end
  
  def test_add_team_sizes_empty
    assert_equal [], Competitions::Calculator.add_team_sizes([])
  end
  
  def test_add_team_sizes
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
    assert_equal expected, Competitions::Calculator.add_team_sizes(results)
  end

  def test_numeric_place
    assert_equal 1, Competitions::Calculator.numeric_place(result(place: "1"))
    assert_equal 1, Competitions::Calculator.numeric_place(result(place: 1))
    assert_equal 217, Competitions::Calculator.numeric_place(result(place: "217"))
    assert_equal Float::INFINITY, Competitions::Calculator.numeric_place(result(place: ""))
    assert_equal Float::INFINITY, Competitions::Calculator.numeric_place(result(place: nil))
    assert_equal Float::INFINITY, Competitions::Calculator.numeric_place(result(place: "DNF"))
  end

  def test_map_hashes_to_results
    expected = [ Struct::CalculatorResult.new.tap { |r| r.place = 3 } ]
    actual = Competitions::Calculator.map_hashes_to_results([{ place: 3 }])
    assert_equal expected, actual
  end
  
  def test_compare_by_best_place
    x = Struct::CalculatorResult.new
    y = Struct::CalculatorResult.new
    assert_equal 0, Competitions::Calculator.compare_by_best_place(x, y)

    x = result(scores: [ { numeric_place: 1 } ] )
    y = result()
    assert_equal(-1, Competitions::Calculator.compare_by_best_place(x, y))

    x = result()
    y = result(scores: [ { numeric_place: 1 } ] )
    assert_equal(1, Competitions::Calculator.compare_by_best_place(x, y))

    x = result(scores: [ { numeric_place: 2 } ] )
    y = result(scores: [ { numeric_place: 3 } ] )
    assert_equal(-1, Competitions::Calculator.compare_by_best_place(x, y))

    x = result(scores: [ { numeric_place: 5 } ] )
    y = result(scores: [ { numeric_place: 5 } ] )
    assert_equal 0, Competitions::Calculator.compare_by_best_place(x, y)

    x = result(scores: [ { numeric_place: 9 }, { numeric_place: 2 } ] )
    y = result(scores: [ { numeric_place: 2 } ] )
    assert_equal(-1, Competitions::Calculator.compare_by_best_place(x, y))

    x = result(scores: [ { numeric_place: 9 }, { numeric_place: 2 }, { numeric_place: 4} ] )
    y = result(scores: [ { numeric_place: 4 }, { numeric_place: 2 }, { numeric_place: 10 } ] )
    assert_equal(-1, Competitions::Calculator.compare_by_best_place(x, y))

    x = result(scores: [ { numeric_place: 9 }, { numeric_place: 2 }, { numeric_place: 4} ] )
    y = result(scores: [ { numeric_place: 4 }, { numeric_place: 2 }, { numeric_place: 4 } ] )
    assert_equal(1, Competitions::Calculator.compare_by_best_place(x, y))
  end
  
  def test_compare_by_most_recent_result
    x = Struct::CalculatorResult.new
    y = Struct::CalculatorResult.new
    assert_equal 0, Competitions::Calculator.compare_by_most_recent_result(x, y)

    x = result(scores: [ { date: Date.today } ] )
    y = result()
    assert_equal(-1, Competitions::Calculator.compare_by_most_recent_result(x, y))

    x = result()
    y = result(scores: [ { date: Date.today } ] )
    assert_equal 1, Competitions::Calculator.compare_by_most_recent_result(x, y)

    x = result(scores: [ { date: Date.new(2012, 2) } ] )
    y = result(scores: [ { date: Date.new(2012, 3) } ] )
    assert_equal(1, Competitions::Calculator.compare_by_most_recent_result(x, y))

    x = result(scores: [ { date: Date.new(2012) } ] )
    y = result(scores: [ { date: Date.new(2012) } ] )
    assert_equal 0, Competitions::Calculator.compare_by_most_recent_result(x, y)

    x = result(scores: [ { date: Date.new(2012, 9) }, { date: Date.new(2012, 2) } ] )
    y = result(scores: [ { date: Date.new(2012, 2) } ] )
    assert_equal(-1, Competitions::Calculator.compare_by_most_recent_result(x, y))

    x = result(scores: [ { date: Date.new(2012, 9) }, { date: Date.new(2012, 2) }, { date: Date.new(2012, 4) } ] )
    y = result(scores: [ { date: Date.new(2012, 4) }, { date: Date.new(2012, 2) }, { date: Date.new(2012, 10) } ] )
    assert_equal 1, Competitions::Calculator.compare_by_most_recent_result(x, y)

    x = result(scores: [ { date: Date.new(2012, 9) }, { date: Date.new(2012, 2) }, { date: Date.new(2012, 4) } ] )
    y = result(scores: [ { date: Date.new(2012, 4) }, { date: Date.new(2012, 2) }, { date: Date.new(2012, 4) } ] )
    assert_equal(-1, Competitions::Calculator.compare_by_most_recent_result(x, y))
  end
  
  def test_member_in_year
    assert !Competitions::Calculator.member_in_year?(result(year: 2005))
    assert !Competitions::Calculator.member_in_year?(result(year: 2005, member_from: Date.new(2001)))
    assert !Competitions::Calculator.member_in_year?(result(year: 2005, member_from: Date.new(2012)))
    assert !Competitions::Calculator.member_in_year?(result(year: 2005, member_from: Date.new(2006), member_to: Date.new(2007)))
    assert !Competitions::Calculator.member_in_year?(result(year: 2005, member_from: Date.new(1999), member_to: Date.new(2004)))
    assert  Competitions::Calculator.member_in_year?(result(year: 2005, member_from: Date.new(1999), member_to: Date.new(2014)))
  end
  
  def assert_equal_results(expected, actual)
    [ expected, actual ].each do |results|
      results.each { |result| result.scores.sort_by!(&:numeric_place) }
      results.sort_by!(&:participant_id)
      results.sort_by!(&:place)
    end
    
    unless expected == actual
      expected_message = pretty_to_string(expected)
      actual_message = pretty_to_string(actual)
      flunk("Results not equal." + "\nExpected:\n" + expected_message + "Actual:\n" + actual_message)
    end
  end
  
  def pretty_to_string(results)
    message = ""
    results.each do |r|
      message << "  Result place #{r.place} participant_id: #{r.participant_id} points: #{r.points}"
      message << "\n"
      r.scores.each do |s|
        message << "    Score place: #{s.numeric_place} points: #{s.points}"
        message << "\n"
      end
      message << "\n" if r.scores.size > 0
    end
    message
  end

  def result(hash = {})
    result = Struct::CalculatorResult.new

    scores = hash[:scores] || []
    scores.map! do |score|
      struct = Struct::CalculatorScore.new
      score.each do |key, value|
        struct[key] = value
      end
      struct
    end
    hash[:scores] = scores

    hash.each do |key, value|
      result[key] = value
    end
    result
  end
  
  def end_of_year
    @end_of_year ||= Date.new(Date.today.year, 12, 31)
  end
end
