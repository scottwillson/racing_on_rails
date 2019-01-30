# frozen_string_literal: true

require_relative "../v3"

module Calculations
  module V3
    # :stopdoc:
    class RulesTest < Ruby::TestCase
      def test_new
        categories = [Models::Category.new("Masters Men")]

        rules = Rules.new(categories: categories)

        assert_nil rules.points_for_place
        assert_equal categories, rules.categories
      end
    end
  end
end
