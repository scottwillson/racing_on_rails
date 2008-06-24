require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/account_controller'

# :stopdoc:
class Admin::AccountController
  def rescue_action(e) raise e end
end

class AdminAccountControllerTest < ActiveSupport::TestCase
  
  def setup
    @controller = Admin::AccountController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_login
    opts = {:controller => "admin/account", :action => "login"}
    assert_routing("admin/account/login", opts)
  end
  
  # TODO Add some more tests!
end
