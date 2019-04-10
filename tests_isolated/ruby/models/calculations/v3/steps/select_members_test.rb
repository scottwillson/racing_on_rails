# frozen_string_literal: true

require_relative "../../v3"

module Calculations
  module V3
    module Steps
      # :stopdoc:
      class SelectMembersTest < Ruby::TestCase
        def test_calculate
          category = Models::Category.new("Women")
          rules = Rules.new(
            category_rules: [Models::CategoryRule.new(category)],
            members_only: true
          )
          calculator = Calculator.new(rules: rules, source_results: [])
          event_category = calculator.event_categories.first

          source_result = Models::SourceResult.new(id: 33, event_category: Models::EventCategory.new(category), place: 1, points: 100)
          membership = (Date.new(2018, 1, 1))..(Date.new(2018, 12, 31))
          participant = Models::Participant.new(1, membership: membership)
          result = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result

          event_categories = SelectMembers.calculate!(calculator)

          assert_equal 1, event_categories.first.results.size
          result = event_categories.first.results.first
          assert result.rejected?
          assert_equal :members_only, result.rejection_reason
        end

        def test_calculate_non_members_count
          category = Models::Category.new("Women")
          rules = Rules.new(
            category_rules: [Models::CategoryRule.new(category)],
            members_only: false
          )
          calculator = Calculator.new(rules: rules, source_results: [])
          event_category = calculator.event_categories.first

          source_result = Models::SourceResult.new(id: 33, event_category: Models::EventCategory.new(category), place: 1, points: 100)
          membership = (Date.new(2018, 1, 1))..(Date.new(2018, 12, 31))
          participant = Models::Participant.new(1, membership: membership)
          result = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result

          event_categories = SelectMembers.calculate!(calculator)

          assert_equal 1, event_categories.first.results.size
          result = event_categories.first.results.first
          refute result.rejected?
        end

        # TODO test different years
      end
    end
  end
end
