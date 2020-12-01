# frozen_string_literal: true

require_relative "../v3"

module Calculations
  module V3
    # :stopdoc:
    class RulesTest < Ruby::TestCase
      def test_new
        category = Models::Category.new("Masters Men")

        rules = Rules.new(category_rules: [Models::CategoryRule.new(category)])

        assert_nil rules.points_for_place
        assert_equal [category], rules.categories
      end
    end
  end
end
