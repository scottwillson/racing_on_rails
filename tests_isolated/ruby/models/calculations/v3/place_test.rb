# frozen_string_literal: true

require_relative "../v3"

# :stopdoc:
class Calculations::V3::PlaceTest < Ruby::TestCase
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
    result = Calculations::V3::Models::CalculatedResult.new(participant, [source_result])

    calculator = Calculations::V3::Calculator.new(rules: rules, source_results: [source_result])
    event_category = calculator.event_categories.first
    event_category.results << result

    Calculations::V3::Steps::Place.calculate!(calculator)

    assert_equal "1", calculator.event_categories.first.results.first.place
  end

  def test_place_many
    category = Calculations::V3::Models::Category.new("Masters Men")
    rules = Calculations::V3::Rules.new(categories: [category])
    calculator = Calculations::V3::Calculator.new(rules: rules, source_results: [])
    event_category = calculator.event_categories.first

    participant = Calculations::V3::Models::Participant.new(0)
    source_result = Calculations::V3::Models::SourceResult.new(id: 0, event_category: Calculations::V3::Models::EventCategory.new(category))
    result = Calculations::V3::Models::CalculatedResult.new(participant, [source_result])
    result.points = 10
    event_category.results << result

    participant = Calculations::V3::Models::Participant.new(1)
    source_result = Calculations::V3::Models::SourceResult.new(id: 1, event_category: Calculations::V3::Models::EventCategory.new(category))
    result = Calculations::V3::Models::CalculatedResult.new(participant, [source_result])
    result.points = 3
    event_category.results << result

    participant = Calculations::V3::Models::Participant.new(1)
    source_result = Calculations::V3::Models::SourceResult.new(id: 2, event_category: Calculations::V3::Models::EventCategory.new(category))
    result = Calculations::V3::Models::CalculatedResult.new(participant, [source_result])
    result.points = 7
    event_category.results << result

    Calculations::V3::Steps::Place.calculate!(calculator)

    assert_equal "1", calculator.event_categories.first.results[0].place
    assert_equal "2", calculator.event_categories.first.results[1].place
    assert_equal "3", calculator.event_categories.first.results[2].place
  end
end
