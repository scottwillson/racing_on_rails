# frozen_string_literal: true

require_relative "../../v3"

module Calculations
  module V3
    module Steps
      # :stopdoc:
      class RejectBelowMinimumEventsTest < Ruby::TestCase
        def test_calculate
          category = Models::Category.new("Women")
          rules = Rules.new(categories: [category], minimum_events: 3)
          calculator = Calculator.new(rules: rules, source_results: [])
          event_category = calculator.event_categories.first

          participant = Models::Participant.new(0)
          source_results = [
            Models::SourceResult.new(id: 0, event_category: Models::EventCategory.new(category), place: 1, points: 100),
            Models::SourceResult.new(id: 33, event_category: Models::EventCategory.new(category), place: 1, points: 100)
          ]
          result = Models::CalculatedResult.new(participant, source_results)
          event_category.results << result

          event_categories = RejectBelowMinimumEvents.calculate!(calculator)

          assert event_categories.first.results.first.rejected?
          assert_equal :below_minimum_events, event_categories.first.results.first.rejection_reason
        end

        def test_dnfs_dont_count
          category = Models::Category.new("Women")
          rules = Rules.new(categories: [category], minimum_events: 3)
          calculator = Calculator.new(rules: rules, source_results: [])
          event_category = calculator.event_categories.first

          participant = Models::Participant.new(0)
          rejected_result = Models::SourceResult.new(id: 35, event_category: Models::EventCategory.new(category), place: "DNF", points: 0)
          rejected_result.reject(:dnf)
          source_results = [
            Models::SourceResult.new(id: 0, event_category: Models::EventCategory.new(category), place: 1, points: 100),
            Models::SourceResult.new(id: 33, event_category: Models::EventCategory.new(category), place: 1, points: 100)
          ]
          result = Models::CalculatedResult.new(participant, source_results)
          event_category.results << result

          event_categories = RejectBelowMinimumEvents.calculate!(calculator)

          assert event_categories.first.results.first.rejected?
          assert_equal :below_minimum_events, event_categories.first.results.first.rejection_reason
        end
      end
    end
  end
end
