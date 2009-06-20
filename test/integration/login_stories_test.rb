require "test_helper"

class LoginStoriesTest < ActionController::IntegrationTest
  setup :activate_authlogic
  
  def test_redirect_from_old_paths
    get "/account/login"
    assert_redirected_to "/person_session/new"

    get "/account/logout"
    assert_redirected_to "/person_session/new"

    post "/account/authenticate"
    assert_redirected_to "/person_session/new"

    get "/account"
    assert_redirected_to "/person_session/new"
  end
  
  def test_valid_admin_login
    get admin_people_path
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_template "person_sessions/new"
    assert_equal "You must be an administrator to access this page", flash[:notice]

    login :person_session => { :login => 'admin@example.com', :password => 'secret' }
    assert_redirected_to admin_people_path
  end
  
  def test_should_redirect_to_admin_home_after_admin_login
    go_to_login
    login :person_session => { :login => 'admin@example.com', :password => 'secret' }
    assert_redirected_to "/admin"
  end
  
  def test_valid_member_login
    go_to_login
    
    login :person_session => { :login => 'bob.jones', :password => 'secret' }
    
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_template "home/index.html.erb"
  end
  
  def test_should_fail_cookie_login
    PersonSession.create(people(:administrator))
    cookies["person_credentials"] = "invalid_auth_token"
    get '/admin/events'
    assert_redirected_to "/person_session/new"
  end
  
  def test_blank_login_shold_not_work
    Person.create!
    
    post person_session_path, "person_session" => { "email" => "", "password" => "" }, "login" => "Login"
    assert_response :success
    assert_template "person_sessions/new"

    get admin_people_path
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_template "person_sessions/new"
    assert_equal "You must be an administrator to access this page", flash[:notice]
  end

  private
  
  def go_to_login
    get new_person_session_path
    assert_response :success
    assert_template "person_sessions/new"
  end
  
  def login(options)
    post person_session_path, options
    assert_response :redirect
  end
end