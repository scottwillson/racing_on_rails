# frozen_string_literal: true

require_relative "../v3"

module Calculations
  module V3
    # :stopdoc:
    class CalculatorTest < Ruby::TestCase
      def test_initialize
        Calculator.new
      end

      def test_calculate
        calculator = Calculator.new
        calculator.calculate!
      end

      def test_map_categories_to_event_categories
        categories = [Models::Category.new("Masters Men")]
        rules = Rules.new(categories: categories)
        calculator = Calculator.new(rules: rules)
        assert_equal 1, calculator.event_categories.size
        assert_equal "Masters Men", calculator.event_categories.first.name
      end

      def test_validate
        calculator = Calculator.new
        calculator.validate!

        calculator.event_categories << Models::EventCategory.new(Models::Category.new("Masters Men"))
        calculator.validate!
        calculator.event_categories << Models::EventCategory.new(Models::Category.new("Masters Men"))
        assert_raises(RuntimeError) { calculator.validate! }
      end
    end
  end
end
