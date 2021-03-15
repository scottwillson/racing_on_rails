# frozen_string_literal: true

require_relative "../../v3"

module Calculations
  module V3
    module Steps
      # :stopdoc:
      class RejectNoSourceEventPointsTest < Ruby::TestCase
        def test_calculate
          category = Models::Category.new("Women")
          rules = Rules.new(category_rules: [Models::CategoryRule.new(category)])
          calculator = Calculator.new(rules: rules, source_results: [])
          event_category = calculator.event_categories.first

          source_result = Models::SourceResult.new(id: 33, event_category: Models::EventCategory.new(category), place: 1, points: 0)
          participant = Models::Participant.new(0)
          result = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result

          event_categories = RejectNoSourceEventPoints.calculate!(calculator)

          assert_equal 1, event_categories.first.results.size
          assert !event_categories.first.results.first.source_results.first.rejected?
        end

        # Use the source points. E.g., Age-graded BAR.
        def test_with_source_events
          category = Models::Category.new("Women")
          rules = Rules.new(category_rules: [Models::CategoryRule.new(category)], source_event_keys: [:road_bar])
          calculator = Calculator.new(rules: rules, source_results: [])
          event_category = calculator.event_categories.first

          source_result = Models::SourceResult.new(id: 33, event_category: Models::EventCategory.new(category), place: 1, points: 0)
          participant = Models::Participant.new(0)
          result = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result

          event_categories = RejectNoSourceEventPoints.calculate!(calculator)

          assert_equal 1, event_categories.first.results.size
          assert !event_categories.first.results.first.source_results.first.rejected?
        end

        # E.g., BAR, Cross Crusade
        def test_calculate_points_for_place
          category = Models::Category.new("Women")
          rules = Rules.new(category_rules: [Models::CategoryRule.new(category)], points_for_place: [1, 2, 3])
          calculator = Calculator.new(rules: rules, source_results: [])
          event_category = calculator.event_categories.first

          source_result = Models::SourceResult.new(id: 33, event_category: Models::EventCategory.new(category), place: 1, points: 0)
          participant = Models::Participant.new(0)
          result = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result

          event_categories = RejectNoSourceEventPoints.calculate!(calculator)

          assert_equal 1, event_categories.first.results.size
          assert !event_categories.first.results.first.source_results.first.rejected?
        end

        # For calcs like the overall BAR, don't count zero-point results from discipline BARs
        def test_with_source_events_points_for_place
          category = Models::Category.new("Women")
          rules = Rules.new(category_rules: [Models::CategoryRule.new(category)], source_event_keys: [:road_bar], points_for_place: [1, 2, 3])
          calculator = Calculator.new(rules: rules, source_results: [])
          event_category = calculator.event_categories.first

          source_result = Models::SourceResult.new(id: 33, event_category: Models::EventCategory.new(category), place: 1, points: 0)
          participant = Models::Participant.new(0)
          result = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result

          event_categories = RejectNoSourceEventPoints.calculate!(calculator)

          assert_equal 1, event_categories.first.results.size
          assert event_categories.first.results.first.source_results.empty?
        end
      end
    end
  end
end
