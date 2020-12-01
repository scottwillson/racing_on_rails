# frozen_string_literal: true

require_relative "../../v3"

module Calculations
  module V3
    module Steps
      # :stopdoc:
      class AssignPointsTest < Ruby::TestCase
        def test_calculate
          category = Models::Category.new("Masters Men")
          rules = Rules.new
          calculator = Calculator.new(rules: rules, source_results: [])
          event_category = calculator.event_categories.first

          event = Models::Event.new(id: 0)
          source_event_category = Models::EventCategory.new(category, event)
          source_result = Models::SourceResult.new(id: 33, event_category: source_event_category, place: 1)
          participant = Models::Participant.new(0)
          result = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result

          source_result = Models::SourceResult.new(id: 19, event_category: source_event_category, place: 1)
          participant = Models::Participant.new(1)
          result = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result

          source_result = Models::SourceResult.new(id: 21, event_category: source_event_category, place: 1)
          participant = Models::Participant.new(2)
          result = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result

          source_result = Models::SourceResult.new(id: 22, event_category: source_event_category, place: 2)
          participant = Models::Participant.new(3)
          result = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result

          source_result = Models::SourceResult.new(id: 23, event_category: source_event_category, place: 2)
          participant = Models::Participant.new(4)
          result = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result

          event_categories = AssignTeamSizes.calculate!(calculator)

          source_results = event_categories.first.results.flat_map(&:source_results)
          assert_equal [3, 3, 3, 2, 2], source_results.map(&:team_size)
        end
      end
    end
  end
end
