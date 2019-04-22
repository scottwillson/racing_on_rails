# frozen_string_literal: true

require_relative "../../v3"

module Calculations
  module V3
    module Steps
      # :stopdoc:
      class SelectAssociationSanctionedTest < Ruby::TestCase
        def test_calculate
          category = Models::Category.new("Women")
          rules = Rules.new(
            association: Models::Association.new(id: 2),
            category_rules: [Models::CategoryRule.new(category)]
          )
          calculator = Calculator.new(rules: rules, source_results: [])
          event_category = calculator.event_categories.first

          event = Models::Event.new(sanctioned_by: Models::Association.new(id: 3))
          source_result = Models::SourceResult.new(id: 33, event_category: Models::EventCategory.new(category, event), place: 1, points: 100)
          participant = Models::Participant.new(1)
          result = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result

          event_categories = SelectAssociationSanctioned.calculate!(calculator)

          source_result = event_categories.first.results.first.source_results.first
          assert source_result.rejected?
          assert_equal :sanctioned_by, source_result.rejection_reason
        end
      end
    end
  end
end
