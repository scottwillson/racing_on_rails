require "test_helper"

class PersonSessionsControllerTest < ActionController::TestCase
  setup :activate_authlogic, :use_ssl

  def test_login_page
    get :new
    assert_response :success
  end

  def test_admin_login
    post :create, :person_session => { :login => "admin@example.com", :password => "secret" }
    assert_not_nil(assigns["person_session"], "@person_session")
    assert(assigns["person_session"].errors.empty?, assigns["person_session"].errors.full_messages)
    assert_redirected_to admin_home_path
    assert_not_nil session[:person_credentials], "Should have :person_credentials in session"
    assert_not_nil cookies["person_credentials"], "person_credentials cookie"
  end

  def test_member_login
    post :create, :person_session => { :login => "bob.jones", :password => "secret" }
    assert_not_nil(assigns["person_session"], "@person_session")
    assert(assigns["person_session"].errors.empty?, assigns["person_session"].errors.full_messages)
    assert_redirected_to edit_person_path(people(:member))
    assert_not_nil session[:person_credentials], "Should have :person_credentials in session"
    assert_not_nil cookies["person_credentials"], "person_credentials cookie"
  end

  def test_login_failure
    post :create, :person_session => { :login => "admin@example.com", :password => "bad password" }
    assert_not_nil(assigns["person_session"], "@person_session")
    assert(!assigns["person_session"].errors.empty?, "@person_session should have errors")
    assert_response :success
    assert_nil session[:person_credentials], "Should not have :person_credentials in session"
    assert_nil cookies["person_credentials"], "person_credentials cookie"
  end

  def test_blank_login_should_fail
    post :create, :person_session => { :login => "", :password => "" }
    assert_not_nil(assigns["person_session"], "@person_session")
    assert(!assigns["person_session"].errors.empty?, "@person_session should have errors")
    assert_response :success
    assert_nil session[:person_credentials], "Should not have :person_credentials in session"
    assert_nil cookies["person_credentials"], "person_credentials cookie"
  end

  def test_blank_login_should_fail_with_blank_email_address
    Person.create!
    post :create, "person_session" => { "email" => "", "password" => "" }, "login" => "Login"
    assert_not_nil(assigns["person_session"], "@person_session")
    assert(!assigns["person_session"].errors.empty?, "@person_session should have errors")
    assert_response :success
    assert_nil cookies["person_credentials"], "person_credentials cookie"
    assert_not_nil session[:person_credentials], "Authlogic puts :person_credentials in session, even though it won't allow person to access protected pages"
  end
  
  def test_logout
    PersonSession.create(people(:administrator))

    delete :destroy
    
    assert_redirected_to new_person_session_path
    assert_nil(assigns["person_session"], "@person_session")
    assert_nil session[:person_credentials], "Should not have :person_credentials in session"
    assert_nil cookies["person_credentials"], "person_credentials cookie"    
  end
  
  def test_logout_no_ssl
    @request.env['HTTPS'] = nil
    PersonSession.create(people(:administrator))

    delete :destroy
    
    if ASSOCIATION.ssl?
      assert_redirected_to "https://test.host/person_session"
    else
      assert_redirected_to "http://test.host/person_session/new"
    end
  end
  
  def test_show
    @request.env['HTTPS'] = nil
    get :show
    assert_redirected_to new_person_session_url
  end
  
  def test_show_and_return_to
    @request.env['HTTPS'] = nil
    get :show, :return_to => "/admin"
    assert_redirected_to new_person_session_url
  end
  
  def test_show_and_return_to_registration
    @request.env['HTTPS'] = nil
    get :show, :return_to => "/events/123/register"
    assert_redirected_to new_person_session_url
  end
  
  def test_show_loggedin
    @request.env['HTTPS'] = nil
    login_as :member
    get :show
    assert_response :success
  end
end
