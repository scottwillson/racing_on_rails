# frozen_string_literal: true

require_relative "../../v3"

module Calculations
  module V3
    module Steps
      # :stopdoc:
      class RejectNoParticipantTest < Ruby::TestCase
        def test_calculate
          category = Models::Category.new("Women")
          rules = Rules.new(categories: [category])
          calculator = Calculator.new(rules: rules, source_results: [])
          event_category = calculator.event_categories.first

          source_result = Models::SourceResult.new(id: 33, event_category: Models::EventCategory.new(category), place: 1, points: 100)
          participant = Models::Participant.new(nil)
          result = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result

          event_categories = RejectNoParticipant.calculate!(calculator)

          assert event_categories.first.results.empty?
        end
      end
    end
  end
end
