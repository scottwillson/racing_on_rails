require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/bids_controller'

class Admin::BidsController; def rescue_action(e) raise e end; end

class Admin::BidsControllerTest < Test::Unit::TestCase
  def setup
    @controller = Admin::BidsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user] = users(:candi)
  end

  def test_index
    opts = {:controller => "admin/bids", :action => "index"}
    assert_routing("/admin/bids", opts)

    get(:index)
    assert_response(:success)
    assert_template("admin/bids/index")
    assert_not_nil(assigns['bids'], 'Should assign bids')
  end
end
