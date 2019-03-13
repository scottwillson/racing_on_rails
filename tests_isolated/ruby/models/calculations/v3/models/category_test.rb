# frozen_string_literal: true

require_relative "../../v3"
require_relative "./equality_assertion"

module Calculations
  module V3
    module Models
      # :stopdoc:
      class CategoryTest < Ruby::TestCase
        include EqualityAssertion

        def test_initialize
          category = Category.new("Women")
          assert_equal "Women", category.name
        end

        def test_equality
          a = Category.new("Women")
          b = Category.new("Women")
          c = Category.new("Women")
          d = Category.new("Men")

          assert_equality a, b, c, d
        end
      end
    end
  end
end
