require File.dirname(__FILE__) + '/../../test_helper'

class Admin::BidsControllerTest < ActionController::TestCase
  def setup
    @request.session[:user] = users(:administrator).id
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
