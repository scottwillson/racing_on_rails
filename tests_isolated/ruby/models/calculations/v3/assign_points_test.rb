# frozen_string_literal: true

require_relative "../../../test_case"
require_relative "../../../../../app/models/calculations"
require_relative "../../../../../app/models/calculations/v3"
require_relative "../../../../../app/models/calculations/v3/calculator"
require_relative "../../../../../app/models/calculations/v3/models"
require_relative "../../../../../app/models/calculations/v3/models/calculated_result"
require_relative "../../../../../app/models/calculations/v3/models/event_category"
require_relative "../../../../../app/models/calculations/v3/steps"
require_relative "../../../../../app/models/calculations/v3/steps/assign_points"

# :stopdoc:
class Calculations::V3::AssignPointsTest < Ruby::TestCase
  def test_assign_points
    category = Calculations::V3::Models::Category.new("Masters Men")
    rules = Calculations::V3::Rules.new(categories: [category])

    participant = Calculations::V3::Models::Participant.new(0)
    source_result = Calculations::V3::Models::SourceResult.new(
      id: 33,
      participant: participant,
      place: "19"
    )

    calculator = Calculations::V3::Calculator.new(rules: rules, source_results: [source_result])

    event_category = calculator.event_categories.first
    result = Calculations::V3::Models::CalculatedResult.new(participant, [source_result])
    event_category.results << result

    event_categories = Calculations::V3::Steps::AssignPoints.calculate!(calculator)

    assert_equal 100, event_categories.first.results.first.source_results.first.points
  end
end
