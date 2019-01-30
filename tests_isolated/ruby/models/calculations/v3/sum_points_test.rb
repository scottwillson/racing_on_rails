# frozen_string_literal: true

require_relative "../v3"

# :stopdoc:
class Calculations::V3::SumPointsTest < Ruby::TestCase
  def test_calculate
    category = Calculations::V3::Models::Category.new("Masters Men")
    rules = Calculations::V3::Rules.new(categories: [category])

    participant = Calculations::V3::Models::Participant.new(0)
    source_result = Calculations::V3::Models::SourceResult.new(
      id: 33,
      event_category: Calculations::V3::Models::EventCategory.new(category),
      participant: participant,
      place: "19"
    )
    source_result.points = 75

    calculator = Calculations::V3::Calculator.new(rules: rules, source_results: [source_result])

    event_category = calculator.event_categories.first
    result = Calculations::V3::Models::CalculatedResult.new(participant, [source_result])
    event_category.results << result

    event_categories = Calculations::V3::Steps::SumPoints.calculate!(calculator)

    assert_equal 75, event_categories.first.results.first.points
  end
end
