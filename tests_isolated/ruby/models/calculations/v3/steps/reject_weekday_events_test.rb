# frozen_string_literal: true

require_relative "../../v3"

module Calculations
  module V3
    module Steps
      # :stopdoc:
      class RejectWeekdayEventsTest < Ruby::TestCase
        def test_calculate
          category = Models::Category.new("Women")
          rules = Rules.new(
            category_rules: [Models::CategoryRule.new(category)],
            weekday_events: false
          )
          calculator = Calculator.new(rules: rules, source_results: [])

          participant = Models::Participant.new(0)
          source_results = []

          event = Models::Event.new(id: 0, date: Date.new(2019, 3, 23))
          source_results << Models::SourceResult.new(
            id: 0,
            event_category: Models::EventCategory.new(category, event),
            participant: participant,
            place: 1,
            points: 100
          )

          event = Models::Event.new(id: 1, date: Date.new(2019, 3, 28))
          source_results << Models::SourceResult.new(
            id: 1,
            event_category: Models::EventCategory.new(category, event),
            participant: participant,
            place: 2,
            points: 50
          )

          result = Models::CalculatedResult.new(participant, source_results)
          calculator.event_categories.first.results << result

          event_categories = RejectWeekdayEvents.calculate!(calculator)

          source_results = event_categories.first.results.first.source_results.sort_by(&:id)

          refute source_results.first.rejected?

          assert source_results.last.rejected?
          assert_equal :weekday, source_results.last.rejection_reason
        end

        def test_include_specific_events
          category = Models::Category.new("Women")
          rules = Rules.new(
            calculations_events: [Models::Event.new(id: 1, date: Date.new(2019, 3, 28))],
            category_rules: [Models::CategoryRule.new(category)],
            weekday_events: false
          )
          calculator = Calculator.new(rules: rules, source_results: [])

          participant = Models::Participant.new(0)
          source_results = []

          event = Models::Event.new(id: 0, date: Date.new(2019, 3, 23))
          source_results << Models::SourceResult.new(
            id: 0,
            event_category: Models::EventCategory.new(category, event),
            participant: participant,
            place: 1,
            points: 100
          )

          event = Models::Event.new(id: 1, date: Date.new(2019, 3, 28))
          source_results << Models::SourceResult.new(
            id: 1,
            event_category: Models::EventCategory.new(category, event),
            participant: participant,
            place: 2,
            points: 50
          )

          result = Models::CalculatedResult.new(participant, source_results)
          calculator.event_categories.first.results << result

          event_categories = RejectWeekdayEvents.calculate!(calculator)

          source_results = event_categories.first.results.first.source_results.sort_by(&:id)

          refute source_results.first.rejected?
          refute source_results.last.rejected?
        end

        def test_include_series_overall
          category = Models::Category.new("Women")
          rules = Rules.new(
            category_rules: [Models::CategoryRule.new(category)],
            weekday_events: false
          )
          calculator = Calculator.new(rules: rules, source_results: [])

          participant = Models::Participant.new(0)
          source_results = []

          event = Models::Event.new(id: 0, calculated: true, date: Date.new(2019, 3, 22), end_date: Date.new(2019, 3, 29))
          event.add_child Models::Event.new(id: 1, date: Date.new(2019, 3, 22))
          event.add_child Models::Event.new(id: 2, date: Date.new(2019, 3, 29))
          source_results << Models::SourceResult.new(
            id: 0,
            event_category: Models::EventCategory.new(category, event),
            participant: participant,
            place: 1,
            points: 100
          )

          result = Models::CalculatedResult.new(participant, source_results)
          calculator.event_categories.first.results << result

          event_categories = RejectWeekdayEvents.calculate!(calculator)

          assert event_categories.first.results.none?(&:rejected?)
          source_result = event_categories.first.source_results.first
          refute source_result.rejected?, source_result.rejection_reason
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

        def test_omnium_or_stage_race
          event = Models::Event.new(id: 0, date: Date.new(2018, 6, 29))
          refute RejectWeekdayEvents.omnium_or_stage_race? event

          event = Models::Event.new(id: 0, date: Date.new(2018, 6, 22), end_date: Date.new(2018, 6, 29))
          event.add_child Models::Event.new(id: 1, date: Date.new(2018, 6, 22))
          event.add_child Models::Event.new(id: 2, date: Date.new(2018, 6, 29))
          refute RejectWeekdayEvents.omnium_or_stage_race? event

          event = Models::Event.new(id: 0, date: Date.new(2018, 6, 15), end_date: Date.new(2018, 6, 29))
          event.add_child Models::Event.new(id: 1, date: Date.new(2018, 6, 15))
          event.add_child Models::Event.new(id: 2, date: Date.new(2018, 6, 22))
          event.add_child Models::Event.new(id: 3, date: Date.new(2018, 6, 29))
          refute RejectWeekdayEvents.omnium_or_stage_race? event

          event = Models::Event.new(id: 0, date: Date.new(2018, 6, 30), end_date: Date.new(2018, 7, 1))
          event.add_child Models::Event.new(id: 3, date: Date.new(2018, 6, 30))
          event.add_child Models::Event.new(id: 4, date: Date.new(2018, 7, 1))
          assert RejectWeekdayEvents.omnium_or_stage_race? event

          event = Models::Event.new(id: 0, date: Date.new(2018, 6, 29), end_date: Date.new(2018, 7, 1))
          event.add_child Models::Event.new(id: 1, date: Date.new(2018, 6, 29))
          event.add_child Models::Event.new(id: 2, date: Date.new(2018, 6, 29))
          event.add_child Models::Event.new(id: 3, date: Date.new(2018, 6, 30))
          event.add_child Models::Event.new(id: 4, date: Date.new(2018, 7, 1))
          assert RejectWeekdayEvents.omnium_or_stage_race? event
        end
      end
    end
  end
end
