require "test_helper"

# :stopdoc:
class AccountControllerTest < ActionController::TestCase
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
  
  def test_admin_authenticate
    post :authenticate, :email => "admin@example.com", :user_password => "secret"
    assert_equal users(:administrator).id, @controller.session[:user_id], "Should member user id in session (not entire User)"
    assert_redirected_to admin_home_path
  end
  
  def test_member_authenticate
    post :authenticate, :email => "member@example.com", :user_password => "membersecret"
    assert_equal users(:member_user).id, @controller.session[:user_id], "Should member user id in session (not entire User)"
    assert_redirected_to "/"
  end

  def test_authenticate_failure
    post :authenticate, :email => "admin@example.com", :user_password => "bad password"
    assert_nil @controller.session[:user_id], "Should be no user_id in session"
    assert_response :success
    assert_not_nil flash[:warn]
  end
  
  def test_should_login_with_cookie
    users(:administrator).remember_me
    @request.cookies["auth_token"] = cookie_for(:administrator)
    get :login
    assert @controller.send(:is_logged_in?)
  end

  def test_should_fail_cookie_login
    users(:administrator).remember_me
    @request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :login
    assert !@controller.send(:is_logged_in?)
  end

  protected
    def auth_token(token)
      CGI::Cookie.new('name' => 'auth_token', 'value' => token)
    end
    
    def cookie_for(user)
      auth_token users(user).remember_token
    end
end
