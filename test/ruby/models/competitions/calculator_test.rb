require_relative "../../test_case"
require_relative "../../../../app/models/competitions/calculator"

# :stopdoc:
class Competitions::CalculatorTest < Ruby::TestCase
  def test_calculate_with_no_source_results
    assert_equal [], Competitions::Calculator.calculate([])
  end

  def test_calculate_with_one_source_result
    source_results = [ { "event_id" => 1, "person_id" => 1, "place" => "1", "member_from" => Date.new(2012), member_to: end_of_year } ]
    expected = [
      result(place: 1, person_id: 1, points: 1, scores: [ { person_id: 1, points: 1 } ])
    ]
    actual = Competitions::Calculator.calculate(source_results)
    assert_equal expected, actual
  end

  def test_calculate_with_many_source_results
    source_results = [ 
      { event_id: 1, person_id: 1, place: 1, member_from: Date.new(2012), member_to: end_of_year },
      { event_id: 1, person_id: 2, place: 2, member_from: Date.new(2012), member_to: end_of_year }
    ]
    expected = [
      result(place: 1, person_id: 1, points: 1, scores: [ { person_id: 1, points: 1 } ]),
      result(place: 1, person_id: 2, points: 1, scores: [ { person_id: 2, points: 1 } ])
    ]
    actual = Competitions::Calculator.calculate(source_results)
    assert_equal expected.sort_by(&:person_id), actual.sort_by(&:person_id)
  end

  def test_calculate_should_ignore_non_scoring_results
    source_results = [ 
      { event_id: 1, person_id: 1, place: "", member_from: Date.new(2012), member_to: end_of_year },
      { event_id: 1, person_id: 2, place: "DNS", member_from: Date.new(2012), member_to: end_of_year },
      { event_id: 1, person_id: 3, place: "DQ", member_from: Date.new(2012), member_to: end_of_year },
      { event_id: 1, person_id: 4, place: nil, member_from: Date.new(2012), member_to: end_of_year }
    ]
    expected = []
    actual = Competitions::Calculator.calculate(source_results)
    assert_equal expected, actual
  end

  def test_calculate_ignore_non_starters
    source_results = [ 
      { event_id: 1, person_id: 1, place: "", member_from: Date.new(2012), member_to: end_of_year },
      { event_id: 1, person_id: 2, place: "DNS", member_from: Date.new(2012), member_to: end_of_year },
      { event_id: 1, person_id: 3, place: "DQ", member_from: Date.new(2012), member_to: end_of_year },
      { event_id: 1, person_id: 4, place: nil, member_from: Date.new(2012), member_to: end_of_year }
    ]
    expected = []
    actual = Competitions::Calculator.calculate(source_results)
    assert_equal expected, actual
  end

  def test_calculate_with_multiple_events_and_people
    source_results = [ 
      { id: 1, event_id: 1, race_id: 1, person_id: 1, place: 1, member_from: Date.new(2012), member_to: end_of_year },
      { id: 2, event_id: 1, race_id: 1, person_id: 2, place: 2, member_from: Date.new(2012), member_to: end_of_year },
      { id: 3, event_id: 1, race_id: 1, person_id: 2, place: 20, member_from: Date.new(2012), member_to: end_of_year },
      { id: 4, event_id: 2, race_id: 2, person_id: 1, place: "DNF", member_from: Date.new(2012), member_to: end_of_year }
    ]
    expected = [
      result(place: 1, person_id: 1, points: 2, scores: [ { source_result_id: 1, points: 1, person_id: 1 }, { source_result_id: 4, points: 1, person_id: 1 } ]),
      result(place: 2, person_id: 2, points: 1, scores: [ { source_result_id: 2, points: 1, person_id: 2 } ])
    ]
    actual = Competitions::Calculator.calculate(source_results, dnf: true)
    assert_equal expected.sort_by(&:person_id), actual.sort_by(&:person_id)
  end

  def test_select_eligible_empty
    expected = []
    actual = Competitions::Calculator.select_eligible([])
    assert_equal expected, actual
  end

  def test_select_eligible
    source_results = [ 
      result(id: 1, event_id: 1, race_id: 1, place: 1, member_from: Date.new(2012)),
      result(id: 2, event_id: 1, race_id: 1, person_id: 1, place: nil, member_from: Date.new(2012), member_to: end_of_year),
      result(id: 3, event_id: 1, race_id: 1, person_id: 1, place: "", member_from: Date.new(2012), member_to: end_of_year),
      result(id: 4, event_id: 1, race_id: 1, person_id: 1, place: "DQ", member_from: Date.new(2012), member_to: end_of_year),
      result(id: 5, event_id: 1, race_id: 1, person_id: 1, place: "DNF", member_from: Date.new(2012), member_to: end_of_year),
      result(id: 6, event_id: 1, race_id: 1, person_id: 1, place: "6", member_from: Date.new(2012), member_to: end_of_year),
      result(id: 7, event_id: 1, race_id: 1, person_id: 1, place: "2", member_from: Date.new(2012), member_to: end_of_year),
      result(id: 8, event_id: 1, race_id: 1, person_id: 1, place: "13", member_from: Date.new(2012), member_to: end_of_year),
      result(id: 9, event_id: 1, race_id: 1, person_id: 1, place: "1", member_from: Date.new(2010), member_to: Date.new(2011)),
      result(id: 10, event_id: 1, race_id: 1, person_id: 1, place: "1", member_from: Date.new(Date.today.year + 1), member_to: Date.new(Date.today.year + 2))
    ]
    expected = [ result(id: 7, event_id: 1, race_id: 1, person_id: 1, place: "2", member_from: Date.new(2012), member_to: end_of_year)]
    actual = Competitions::Calculator.select_eligible(source_results)
    assert_equal expected, actual
  end

  def test_map_to_scores
    expected = [ Struct::CalculatorScore.new(1, 1, 1) ]
    source_results = [ result(id: 1, event_id: 1, race_id: 1, person_id: 1, place: 1, member_from: Date.new(2012)) ]
    actual = Competitions::Calculator.map_to_scores(source_results, [], true)
    assert_equal expected, actual
  end

  def test_map_to_scores_empty
    expected = []
    actual = Competitions::Calculator.map_to_scores([], [], true)
    assert_equal expected, actual
  end

  def test_map_to_results
    scores = [ Struct::CalculatorScore.new(1, 1, 1) ]
    expected = [ result(person_id: 1, points: 1, scores: [ { person_id: 1, points: 1, source_result_id: 1 } ]) ]
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

  def test_place_empty
    expected = []
    actual = Competitions::Calculator.place([])
    assert_equal expected, actual
  end

  def test_points
    assert_equal 1, Competitions::Calculator.points(result(place: 20), [], true)
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
  
  def result(hash)
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
