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

  def test_show
    opts = {:controller => "admin/home", :action => 'index'}
    assert_routing("/admin/home", opts)
    
    # expose old bug
    get(:index)
    assert_response(:success)
    assert_template("admin/home/index")
  end
  
  def test_security
    @request.session[:user] = nil
    get(:index)
    assert_response(:redirect)
  end
end
