# frozen_string_literal: true

require_relative "../../v3"

module Calculations
  module V3
    module Steps
      # :stopdoc:
      class RejectWorstResultsTest < Ruby::TestCase
        def test_calculate
          category = Models::Category.new("Women")
          rules = Rules.new(
            categories: [category],
            points_for_place: [100, 75, 50, 20, 10]
          )
          calculator = Calculator.new(rules: rules, source_results: [])
          event_category = calculator.event_categories.first

          source_result = Models::SourceResult.new(id: 33, event_category: Models::EventCategory.new(category), place: 1, points: 100)
          participant = Models::Participant.new(0)
          result = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result

          source_result = Models::SourceResult.new(id: 19, event_category: Models::EventCategory.new(category), place: 2, points: 75)
          participant = Models::Participant.new(1)
          result = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result

          event_categories = RejectWorstResults.calculate!(calculator)

          assert_equal 100, event_categories.first.results[0].source_results.first.points
          refute event_categories.first.results[0].source_results.first.rejected?

          assert_equal 75, event_categories.first.results[1].source_results.first.points
          refute event_categories.first.results[1].source_results.first.rejected?
        end

        def test_reject_worst_results
          category = Models::Category.new("Women")

          series = Models::Event.new(id: 0, date: Date.new(2018, 5, 1), end_date: Date.new(2018, 5, 8))
          series.add_child Models::Event.new(id: 1, date: Date.new(2018, 5, 1))
          series.add_child Models::Event.new(id: 2, date: Date.new(2018, 5, 8))

          rules = Rules.new(
            categories: [category],
            source_events: series.children,
            reject_worst_results: 1,
            points_for_place: [100, 75, 50, 20, 10]
          )
          calculator = Calculator.new(rules: rules, source_results: [])
          calculation_event_category = calculator.event_categories.first

          event_category = Models::EventCategory.new(category, series.children[0])
          source_result = Models::SourceResult.new(id: 33, date: Date.new(2018, 5, 1), event_category: event_category, place: 1, points: 100)

          event_category = Models::EventCategory.new(category, series.children[1])
          source_result_2 = Models::SourceResult.new(id: 19, date: Date.new(2018, 5, 8), event_category: event_category, place: 2, points: 75)

          participant = Models::Participant.new(0)
          result = Models::CalculatedResult.new(participant, [source_result, source_result_2])
          calculation_event_category.results << result

          event_categories = RejectWorstResults.calculate!(calculator)
          source_results = event_categories.first.results.first.source_results.sort_by(&:place)

          assert_equal 100, source_results.first.points
          refute source_results.first.rejected?

          assert_equal 0, source_results[1].points
          assert source_results[1].rejected?
          assert_equal :worse_result, source_results[1].rejection_reason
        end

        def test_reject_worst_results_by_category
          women = Models::Category.new("Women")
          women_4 = Models::Category.new("Women 4")

          series = Models::Event.new(id: 0, date: Date.new(2018, 5, 1), end_date: Date.new(2018, 5, 15))
          series.add_child Models::Event.new(id: 1, date: Date.new(2018, 5, 1))
          series.add_child Models::Event.new(id: 2, date: Date.new(2018, 5, 8))
          series.add_child Models::Event.new(id: 3, date: Date.new(2018, 5, 15))

          rules = Rules.new(
            categories: [women, women_4],
            source_events: series.children,
            reject_worst_results: 1,
            points_for_place: [100, 75, 50, 20, 10]
          )
          calculator = Calculator.new(rules: rules, source_results: [])

          event_category = Models::EventCategory.new(women, series.children[0])
          source_result = Models::SourceResult.new(id: 33, date: Date.new(2018, 5, 1), event_category: event_category, place: 1, points: 100)

          event_category = Models::EventCategory.new(women, series.children[1])
          source_result_2 = Models::SourceResult.new(id: 19, date: Date.new(2018, 5, 8), event_category: event_category, place: 3, points: 50)

          event_category = Models::EventCategory.new(women, series.children[2])
          source_result_3 = Models::SourceResult.new(id: 20, date: Date.new(2018, 5, 15), event_category: event_category, place: 2, points: 75)

          participant = Models::Participant.new(0)
          result = Models::CalculatedResult.new(participant, [source_result, source_result_2, source_result_3])
          calculator.event_categories.first.results << result

          # No May 1 Women 4 race
          event_category = Models::EventCategory.new(women_4, series.children[1])
          source_result = Models::SourceResult.new(id: 22, date: Date.new(2018, 5, 8), event_category: event_category, place: 3, points: 50)

          event_category = Models::EventCategory.new(women_4, series.children[2])
          source_result_2 = Models::SourceResult.new(id: 25, date: Date.new(2018, 5, 15), event_category: event_category, place: 2, points: 75)

          participant = Models::Participant.new(1)
          result = Models::CalculatedResult.new(participant, [source_result, source_result_2])
          calculator.event_categories.last.results << result

          event_categories = RejectWorstResults.calculate!(calculator)
          results = event_categories.detect { |ec| ec.category == women }.results
          source_results = results.first.source_results.sort_by(&:place)

          assert_equal 100, source_results.first.points
          refute source_results.first.rejected?

          assert_equal 0, source_results[2].points
          assert source_results[2].rejected?
          assert_equal :worse_result, source_results[2].rejection_reason

          results = event_categories.detect { |ec| ec.category == women_4 }.results
          source_results = results.first.source_results.sort_by(&:place)

          assert_equal 75, source_results.first.points
          refute source_results.first.rejected?

          assert_equal 0, source_results[1].points
          assert source_results[1].rejected?
          assert_equal :worse_result, source_results[1].rejection_reason
        end

        def test_reject_no_points
          category = Models::Category.new("Women")
          source_result = Models::SourceResult.new(id: 0, event_category: Models::EventCategory.new(category), points: 0)
          source_result.reject(:not_calculation_category)
          result = Models::CalculatedResult.new(Models::Participant.new(0), [source_result])
          RejectWorstResults.reject_worst_results(result, 7)
          assert result.source_results.first.rejected?
        end

        def test_single_result
          category = Models::Category.new("Women")
          source_result = Models::SourceResult.new(id: 0, event_category: Models::EventCategory.new(category), points: 10, place: 7)
          result = Models::CalculatedResult.new(Models::Participant.new(0), [source_result])
          RejectWorstResults.reject_worst_results(result, 7)
          refute result.source_results.first.rejected?
        end

        def test_maximum_results
          category = Models::Category.new("Women")
          source_results = []
          source_results << Models::SourceResult.new(id: 0, event_category: Models::EventCategory.new(category), points: 10, place: 7)
          source_results << Models::SourceResult.new(id: 1, event_category: Models::EventCategory.new(category), points: 5, place: 9)
          source_results << Models::SourceResult.new(id: 2, event_category: Models::EventCategory.new(category), points: 30, place: 1)
          source_results << Models::SourceResult.new(id: 3, event_category: Models::EventCategory.new(category), points: 20, place: 2)
          result = Models::CalculatedResult.new(Models::Participant.new(0), source_results)
          RejectWorstResults.reject_worst_results(result, 4)
          assert result.source_results.none?(&:rejected?)
        end

        def test_over_maximum
          category = Models::Category.new("Women")
          source_results = []
          source_results << Models::SourceResult.new(id: 0, event_category: Models::EventCategory.new(category), points: 10, place: 7)
          source_results << Models::SourceResult.new(id: 1, event_category: Models::EventCategory.new(category), points: 5, place: 9)
          source_results << Models::SourceResult.new(id: 2, event_category: Models::EventCategory.new(category), points: 30, place: 1)
          source_results << Models::SourceResult.new(id: 3, event_category: Models::EventCategory.new(category), points: 20, place: 2)
          result = Models::CalculatedResult.new(Models::Participant.new(0), source_results)

          RejectWorstResults.reject_worst_results(result, 3)

          source_results = result.source_results.sort_by(&:id)
          refute source_results[0].rejected?
          assert source_results[1].rejected?
          refute source_results[2].rejected?
          refute source_results[3].rejected?
        end

        def test_many_over_maximum
          category = Models::Category.new("Women")
          source_results = []
          source_results << Models::SourceResult.new(id: 0, event_category: Models::EventCategory.new(category), points: 10, place: 7)
          source_results << Models::SourceResult.new(id: 1, event_category: Models::EventCategory.new(category), points: 5, place: 9)
          source_results << Models::SourceResult.new(id: 2, event_category: Models::EventCategory.new(category), points: 30, place: 1)
          source_results << Models::SourceResult.new(id: 3, event_category: Models::EventCategory.new(category), points: 20, place: 2)
          source_results << Models::SourceResult.new(id: 4, event_category: Models::EventCategory.new(category), points: 12, place: 2)
          result = Models::CalculatedResult.new(Models::Participant.new(0), source_results)

          RejectWorstResults.reject_worst_results(result, 3)

          source_results = result.source_results.sort_by(&:id)
          assert source_results[0].rejected?
          assert source_results[1].rejected?
          refute source_results[2].rejected?
          refute source_results[3].rejected?
          refute source_results[4].rejected?
        end

        def test_points_not_place
          category = Models::Category.new("Women")
          source_results = []
          source_results << Models::SourceResult.new(id: 0, event_category: Models::EventCategory.new(category), points: 10, place: 1)
          source_results << Models::SourceResult.new(id: 1, event_category: Models::EventCategory.new(category), points: 50, place: 2)
          source_results << Models::SourceResult.new(id: 2, event_category: Models::EventCategory.new(category), points: 30, place: 4)
          source_results << Models::SourceResult.new(id: 3, event_category: Models::EventCategory.new(category), points: 20, place: 1)
          result = Models::CalculatedResult.new(Models::Participant.new(0), source_results)

          RejectWorstResults.reject_worst_results(result, 3)

          source_results = result.source_results.sort_by(&:id)
          assert source_results[0].rejected?
          refute source_results[1].rejected?
          refute source_results[2].rejected?
          refute source_results[3].rejected?
        end
      end
    end
  end
end
