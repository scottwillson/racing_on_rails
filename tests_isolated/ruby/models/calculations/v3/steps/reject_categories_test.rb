# frozen_string_literal: true

require_relative "../../v3"

module Calculations
  module V3
    module Steps
      # :stopdoc:
      class RejectCategoriesTest < Ruby::TestCase
        def test_calculate
          category = Models::Category.new("Junior Men 3/4/5")
          rejected_category = Models::Category.new("Junior Men 9-12 3/4/5")
          rules = Rules.new(categories: [category], rejected_categories: [rejected_category])
          calculator = Calculator.new(rules: rules, source_results: [])

          event_category = calculator.event_categories.first

          participant = Models::Participant.new(0)
          source_results = [
            Models::SourceResult.new(id: 0, event_category: Models::EventCategory.new(rejected_category), place: 1, points: 100),
            Models::SourceResult.new(id: 33, event_category: Models::EventCategory.new(category), place: 1, points: 100)
          ]
          result = Models::CalculatedResult.new(participant, source_results)
          event_category.results << result

          event_categories = RejectCategories.calculate!(calculator)

          result = event_categories.first.results.first

          source_result = result.source_results.find { |r| r.id == 0 }
          assert source_result.rejected?

          source_result = result.source_results.find { |r| r.id == 33 }
          refute source_result.rejected?
        end
      end
    end
  end
end
