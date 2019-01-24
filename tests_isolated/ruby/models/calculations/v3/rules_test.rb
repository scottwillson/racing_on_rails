# frozen_string_literal: true

require_relative "../../../test_case"
require_relative "../../../../../app/models/calculations"
require_relative "../../../../../app/models/calculations/v3"
require_relative "../../../../../app/models/calculations/v3/calculator"
require_relative "../../../../../app/models/calculations/v3/rules"

# :stopdoc:
class Calculations::V3::RulesTest < Ruby::TestCase
  def test_new
    rules = Calculations::V3::Rules.new
    assert_nil rules.points_for_place
  end
end
