# frozen_string_literal: true

require_relative "../v3"

# :stopdoc:
class Calculations::V3::CalculatorTest < Ruby::TestCase
  def test_initialize
    Calculations::V3::Calculator.new
  end

  def test_calculate
    calculator = Calculations::V3::Calculator.new
    calculator.calculate!
  end

  def test_map_categories_to_event_categories
    categories = [Calculations::V3::Models::Category.new("Masters Men")]
    rules = Calculations::V3::Rules.new(categories: categories)
    calculator = Calculations::V3::Calculator.new(rules: rules)
    assert_equal 1, calculator.event_categories.size
    assert_equal "Masters Men", calculator.event_categories.first.name
  end
end
