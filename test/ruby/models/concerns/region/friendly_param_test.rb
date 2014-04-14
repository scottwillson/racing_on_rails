require_relative "../../../test_case"
require_relative "../../../../../app/models/concerns/region/friendly_param"

# :stopdoc:
class Concerns::Region::FriendlyParamTest < Ruby::TestCase
  class TestRegion
    include Concerns::Region::FriendlyParam
    attr_accessor :name
  end

  test "to_param" do
    region = TestRegion.new
    region.name = "Oregon"
    assert_equal "oregon", region.to_param
  end

  test "to_param_with_spaces" do
    region = TestRegion.new
    region.name = "Northern California"
    assert_equal "northern-california", region.to_param
  end

  test "to_param_with_puncuation" do
    region = TestRegion.new
    region.name = "N. California"
    assert_equal "n-california", region.to_param
  end
end
