require File.expand_path("../../test_helper", __FILE__)

class VelodromeTest < ActiveSupport::TestCase
  def test_find_name
    Velodrome.create!(:name => "Hellyer", :website => "hellyer.org")
    velodrome = Velodrome.find_by_name("Hellyer")
    assert_not_nil(velodrome, "Should find new Velodrome")
    assert_equal("hellyer.org", velodrome.website, "website")
  end
end
