# frozen_string_literal: true

require_relative "../../v3"

module Calculations
  module V3
    module Steps
      # :stopdoc:
      class RejectCalculatedEventCategoriesTest < Ruby::TestCase
        def test_no_calculations
          category = Models::Category.new("Women")
          rules = Rules.new(category_rules: [Models::CategoryRule.new(category)])
          calculator = Calculator.new(rules: rules, source_results: [])

          participant = Models::Participant.new(0)
          event = Models::Event.new(id: 0)

          source_result = Models::SourceResult.new(
            id: 0,
            event_category: Models::EventCategory.new(category, event),
            participant: participant,
            place: 1,
            points: 100
          )
          result = Models::CalculatedResult.new(participant, [source_result])
          calculator.event_categories.first.results << result

          RejectCalculatedEventCategories.calculate!(calculator)

          calculator.results.none?(&:rejected?)
        end

        def test_multiple_results_same_participant
          women = Models::Category.new("Women")
          singlespeed = Models::Category.new("Singlespeed")
          rules = Rules.new(
            category_rules: [
                              Models::CategoryRule.new(singlespeed),
                              Models::CategoryRule.new(women)
            ]
          )
          calculator = Calculator.new(rules: rules, source_results: [])

          participant = Models::Participant.new(0)
          event = Models::Event.new(id: 0)

          source_result = Models::SourceResult.new(
            id: 0,
            event_category: Models::EventCategory.new(singlespeed, event),
            participant: participant,
            place: 1
          )
          result = Models::CalculatedResult.new(participant, [source_result])
          calculator.event_categories.first.results << result

          source_result = Models::SourceResult.new(
            id: 1,
            event_category: Models::EventCategory.new(women, event),
            participant: participant,
            place: 1
          )
          result = Models::CalculatedResult.new(participant, [source_result])
          calculator.event_categories.last.results << result

          RejectCalculatedEventCategories.calculate!(calculator)

          calculator.results.none?(&:rejected?)
        end
      end
    end
  end
end
