# frozen_string_literal: true

require_relative "../../v3"

module Calculations
  module V3
    module Steps
      # :stopdoc:
      class RejectEmptySourceResultsTest < Ruby::TestCase
        def test_calculate
          category = Models::Category.new("Women")
          rules = Rules.new
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

          event_categories = RejectEmptySourceResults.calculate!(calculator)

          assert event_categories.first.results.present?
        end

        def test_reject
          category = Models::Category.new("Women")
          rules = Rules.new
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

          result.source_results.pop

          event_categories = RejectEmptySourceResults.calculate!(calculator)

          assert event_categories.first.results.empty?
        end
      end
    end
  end
end
