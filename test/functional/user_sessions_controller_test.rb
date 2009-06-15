require "test_helper"

class UserSessionsControllerTest < ActionController::TestCase
  setup :activate_authlogic

  def test_login_page
    get :new
    assert_response :success
  end

  def test_admin_login
    post :create, :user_session => { :email => "admin@example.com", :password => "secret" }
    assert_not_nil(assigns["user_session"], "@user_session")
    assert(assigns["user_session"].errors.empty?, assigns["user_session"].errors.full_messages)
    assert_redirected_to admin_home_path
    assert_not_nil session[:user_credentials], "Should have :user_credentials in session"
    assert_not_nil cookies["user_credentials"], "user_credentials cookie"
  end

  def test_member_login
    post :create, :user_session => { :email => "member@example.com", :password => "secret" }
    assert_not_nil(assigns["user_session"], "@user_session")
    assert(assigns["user_session"].errors.empty?, assigns["user_session"].errors.full_messages)
    assert_redirected_to "/"
    assert_not_nil session[:user_credentials], "Should have :user_credentials in session"
    assert_not_nil cookies["user_credentials"], "user_credentials cookie"
  end

  def test_login_failure
    post :create, :user_session => { :email => "admin@example.com", :password => "bad password" }
    assert_not_nil(assigns["user_session"], "@user_session")
    assert(!assigns["user_session"].errors.empty?, "@user_session should have errors")
    assert_response :success
    assert_nil session[:user_credentials], "Should not have :user_credentials in session"
    assert_nil cookies["user_credentials"], "user_credentials cookie"
  end

  def test_blank_login_should_fail
    post :create, :user_session => { :email => "", :password => "" }
    assert_not_nil(assigns["user_session"], "@user_session")
    assert(!assigns["user_session"].errors.empty?, "@user_session should have errors")
    assert_response :success
    assert_nil session[:user_credentials], "Should not have :user_credentials in session"
    assert_nil cookies["user_credentials"], "user_credentials cookie"
  end
  
  def test_logout
    UserSession.create(users(:administrator))

    delete :destroy
    
    assert_redirected_to new_user_session_path
    assert_nil(assigns["user_session"], "@user_session")
    assert_nil session[:user_credentials], "Should not have :user_credentials in session"
    assert_nil cookies["user_credentials"], "user_credentials cookie"    
  end
end
