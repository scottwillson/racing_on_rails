# frozen_string_literal: true

require_relative "../../../../test_case"
require_relative "../../../../../../app/models/calculations"
require_relative "../../../../../../app/models/calculations/v3"
require_relative "../../../../../../app/models/calculations/v3/models"
require_relative "../../../../../../app/models/calculations/v3/models/category"

# :stopdoc:
class Calculations::V3::Models::CategoryTest < Ruby::TestCase
  def test_initialize
    category = Calculations::V3::Models::Category.new("Women")
    assert_equal "Women", category.name
  end
end
