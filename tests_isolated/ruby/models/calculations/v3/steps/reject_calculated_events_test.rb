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
          event_category = calculator.event_categories.first.results << result

          event_categories = RejectCalculatedEvents.calculate!(calculator)

          source_result = event_categories.first.results.first.source_results.first
          assert source_result.rejected?
          assert_equal :calculated, source_result.rejection_reason
        end
      end
    end
  end
end
