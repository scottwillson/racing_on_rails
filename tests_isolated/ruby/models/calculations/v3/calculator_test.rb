# frozen_string_literal: true

require_relative "../../../test_case"
require_relative "../../../../../app/models/calculations"
require_relative "../../../../../app/models/calculations/v3"
require_relative "../../../../../app/models/calculations/v3/calculator"
require_relative "../../../../../app/models/calculations/v3/models"
require_relative "../../../../../app/models/calculations/v3/models/calculated_result"

# :stopdoc:
class Calculations::V3::CalculatorTest < Ruby::TestCase
  def test_initialize
    Calculations::V3::Calculator.new([])
  end

  def test_calculate
    calculator = Calculations::V3::Calculator.new([])
    calculator.calculate! []
  end

  def test_map_categories_to_event_categories
    calculator = Calculations::V3::Calculator.new([Calculations::V3::Models::Category.new("Masters Men")])
    event_categories = calculator.map_categories_to_event_categories
    assert_equal 1, event_categories.size
    assert_equal "Masters Men", event_categories.first.name
  end

  def test_map_source_results_to_results
    participant = Calculations::V3::Models::Participant.new(0)

    source_result = Calculations::V3::Models::SourceResult.new(
      id: 33,
      participant: participant,
      place: "19"
    )
    source_results = [source_result]
    calculator = Calculations::V3::Calculator.new([])

    results = calculator.map_source_results_to_results(source_results)

    assert_equal 1, results.size
    result = results.first
    assert_equal 0, result.participant.id

    assert_equal 1, result.source_results.size
    assert_equal 33, result.source_results.first.id
    assert_equal "19", result.source_results.first.place
  end

  def test_group_results_by_event_category
    calculator = Calculations::V3::Calculator.new([])
    participant = Calculations::V3::Models::Participant.new(0)
    source_result = Calculations::V3::Models::SourceResult.new(
      id: 33,
      participant: participant,
      place: "19"
    )
    results = [Calculations::V3::Models::CalculatedResult.new(participant, [source_result])]
    category = Calculations::V3::Models::Category.new("Masters Men")
    event_categories = [Calculations::V3::Models::EventCategory.new(category)]

    event_categories = calculator.group_results_by_event_category(results, event_categories)

    assert_equal 1, event_categories.size
    assert_equal 1, event_categories.first.results.size
  end

  def test_assign_points
    calculator = Calculations::V3::Calculator.new([])
    participant = Calculations::V3::Models::Participant.new(0)
    source_result = Calculations::V3::Models::SourceResult.new(
      id: 33,
      participant: participant,
      place: "19"
    )
    category = Calculations::V3::Models::Category.new("Masters Men")
    event_category = Calculations::V3::Models::EventCategory.new(category)
    result = Calculations::V3::Models::CalculatedResult.new(participant, [source_result])
    event_category.results << result

    event_categories = calculator.assign_points([event_category])

    assert_equal 100, event_categories.first.results.first.source_results.first.points
  end

  def test_sum_points
    calculator = Calculations::V3::Calculator.new([])
    participant = Calculations::V3::Models::Participant.new(0)
    source_result = Calculations::V3::Models::SourceResult.new(
      id: 33,
      participant: participant,
      place: "19"
    )
    source_result.points = 75
    category = Calculations::V3::Models::Category.new("Masters Men")
    event_category = Calculations::V3::Models::EventCategory.new(category)
    result = Calculations::V3::Models::CalculatedResult.new(participant, [source_result])
    event_category.results << result

    event_categories = calculator.sum_points([event_category])

    assert_equal 75, event_categories.first.results.first.points
  end

  def test_place
    calculator = Calculations::V3::Calculator.new([])
    participant = Calculations::V3::Models::Participant.new(0)
    source_result = Calculations::V3::Models::SourceResult.new(
      id: 33,
      participant: participant,
      place: "19"
    )
    category = Calculations::V3::Models::Category.new("Masters Men")
    event_category = Calculations::V3::Models::EventCategory.new(category)
    result = Calculations::V3::Models::CalculatedResult.new(participant, [source_result])
    event_category.results << result

    event_categories = calculator.place([event_category])

    assert_equal "1", event_categories.first.results.first.place
  end
end
