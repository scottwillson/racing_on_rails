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
            category_rules: [Models::CategoryRule.new(category)],
            points_for_place: [100, 75, 50, 20, 10]
          )
          calculator = Calculator.new(rules: rules, source_results: [])
          event_category = calculator.event_categories.first

          event = Models::Event.new
          source_result = Models::SourceResult.new(id: 33, event_category: Models::EventCategory.new(category, event), place: 1)
          participant = Models::Participant.new(0)
          result = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result

          event = Models::Event.new
          source_result = Models::SourceResult.new(id: 19, event_category: Models::EventCategory.new(category, event), place: 2)
          participant = Models::Participant.new(1)
          result = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result

          event_categories = AssignPoints.calculate!(calculator)

          assert_equal 100, event_categories.first.results[0].source_results.first.points
          assert_equal 75, event_categories.first.results[1].source_results.first.points
        end

        def test_multiplier
          category = Models::Category.new("Masters Men")
          rules = Rules.new(
            category_rules: [Models::CategoryRule.new(category)],
            points_for_place: [100, 75, 50, 20, 10]
          )
          calculator = Calculator.new(rules: rules, source_results: [])
          event_category = calculator.event_categories.first

          event = Models::Event.new
          source_result = Models::SourceResult.new(id: 33, event_category: Models::EventCategory.new(category, event), place: 1)
          participant = Models::Participant.new(0)
          result = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result

          event = Models::Event.new(multiplier: 2)
          source_result = Models::SourceResult.new(id: 19, event_category: Models::EventCategory.new(category, event), place: 2)
          participant = Models::Participant.new(1)
          result = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result

          event_categories = AssignPoints.calculate!(calculator)

          assert_equal 100, event_categories.first.results[0].source_results.first.points
          assert_equal 150, event_categories.first.results[1].source_results.first.points
        end

        def test_no_points_for_place
          category = Models::Category.new("Masters Men")
          rules = Rules.new
          calculator = Calculator.new(rules: rules, source_results: [])
          event_category = calculator.event_categories.first

          event = Models::Event.new
          source_result = Models::SourceResult.new(id: 33, event_category: Models::EventCategory.new(category, event), place: 1)
          participant = Models::Participant.new(0)
          result = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result

          event = Models::Event.new
          source_result = Models::SourceResult.new(id: 19, event_category: Models::EventCategory.new(category, event), place: 2)
          participant = Models::Participant.new(1)
          result = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result

          event_categories = AssignPoints.calculate!(calculator)

          assert_equal 1, event_categories.first.results[0].source_results.first.points
          assert_equal 1, event_categories.first.results[1].source_results.first.points
        end

        def test_double_points_for_last_event
          category = Models::Category.new("Women 4")
          rules = Rules.new(
            category_rules: [Models::CategoryRule.new(category)],
            double_points_for_last_event: true,
            points_for_place: [100, 75, 50, 20, 10]
          )
          calculator = Calculator.new(rules: rules, source_results: [])
          calculation_event_category = calculator.event_categories.first

          series = Models::Event.new(id: 0, date: Date.new(2018, 5, 1), end_date: Date.new(2018, 5, 8))
          series.add_child Models::Event.new(id: 1, date: Date.new(2018, 5, 1))
          series.add_child Models::Event.new(id: 2, date: Date.new(2018, 5, 8))

          event_category = Models::EventCategory.new(category, series.children[0])
          source_result = Models::SourceResult.new(id: 33, date: Date.new(2018, 5, 1), event_category: event_category, place: 1)
          participant = Models::Participant.new(0)
          result = Models::CalculatedResult.new(participant, [source_result])
          calculation_event_category.results << result

          event_category = Models::EventCategory.new(category, series.children[1])
          source_result = Models::SourceResult.new(id: 19, date: Date.new(2018, 5, 8), event_category: event_category, place: 2)
          participant = Models::Participant.new(1)
          result = Models::CalculatedResult.new(participant, [source_result])
          calculation_event_category.results << result

          event_categories = AssignPoints.calculate!(calculator)

          assert_equal 100, event_categories.first.results[0].source_results.first.points
          assert_equal 150, event_categories.first.results[1].source_results.first.points
        end

        def test_skip_rejected_categories
          category = Models::Category.new("Masters Men")
          rules = Rules.new(
            category_rules: [Models::CategoryRule.new(category)],
            points_for_place: [100, 75, 50, 20, 10]
          )
          calculator = Calculator.new(rules: rules, source_results: [])
          event_category = calculator.event_categories.first

          source_result = Models::SourceResult.new(id: 33, event_category: Models::EventCategory.new(category), place: 1)
          participant = Models::Participant.new(0)
          result = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result

          event_category.reject("nope")
          event_categories = AssignPoints.calculate!(calculator)

          assert_equal 0, event_categories.first.results[0].source_results.first.points
        end

        def test_points_for_place
          points_for_place = [100, 75, 50, 20, 10]
          event_category = Models::EventCategory.new(Models::Category.new("Masters Men"))

          source_result = Models::SourceResult.new(event_category: event_category, id: 0, place: "1")
          assert_equal 100, AssignPoints.points_for_place(source_result, points_for_place, "points", 1, 0)

          source_result = Models::SourceResult.new(event_category: event_category, id: 0, place: "5")
          assert_equal 10, AssignPoints.points_for_place(source_result, points_for_place, "points", 1, 1)

          source_result = Models::SourceResult.new(event_category: event_category, id: 0, place: "")
          assert_equal 0, AssignPoints.points_for_place(source_result, points_for_place, "points", 1, 2)

          source_result = Models::SourceResult.new(event_category: event_category, id: 0, place: nil)
          assert_equal 0, AssignPoints.points_for_place(source_result, points_for_place, "points", 1, 3)

          source_result = Models::SourceResult.new(event_category: event_category, id: 0, place: "6")
          assert_equal 0, AssignPoints.points_for_place(source_result, points_for_place, "points", 1, 4)

          source_result = Models::SourceResult.new(event_category: event_category, id: 0, place: "999999")
          assert_equal 0, AssignPoints.points_for_place(source_result, points_for_place, "points", 1, 5)

          source_result = Models::SourceResult.new(event_category: event_category, id: 0, place: "DNF")
          assert_equal 0, AssignPoints.points_for_place(source_result, points_for_place, "points", 1, 6)

          source_result = Models::SourceResult.new(event_category: event_category, id: 0, place: "DQ")
          assert_equal 0, AssignPoints.points_for_place(source_result, points_for_place, "points", 1, 7)

          source_result = Models::SourceResult.new(event_category: event_category, id: 0, place: "DNS")
          assert_equal 0, AssignPoints.points_for_place(source_result, points_for_place, "points", 1, 8)
        end

        def test_points_placed_by_place
          category = Models::Category.new("Masters Men")
          rules = Rules.new(
            category_rules: [Models::CategoryRule.new(category)],
            place_by: "place"
          )
          calculator = Calculator.new(rules: rules, source_results: [])
          event_category = calculator.event_categories.first

          event = Models::Event.new
          source_result = Models::SourceResult.new(id: 33, event_category: Models::EventCategory.new(category, event), place: 1)
          participant = Models::Participant.new(0)
          result = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result

          event = Models::Event.new
          source_result = Models::SourceResult.new(id: 19, event_category: Models::EventCategory.new(category, event), place: 2)
          participant = Models::Participant.new(1)
          result = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result

          event_categories = AssignPoints.calculate!(calculator)

          assert_equal 100, event_categories.first.results[0].source_results.first.points
          assert_equal 50, event_categories.first.results[1].source_results.first.points
        end
      end
    end
  end
end
