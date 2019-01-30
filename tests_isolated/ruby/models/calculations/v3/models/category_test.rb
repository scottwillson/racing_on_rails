# frozen_string_literal: true

require_relative "../../v3"

# :stopdoc:
class Calculations::V3::Models::CategoryTest < Ruby::TestCase
  def test_initialize
    category = Calculations::V3::Models::Category.new("Women")
    assert_equal "Women", category.name
  end
end
