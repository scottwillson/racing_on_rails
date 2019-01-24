# frozen_string_literal: true

require_relative "../../../test_case"
require_relative "../../../../../app/models/calculations"
require_relative "../../../../../app/models/calculations/v3"
require_relative "../../../../../app/models/calculations/v3/calculator"
require_relative "../../../../../app/models/calculations/v3/models"
require_relative "../../../../../app/models/calculations/v3/models/calculated_result"
require_relative "../../../../../app/models/calculations/v3/models/event_category"

# :stopdoc:
class Calculations::V3::AssignPointsTest < Ruby::TestCase
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
end
