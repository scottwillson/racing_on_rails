# frozen_string_literal: true

require_relative "../../v3"

module Calculations
  module V3
    module Steps
      # :stopdoc:
      class AssignPointsTest < Ruby::TestCase
        def test_assign_points
          category = Models::Category.new("Masters Men")
          rules = Rules.new(
            categories: [category],
            points_for_place: [100, 75, 50, 20, 10]
          )
          calculator = Calculator.new(rules: rules, source_results: [])
          event_category = calculator.event_categories.first

          source_result = Models::SourceResult.new(id: 33, event_category: Models::EventCategory.new(category), place: 1)
          participant = Models::Participant.new(0)
          result = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result

          source_result = Models::SourceResult.new(id: 19, event_category: Models::EventCategory.new(category), place: 2)
          participant = Models::Participant.new(1)
          result = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result

          event_categories = AssignPoints.calculate!(calculator)

          assert_equal 100, event_categories.first.results[0].source_results.first.points
          assert_equal 75, event_categories.first.results[1].source_results.first.points
        end
      end
    end
  end
end
