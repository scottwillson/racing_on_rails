require File.dirname(__FILE__) + '/../test_helper'

# :stopdoc:
class AccountControllerTest < ActionController::TestCase
  fixtures :users
  
  tests Admin::AccountController
  
  def test_login
    opts = {:controller => "account", :action => "login"}
    assert_routing("account/login", opts)
  end
  
  def test_forgot_password
    opts = {:controller => "account", :action => "forgot"}
    assert_routing("account/forgot", opts)
    
    post :forgot, :email => "admin@example.com"
    assert_response :redirect
    assert_redirected_to :action => "login"
    
  end
  
  def test_forgot_password_error
    post :forgot, :email => "nouser@example.com"
    assert_response :success
  end
end

