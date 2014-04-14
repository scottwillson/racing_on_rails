require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class RegionTest < ActiveSupport::TestCase
  test "set friendly param" do
    region = Region.create!(name: "New York")
    assert_equal "new-york", region.friendly_param
  end
end
