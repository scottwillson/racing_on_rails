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
          assert results[4].rejected?
        end
      end
    end
  end
end
