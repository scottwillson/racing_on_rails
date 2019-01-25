# frozen_string_literal: true

require_relative "../../../test_case"
require_relative "../../../../../app/models/calculations"
require_relative "../../../../../app/models/calculations/v3"
require_relative "../../../../../app/models/calculations/v3/calculator"
require_relative "../../../../../app/models/calculations/v3/models"
require_relative "../../../../../app/models/calculations/v3/models/calculated_result"
require_relative "../../../../../app/models/calculations/v3/models/event_category"
require_relative "../../../../../app/models/calculations/v3/steps"
require_relative "../../../../../app/models/calculations/v3/steps/map_source_results_to_results"

# :stopdoc:
class Calculations::V3::MapSourceResultsToResultsTest < Ruby::TestCase
  def test_map_source_results_to_results
    participant = Calculations::V3::Models::Participant.new(0)

    source_result = Calculations::V3::Models::SourceResult.new(
      id: 33,
      participant: participant,
      place: "19"
    )
    source_results = [source_result]

    category = Calculations::V3::Models::Category.new("Masters Men")
    rules = Calculations::V3::Rules.new(categories: [category])
    calculator = Calculations::V3::Calculator.new(rules: rules, source_results: source_results)

    event_categories = Calculations::V3::Steps::MapSourceResultsToResults.calculate!(calculator)

    assert_equal 1, event_categories.size
    assert_equal 1, event_categories.first.results.size
    result = event_categories.first.results.first
    assert_equal 0, result.participant.id

    assert_equal 1, result.source_results.size
    assert_equal 33, result.source_results.first.id
    assert_equal "19", result.source_results.first.place
  end

  def test_group_by_participant_id
    source_results = []

    participant_1 = Calculations::V3::Models::Participant.new(0)
    source_results << Calculations::V3::Models::SourceResult.new(
      id: 33,
      participant: participant_1,
      place: "19"
    )

    participant_2 = Calculations::V3::Models::Participant.new(1)
    source_results << Calculations::V3::Models::SourceResult.new(
      id: 34,
      participant: participant_2,
      place: "7"
    )

    source_results << Calculations::V3::Models::SourceResult.new(
      id: 35,
      participant: participant_1,
      place: "3"
    )

    category = Calculations::V3::Models::Category.new("Masters Men")
    rules = Calculations::V3::Rules.new(categories: [category])
    calculator = Calculations::V3::Calculator.new(rules: rules, source_results: source_results)

    event_categories = Calculations::V3::Steps::MapSourceResultsToResults.calculate!(calculator)

    assert_equal 1, event_categories.size
    assert_equal 2, event_categories.first.results.size

    result = event_categories.first.results.find { |r| r.participant.id == 0 }
    assert_equal 2, result.source_results.size
    source_results = result.source_results.sort_by(&:id)
    assert_equal 33, source_results.first.id
    assert_equal "19", source_results.first.place
    assert_equal 35, source_results.second.id
    assert_equal "3", source_results.second.place

    result = event_categories.first.results.find { |r| r.participant.id == 1 }
    assert_equal 1, result.source_results.size
    assert_equal 34, result.source_results.first.id
    assert_equal "7", result.source_results.first.place
  end
end
