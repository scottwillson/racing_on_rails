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
    Calculations::V3::Calculator.new
  end

  def test_calculate
    calculator = Calculations::V3::Calculator.new
    calculator.calculate! []
  end

  def test_map_categories_to_event_categories
    categories = [Calculations::V3::Models::Category.new("Masters Men")]
    rules = Calculations::V3::Rules.new(categories: categories)
    calculator = Calculations::V3::Calculator.new(rules)
    event_categories = calculator.map_categories_to_event_categories(categories)
    assert_equal 1, event_categories.size
    assert_equal "Masters Men", event_categories.first.name
  end

  def test_sum_points
    calculator = Calculations::V3::Calculator.new
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
    calculator = Calculations::V3::Calculator.new
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
