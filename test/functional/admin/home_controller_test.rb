# :stopdoc:
require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/home_controller'

# Re-raise errors caught by the controller.
class Admin::HomeController; def rescue_action(e) raise e end; end

class Admin::HomeControllerTest < Test::Unit::TestCase
  def setup
    @controller = Admin::HomeController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user] = users(:candi)
  end

  def test_index
    opts = {:controller => "admin/home", :action => 'index'}
    assert_routing("/admin/home", opts)
    
    get(:index)
    assert_response(:success)
    assert_template("admin/home/index")
    assert_not_nil(assigns['upcoming_events'], 'Should assign upcoming_events')
    assert_not_nil(assigns['recent_results'], 'Should assign recent_results')
    assert_not_nil(assigns['news'], 'Should assign news')
    assert_not_nil(assigns['home_page_photo'], 'Should assign home_page_photo')
  end
  
  def test_security
    @request.session[:user] = nil
    get(:index)
    assert_response(:redirect)
  end
end
