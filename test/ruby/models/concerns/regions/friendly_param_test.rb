require_relative "../../../test_case"
require_relative "../../../../../app/models/regions/friendly_param"

# :stopdoc:
class Regions::FriendlyParamTest < Ruby::TestCase
  class TestRegion
    include Regions::FriendlyParam
    attr_accessor :name
  end

  def test_to_param
    region = TestRegion.new
    region.name = "Oregon"
    assert_equal "oregon", region.to_param
  end

  def test_to_param_with_spaces
    region = TestRegion.new
    region.name = "Northern California"
    assert_equal "northern-california", region.to_param
  end

  def test_to_param_with_puncuation
    region = TestRegion.new
    region.name = "N. California"
    assert_equal "n-california", region.to_param
  end
end
