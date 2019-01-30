# frozen_string_literal: true

require_relative "../../v3"

module Calculations
  module V3
    module Models
      # :stopdoc:
      class CategoryTest < Ruby::TestCase
        def test_initialize
          category = Category.new("Women")
          assert_equal "Women", category.name
        end
      end
    end
  end
end
