require "test_helper"

# :stopdoc:
class CachingTest < ActionController::TestCase
  class TestController < ActionController::Base
    include Caching
  end

  test "expire_cache" do
    controller = TestController.new
    TestController.expects(:expire_cache)
    controller.send :expire_cache
  end

  test "class expire_cache" do
    RacingAssociation.current.update_column :updated_at, 2.days.ago
    TestController.expire_cache
    assert RacingAssociation.current.reload.updated_at > 2.days.ago
  end
end
