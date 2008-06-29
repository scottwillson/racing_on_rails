require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/velodromes_controller'

# :stopdoc:
class Admin::VelodromesController; def rescue_action(e) raise e end; end

class Admin::VelodromesControllerTest < ActiveSupport::TestCase
  
  def setup
    @controller = Admin::VelodromesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.host = "localhost"
    @request.session[:user] = users(:candi)
  end
  
  def test_not_logged_in_index
    @request.session[:user] = nil
    get(:index)
    assert_response(:redirect)
    assert_redirected_to(:controller => '/admin/account', :action => 'login')
    assert_nil(@request.session["user"], "No user in session")
  end

  def test_index
    opts = {:controller => "admin/velodromes", :action => "index"}
    assert_routing("/admin/velodromes", opts)
    
    get(:index)
    assert_response(:success)
    assert_template("admin/velodromes/index")
    assert_not_nil(assigns["velodromes"], "Should assign velodromes")
    assert(assigns["velodromes"].empty?, "Should have no velodromes")
  end
end
