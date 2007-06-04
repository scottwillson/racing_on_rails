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
  
  def test_auction
    get(:auction)
    assert_response(:success)
    assert_template("home/_auction")
    assert_equal(10, assigns['bid'].amount, "highest_bid")
  end
  
  def test_bid
    get(:bid)
    assert_response(:success)
    assert_template("home/bid")
    assert_not_nil(assigns['bid'], "bid")
    assert_not_nil(assigns['highest_bid'], "highest_bid")
    assert_equal(10, assigns['highest_bid'].amount, "highest_bid")
  end

  def test_send_bid_error
    post(:send_bid)
    assert_response(:success)
    assert_template("home/bid")
    assert_not_nil(assigns['bid'], "bid")
    assert_equal(10, assigns['highest_bid'].amount, "highest_bid")
    assert_not_nil(assigns['highest_bid'], "highest_bid")
  end

  def test_send_bid
    post(:send_bid, :bid => {:name => 'Bryan Martin', :email => 'digitalbry@gmail.com', :phone => '911', :amount => 2500})
    assert_response(:redirect)
  end
end
