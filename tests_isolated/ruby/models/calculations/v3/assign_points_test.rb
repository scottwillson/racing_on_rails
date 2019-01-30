# frozen_string_literal: true

require_relative "../v3"

module Calculations
  module V3
    # :stopdoc:
    class AssignPointsTest < Ruby::TestCase
      def test_assign_points
        category = Models::Category.new("Masters Men")
        rules = Calculations::V3::Rules.new(
          categories: [category],
          points_for_place: [100, 75, 50, 20, 10]
        )
        calculator = Calculations::V3::Calculator.new(rules: rules, source_results: [])
        event_category = calculator.event_categories.first

        source_result = Calculations::V3::Models::SourceResult.new(id: 33, event_category: Calculations::V3::Models::EventCategory.new(category), place: 1)
        participant = Calculations::V3::Models::Participant.new(0)
        result = Calculations::V3::Models::CalculatedResult.new(participant, [source_result])
        event_category.results << result

        source_result = Calculations::V3::Models::SourceResult.new(id: 19, event_category: Calculations::V3::Models::EventCategory.new(category), place: 2)
        participant = Calculations::V3::Models::Participant.new(1)
        result = Calculations::V3::Models::CalculatedResult.new(participant, [source_result])
        event_category.results << result

        event_categories = Calculations::V3::Steps::AssignPoints.calculate!(calculator)

        assert_equal 100, event_categories.first.results[0].source_results.first.points
        assert_equal 75, event_categories.first.results[1].source_results.first.points
      end
    end
  end
end
