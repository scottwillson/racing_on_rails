# frozen_string_literal: true

require_relative "../../v3"

module Calculations
  module V3
    module Steps
      # :stopdoc:
      class SelectInDisciplineTest < Ruby::TestCase
        def test_calculate
          cx = Models::Discipline.new("Cyclocross")
          road = Models::Discipline.new("Road")
          rules = Rules.new(disciplines: [road])
          calculator = Calculator.new(rules: rules, source_results: [])
          calculation_event_category = calculator.event_categories.first
          source_results = []

          event = Models::Event.new(discipline: road)
          category = Models::Category.new("Women")
          event_category = Models::EventCategory.new(category, event)
          participant = Models::Participant.new(0)
          source_results << Models::SourceResult.new(id: 1, event_category: event_category)

          event = Models::Event.new(discipline: cx)
          event_category = Models::EventCategory.new(category, event)
          source_results << Models::SourceResult.new(id: 2, event_category: event_category)

          result = Models::CalculatedResult.new(participant, source_results)
          calculation_event_category.results << result

          event_categories = SelectInDiscipline.calculate!(calculator)

          assert_equal 1, event_categories.first.results.size
          source_results = event_categories.first.results.first.source_results.sort_by(&:id)
          assert_equal 2, source_results.size

          refute source_results[0].rejected?
          assert_nil source_results[0].rejection_reason

          assert source_results[1].rejected?
          assert_equal :discipline, source_results[1].rejection_reason
        end
      end
    end
  end
end
