# frozen_string_literal: true

require_relative "../../v3"

module Calculations
  module V3
    module Steps
      # :stopdoc:
      class RejectMoreThanResultsPerEventTest < Ruby::TestCase
        def test_calculate
          rules = Rules.new(
            points_for_place: [100, 75, 50, 20, 10],
            results_per_event: 3,
            team: true
          )
          calculator = Calculator.new(rules: rules, source_results: [])
          event_category = calculator.event_categories.first

          category = Models::Category.new("Women")
          participant = Models::Participant.new(0)
          event = Models::Event.new(id: 0)
          source_event_category = Models::EventCategory.new(category, event)

          4.times do |index|
            source_result = Models::SourceResult.new(
              id: index,
              event_category: source_event_category,
              participant: participant,
              place: 5 - index
            )
            result = Models::CalculatedResult.new(participant, [source_result])
            event_category.results << result
          end

          source_result = Models::SourceResult.new(
            id: 4,
            event_category: source_event_category,
            participant: participant,
            place: "DNF"
          )
          result = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result

          event_categories = RejectMoreThanResultsPerEvent.calculate!(calculator)
          results = event_categories.first.source_results.sort_by(&:id)
          assert_equal [0, 1, 2, 3, 4], results.map(&:id)

          assert results[0].rejected?
          assert_equal :results_per_event, results[0].rejection_reason
          assert !results[1].rejected?
          assert !results[2].rejected?
          assert !results[3].rejected?
          assert !results[4].rejected?
        end

        def test_do_not_reject_unplaced
          category_pro_1_2 = Models::Category.new("Category Pro/1/2 Women")
          category_rules = [
            Models::CategoryRule.new(category_pro_1_2)
          ]
          rules = Rules.new(
            category_rules: category_rules,
            results_per_event: 1
          )
          calculator = Calculator.new(rules: rules, source_results: [])
          event_category = calculator.event_categories.first

          participant = Models::Participant.new(0)
          cyclocross_bar = Models::Event.new(id: 10)
          source_event_category = Models::EventCategory.new(category_pro_1_2, cyclocross_bar)
          source_results = []
          source_results << Models::SourceResult.new(
            id: 100,
            event_category: source_event_category,
            participant: participant,
            place: 6,
            points: 295
          )

          gravel_bar = Models::Event.new(id: 11)
          source_event_category = Models::EventCategory.new(category_pro_1_2, gravel_bar)
          source_results << Models::SourceResult.new(
            id: 101,
            event_category: source_event_category,
            participant: participant,
            place: 11,
            points: 290
          )

          category_1_women = Models::Category.new("Category 1 Women")
          mtb_bar = Models::Event.new(id: 12)
          source_event_category = Models::EventCategory.new(category_1_women, mtb_bar)
          source_results << Models::SourceResult.new(
            id: 102,
            event_category: source_event_category,
            participant: participant,
            place: 12,
            points: 289
          )

          category_2_women = Models::Category.new("Category 2 Women")
          source_event_category = Models::EventCategory.new(category_2_women, mtb_bar)
          source_results << Models::SourceResult.new(
            id: 103,
            event_category: source_event_category,
            participant: participant,
            place: nil,
            points: 0
          )

          tt_bar = Models::Event.new(id: 13)
          source_event_category = Models::EventCategory.new(category_pro_1_2, tt_bar)
          source_results << Models::SourceResult.new(
            id: 104,
            event_category: source_event_category,
            participant: participant,
            place: nil,
            points: 0
          )

          road_bar = Models::Event.new(id: 14)
          source_event_category = Models::EventCategory.new(category_pro_1_2, road_bar)
          source_results << Models::SourceResult.new(
            id: 105,
            event_category: source_event_category,
            participant: participant,
            place: nil,
            points: 0
          )

          result = Models::CalculatedResult.new(participant, source_results)
          event_category.results << result

          event_categories = RejectMoreThanResultsPerEvent.calculate!(calculator)
          results = event_categories.first.source_results.sort_by(&:id)
          assert_equal [100, 101, 102, 103, 104, 105], results.map(&:id)

          assert !results[0].rejected?
          assert !results[1].rejected?
          assert !results[2].rejected?
          assert !results[3].rejected?
          assert !results[4].rejected?
          assert !results[5].rejected?
        end

        def test_bar
          category_pro_1_2 = Models::Category.new("Category Pro/1/2 Women")
          category_3 = Models::Category.new("Category 3 Women")
          category_rules = [
            Models::CategoryRule.new(category_pro_1_2),
            Models::CategoryRule.new(category_3)
          ]
          rules = Rules.new(
            category_rules: category_rules,
            results_per_event: 1
          )
          calculator = Calculator.new(rules: rules, source_results: [])
          pro_1_2_event_category = calculator.event_categories.detect { |ec| ec.category == category_pro_1_2 }
          women_3_event_category = calculator.event_categories.detect { |ec| ec.category == category_3 }

          participant = Models::Participant.new(0)
          gravel_bar = Models::Event.new(id: 10)
          source_event_category = Models::EventCategory.new(category_pro_1_2, gravel_bar)
          source_results = []
          source_results << Models::SourceResult.new(
            id: 100,
            event_category: source_event_category,
            participant: participant,
            place: 19,
            points: 282
          )

          elite_women = Models::Category.new("Elite Women")
          mtb_bar = Models::Event.new(id: 11)
          source_event_category = Models::EventCategory.new(elite_women, mtb_bar)
          source_results << Models::SourceResult.new(
            id: 101,
            event_category: source_event_category,
            participant: participant,
            place: 15,
            points: 286
          )

          category_2_women = Models::Category.new("Category 2 Women")
          stxc_bar = Models::Event.new(id: 12)
          source_event_category = Models::EventCategory.new(category_2_women, stxc_bar)
          source_results << Models::SourceResult.new(
            id: 102,
            event_category: source_event_category,
            participant: participant,
            place: 1,
            points: 300
          )

          cx_bar = Models::Event.new(id: 13)
          source_event_category = Models::EventCategory.new(category_pro_1_2, cx_bar)
          source_results << Models::SourceResult.new(
            id: 103,
            event_category: source_event_category,
            participant: participant,
            place: 3,
            points: 297
          )

          road_bar = Models::Event.new(id: 14)
          source_event_category = Models::EventCategory.new(category_pro_1_2, road_bar)
          source_results << Models::SourceResult.new(
            id: 104,
            event_category: source_event_category,
            participant: participant,
            place: 27,
            points: 273
          )

          result = Models::CalculatedResult.new(participant, source_results)
          pro_1_2_event_category.results << result

          source_results = []
          source_event_category = Models::EventCategory.new(category_3, road_bar)
          source_results << Models::SourceResult.new(
            id: 105,
            event_category: source_event_category,
            participant: participant,
            place: 2,
            points: 299
          )

          result = Models::CalculatedResult.new(participant, source_results)
          women_3_event_category.results << result

          event_categories = RejectMoreThanResultsPerEvent.calculate!(calculator)

          event_category = event_categories.detect { |ec| ec.category == pro_1_2_event_category }
          rejected_results = event_category.source_results.select(&:rejected?)
          assert rejected_results.empty?, "Results #{rejected_results.map(&:id)} were rejected"

          event_category = event_categories.detect { |ec| ec.category == category_3 }
          assert event_category.source_results.none?(&:rejected?)
        end
      end
    end
  end
end
