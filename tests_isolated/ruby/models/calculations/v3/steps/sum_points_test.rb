# frozen_string_literal: true

require_relative "../../v3"

module Calculations
  module V3
    module Steps
      # :stopdoc:
      class SumPointsTest < Ruby::TestCase
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
          source_result.points = 75

          calculator = Calculator.new(rules: rules, source_results: [source_result])

          event_category = calculator.event_categories.first
          result = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result

          event_categories = SumPoints.calculate!(calculator)

          assert_equal 75, event_categories.first.results.first.points
        end
      end
    end
  end
end
