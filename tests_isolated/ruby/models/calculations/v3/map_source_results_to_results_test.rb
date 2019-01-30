# frozen_string_literal: true

require_relative "../v3"

# :stopdoc:
class Calculations::V3::MapSourceResultsToResultsTest < Ruby::TestCase
  def test_map_source_results_to_results
    participant = Calculations::V3::Models::Participant.new(0)
    category = Calculations::V3::Models::Category.new("Masters Men")

    source_result = Calculations::V3::Models::SourceResult.new(
      id: 33,
      event_category: Calculations::V3::Models::EventCategory.new(category),
      participant: participant,
      place: "19"
    )
    source_results = [source_result]

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
    category = Calculations::V3::Models::Category.new("Masters Men")

    participant_1 = Calculations::V3::Models::Participant.new(0)
    source_results << Calculations::V3::Models::SourceResult.new(
      id: 33,
      event_category: Calculations::V3::Models::EventCategory.new(category),
      participant: participant_1,
      place: "19"
    )

    participant_2 = Calculations::V3::Models::Participant.new(1)
    source_results << Calculations::V3::Models::SourceResult.new(
      id: 34,
      event_category: Calculations::V3::Models::EventCategory.new(category),
      participant: participant_2,
      place: "7"
    )

    source_results << Calculations::V3::Models::SourceResult.new(
      id: 35,
      event_category: Calculations::V3::Models::EventCategory.new(category),
      participant: participant_1,
      place: "3"
    )

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
    assert_equal 35, source_results[1].id
    assert_equal "3", source_results[1].place

    result = event_categories.first.results.find { |r| r.participant.id == 1 }
    assert_equal 1, result.source_results.size
    assert_equal 34, result.source_results.first.id
    assert_equal "7", result.source_results.first.place
  end

  def test_group_by_category
    source_results = []
    masters_men = Calculations::V3::Models::Category.new("Masters Men")
    junior_women = Calculations::V3::Models::Category.new("Junior Women")

    participant_1 = Calculations::V3::Models::Participant.new(0)
    source_results << Calculations::V3::Models::SourceResult.new(
      id: 33,
      event_category: Calculations::V3::Models::EventCategory.new(junior_women),
      participant: participant_1,
      place: "19"
    )

    participant_2 = Calculations::V3::Models::Participant.new(1)
    source_results << Calculations::V3::Models::SourceResult.new(
      id: 34,
      event_category: Calculations::V3::Models::EventCategory.new(masters_men),
      participant: participant_2,
      place: "7"
    )

    source_results << Calculations::V3::Models::SourceResult.new(
      id: 35,
      event_category: Calculations::V3::Models::EventCategory.new(masters_men),
      participant: participant_1,
      place: "3"
    )

    rules = Calculations::V3::Rules.new(categories: [masters_men, junior_women])
    calculator = Calculations::V3::Calculator.new(rules: rules, source_results: source_results)

    event_categories = Calculations::V3::Steps::MapSourceResultsToResults.calculate!(calculator)
    assert_equal 2, event_categories.size
    junior_women_event_category = event_categories.find { |ec| ec.category == junior_women }
    assert_equal 1, junior_women_event_category.results.size
    masters_men_event_category = event_categories.find { |ec| ec.category == masters_men }
    assert_equal 2, masters_men_event_category.results.size
  end
end
