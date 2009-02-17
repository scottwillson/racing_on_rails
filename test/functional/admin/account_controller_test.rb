require File.dirname(__FILE__) + '/../../test_helper'

# :stopdoc:
class AccountControllerTest < ActionController::TestCase
  fixtures :users
  
  tests Admin::AccountController
  
  def test_login
    opts = {:controller => "admin/account", :action => "login"}
    assert_routing("admin/account/login", opts)
  end
  
  def test_valid_login
    post :login, :email => "admin@example.com", :user_password => "secret"
    assert session[:user]
    assert_response :redirect
  end
  
  def test_invalid_login
    post :login, :email => "admin@example.com", :user_password => "badsecret"
    assert !session[:user]
    assert_response :success
    assert flash.has_key?(:warn)
  end
  
  def test_forgot_password
    opts = {:controller => "admin/account", :action => "forgot"}
    assert_routing("admin/account/forgot", opts)
    
    post :forgot, :email => "admin@example.com"
    assert_response :redirect
    assert_redirected_to :action => "login"
    
  end
  
  def test_forgot_password_error
    post :forgot, :email => "nouser@example.com"
    assert_response :success
  end
end

