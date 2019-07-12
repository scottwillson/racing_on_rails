# frozen_string_literal: true

require_relative "../../v3"

module Calculations
  module V3
    module Steps
      # :stopdoc:
      class RejectCategoryWorstResultsTest < Ruby::TestCase
        def test_calculate
          category = Models::Category.new("Women")
          rules = Rules.new(place_by: "place")
          calculator = Calculator.new(rules: rules, source_results: [])

          participant = Models::Participant.new(0)
          event = Models::Event.new(id: 0, calculated: true)

          3.times do |ability|
            category = Models::Category.new("Women #{ability + 1}")
            20.times do |index|
              source_result = Models::SourceResult.new(
                id: ability * 20 + index,
                event_category: Models::EventCategory.new(category, event),
                participant: participant,
                place: index + 1
              )
              result = Models::CalculatedResult.new(participant, [source_result])
              calculator.event_categories.first.results << result
            end
          end

          event_categories = RejectCategoryWorstResults.calculate!(calculator)

          rejected_results = event_categories.flat_map(&:results).select(&:rejected?)
          assert_equal 4, rejected_results.size
          assert_equal [19, 19, 20, 20], rejected_results.map(&:source_result_numeric_place).sort
        end
      end
    end
  end
end
