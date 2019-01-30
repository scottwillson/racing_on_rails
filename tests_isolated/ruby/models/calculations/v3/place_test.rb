# frozen_string_literal: true

require_relative "../v3"

module Calculations
  module V3
    # :stopdoc:
    class PlaceTest < Ruby::TestCase
      def test_calculate
        category = Models::Category.new("Masters Men")
        rules = Rules.new(categories: [category])

        participant = Models::Participant.new(0)
        source_result = Models::SourceResult.new(
          id: 33,
          event_category: Models::EventCategory.new(category),
          participant: participant,
          place: "19"
        )
        result = Models::CalculatedResult.new(participant, [source_result])

        calculator = Calculator.new(rules: rules, source_results: [source_result])
        event_category = calculator.event_categories.first
        event_category.results << result

        Steps::Place.calculate!(calculator)

        assert_equal "1", calculator.event_categories.first.results.first.place
      end

      def test_place_many
        category = Models::Category.new("Masters Men")
        rules = Rules.new(categories: [category])
        calculator = Calculator.new(rules: rules, source_results: [])
        event_category = calculator.event_categories.first

        participant = Models::Participant.new(0)
        source_result = Models::SourceResult.new(id: 0, event_category: Models::EventCategory.new(category))
        result = Models::CalculatedResult.new(participant, [source_result])
        result.points = 10
        event_category.results << result

        participant = Models::Participant.new(1)
        source_result = Models::SourceResult.new(id: 1, event_category: Models::EventCategory.new(category))
        result = Models::CalculatedResult.new(participant, [source_result])
        result.points = 3
        event_category.results << result

        participant = Models::Participant.new(1)
        source_result = Models::SourceResult.new(id: 2, event_category: Models::EventCategory.new(category))
        result = Models::CalculatedResult.new(participant, [source_result])
        result.points = 7
        event_category.results << result

        Steps::Place.calculate!(calculator)

        assert_equal "1", calculator.event_categories.first.results[0].place
        assert_equal "2", calculator.event_categories.first.results[1].place
        assert_equal "3", calculator.event_categories.first.results[2].place
      end
    end
  end
end
