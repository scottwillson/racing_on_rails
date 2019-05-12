# frozen_string_literal: true

require_relative "../../v3"

module Calculations
  module V3
    module Steps
      # :stopdoc:
      class RejectCalculatedEventsTest < Ruby::TestCase
        def test_calculate
          category = Models::Category.new("Women")
          rules = Rules.new(category_rules: [Models::CategoryRule.new(category)])
          calculator = Calculator.new(rules: rules, source_results: [])

          participant = Models::Participant.new(0)
          event = Models::Event.new(id: 0, calculated: true)

          source_result = Models::SourceResult.new(
            id: 0,
            event_category: Models::EventCategory.new(category, event),
            participant: participant,
            place: 1,
            points: 100
          )
          result = Models::CalculatedResult.new(participant, [source_result])
          calculator.event_categories.first.results << result

          event_categories = RejectCalculatedEvents.calculate!(calculator)

          source_result = event_categories.first.results.first.source_results.first
          assert source_result.rejected?
          assert_equal :calculated, source_result.rejection_reason
        end

        def test_stage_race
          category = Models::Category.new("Women")
          rules = Rules.new(
            category_rules: [Models::CategoryRule.new(category)],
            weekday_events: false
          )
          calculator = Calculator.new(rules: rules, source_results: [])

          participant = Models::Participant.new(0)
          source_results = []

          parent = Models::Event.new(id: 0, calculated: true, date: Date.new(2018, 6, 29), end_date: Date.new(2018, 7, 1))
          source_results << Models::SourceResult.new(
            id: 4,
            event_category: Models::EventCategory.new(category, parent),
            participant: participant
          )

          event = Models::Event.new(id: 1, date: Date.new(2018, 6, 29))
          parent.add_child event
          source_results << Models::SourceResult.new(
            id: 0,
            event_category: Models::EventCategory.new(category, event),
            participant: participant
          )

          event = Models::Event.new(id: 2, date: Date.new(2018, 6, 29))
          parent.add_child event
          source_results << Models::SourceResult.new(
            id: 1,
            event_category: Models::EventCategory.new(category, event),
            participant: participant
          )

          event = Models::Event.new(id: 3, date: Date.new(2018, 6, 30))
          parent.add_child event
          source_results << Models::SourceResult.new(
            id: 2,
            event_category: Models::EventCategory.new(category, event),
            participant: participant
          )

          event = Models::Event.new(id: 4, date: Date.new(2018, 7, 1))
          parent.add_child event
          source_results << Models::SourceResult.new(
            id: 3,
            event_category: Models::EventCategory.new(category, event),
            participant: participant
          )

          result = Models::CalculatedResult.new(participant, source_results)
          calculator.event_categories.first.results << result

          event_categories = RejectWeekdayEvents.calculate!(calculator)

          rejected_events = event_categories.first.source_results.select(&:rejected?).map(&:id).sort
          assert_equal [], rejected_events
        end
      end
    end
  end
end
