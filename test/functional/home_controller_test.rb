require File.dirname(__FILE__) + '/../test_helper'
require_or_load 'home_controller'

# :stopdoc:
# Re-raise errors caught by the controller.
class HomeController; def rescue_action(e) raise e end; end

class HomeControllerTest < Test::Unit::TestCase
  def setup
    @controller = HomeController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    get(:index)
    assert_not_nil(assigns['upcoming_events'], 'Should assign upcoming_events')
    assert_not_nil(assigns['recent_results'], 'Should assign recent_results')
  end

end
