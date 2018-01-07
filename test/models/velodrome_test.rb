# frozen_string_literal: true

require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class VelodromeTest < ActiveSupport::TestCase
  test "find name" do
    Velodrome.create!(name: "Hellyer", website: "hellyer.org")
    velodrome = Velodrome.find_by(name: "Hellyer")
    assert_not_nil(velodrome, "Should find new Velodrome")
    assert_equal("hellyer.org", velodrome.website, "website")
  end
end
