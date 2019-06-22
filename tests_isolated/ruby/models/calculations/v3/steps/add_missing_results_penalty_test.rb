# frozen_string_literal: true

require_relative "../../v3"

module Calculations
  module V3
    module Steps
      # :stopdoc:
      class AddMissingResultsPenaltyTest < Ruby::TestCase
        def test_calculate
          category = Models::Category.new("Women")
          rules = Rules.new
          calculator = Calculator.new(rules: rules, source_results: [])
          event_category = calculator.event_categories.first

          parent = Models::Event.new(id: 0, date: Date.new(2019, 3, 23))
          event = Models::Event.new(id: 1, date: Date.new(2019, 3, 23))
          parent.add_child event
          participant = Models::Participant.new(0)
          source_results = [
            Models::SourceResult.new(id: 0, event_category: Models::EventCategory.new(category, event), participant: participant, place: 1, points: 100),
            Models::SourceResult.new(id: 33, event_category: Models::EventCategory.new(category, event), participant: participant, place: 1, points: 100)
          ]
          result = Models::CalculatedResult.new(participant, source_results)
          event_category.results << result

          event_categories = AddMissingResultsPenalty.calculate!(calculator)

          assert_equal 1, event_categories.first.results.size
        end

        def test_add_penalty
          category = Models::Category.new("Women")
          rules = Rules.new(missing_result_penalty: true, results_per_event: 10)
          calculator = Calculator.new(rules: rules, source_results: [])
          event_category = calculator.event_categories.first

          parent = Models::Event.new(id: 0, date: Date.new(2019, 3, 23))
          event = Models::Event.new(id: 1, date: Date.new(2019, 3, 23))
          parent.add_child event
          participant = Models::Participant.new(0)
          source_results = [
            Models::SourceResult.new(id: 0, event_category: Models::EventCategory.new(category, event), participant: participant, place: 1, points: 100),
            Models::SourceResult.new(id: 33, event_category: Models::EventCategory.new(category, event), participant: participant, place: 1, points: 100)
          ]
          result = Models::CalculatedResult.new(participant, source_results)
          event_category.results << result

          event_categories = AddMissingResultsPenalty.calculate!(calculator)

          assert_equal 1, event_categories.first.results.size
          assert_equal 3, event_categories.first.results.first.source_results.size
        end
      end
    end
  end
end
