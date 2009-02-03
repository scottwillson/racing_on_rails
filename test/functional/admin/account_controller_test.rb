require File.dirname(__FILE__) + '/../../test_helper'

# :stopdoc:
class AccountControllerTest < ActionController::TestCase
  
  tests Admin::AccountController
  
  def test_login
    opts = {:controller => "admin/account", :action => "login"}
    assert_routing("admin/account/login", opts)
  end
end
