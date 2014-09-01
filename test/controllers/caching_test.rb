require "test_helper"

# :stopdoc:
class CachingTest < ActionController::TestCase
  class TestController < ActionController::Base
    include Caching
  end

  test "expire_cache" do
    controller = TestController.new
    controller.send :expire_cache
  end

  test "class expire_cache" do
    controller = TestController.new
    TestController.expire_cache
  end
end
