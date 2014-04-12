require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class PersonSessionsControllerTest < ActionController::TestCase
  def setup
    super
    use_ssl
  end

  def test_login_page
    get :new
    assert_response :success
  end

  def test_admin_login
    FactoryGirl.create(:administrator)
    post :create, :person_session => { :login => "admin@example.com", :password => "secret" }
    assert_not_nil(assigns["person_session"], "@person_session")
    assert assigns["person_session"].errors.empty?, assigns["person_session"].errors.full_messages.join
    assert_redirected_to admin_home_path
    assert_not_nil session[:person_credentials], "Should have :person_credentials in session"
    assert_not_nil cookies["person_credentials"], "person_credentials cookie"
  end

  def test_member_login
    member = FactoryGirl.create(:person_with_login)
    post :create, :person_session => { :login => member.login, :password => "secret" }
    assert_not_nil(assigns["person_session"], "@person_session")
    assert assigns["person_session"].errors.empty?, assigns["person_session"].errors.full_messages.join
    assert_redirected_to edit_person_path(member)
    assert_not_nil session[:person_credentials], "Should have :person_credentials in session"
    assert_not_nil cookies["person_credentials"], "person_credentials cookie"
  end

  def test_login_failure
    FactoryGirl.create(:administrator)
    post :create, :person_session => { :login => "admin@example.com", :password => "bad password" }
    assert_not_nil(assigns["person_session"], "@person_session")
    assert(!assigns["person_session"].errors.empty?, "@person_session should have errors")
    assert_response :success
    assert_nil session[:person_credentials], "Should not have :person_credentials in session"
    assert_nil cookies["person_credentials"], "person_credentials cookie"
  end

  def test_blank_login_should_fail
    FactoryGirl.create(:administrator)
    post :create, :person_session => { :login => "", :password => "" }
    assert_not_nil(assigns["person_session"], "@person_session")
    assert(assigns["person_session"].errors.present?, "@person_session should have errors")
    assert_response :success
    assert_nil session[:person_credentials], "Should not have :person_credentials in session. @current_person: #{assigns[:current_person]}"
    assert_nil cookies["person_credentials"], "person_credentials cookie"
  end

  def test_blank_login_should_fail_with_blank_email_address
    Person.create!
    post :create, "person_session" => { "email" => "", "password" => "" }, "login" => "Login"
    assert_not_nil(assigns["person_session"], "@person_session")
    assert(!assigns["person_session"].errors.empty?, "@person_session should have errors")
    assert_response :success
    assert_nil cookies["person_credentials"], "person_credentials cookie"
    assert_nil session[:person_credentials], "Authlogic should not put :person_credentials in session"
  end
  
  def test_logout
    member = FactoryGirl.create(:person_with_login)
    login_as member

    delete :destroy
    
    assert_redirected_to new_person_session_url(secure_redirect_options)
    assert_nil assigns["person_session"], "@person_session"
    assert_nil session[:person_credentials], "Should not have :person_credentials in session"
    assert_nil cookies["person_credentials"], "person_credentials cookie"    
    assert_nil session[:return_to], ":return_to in session"
  end
  
  def test_logout_administrator
    administrator = FactoryGirl.create(:administrator)
    login_as administrator

    delete :destroy
    
    assert_redirected_to new_person_session_url(secure_redirect_options)
    assert_nil assigns["person_session"], "@person_session"
    assert_nil session[:person_credentials], "Should not have :person_credentials in session"
    assert_nil cookies["person_credentials"], "person_credentials cookie"    
    assert_nil session[:return_to], ":return_to in session"
  end
  
  def test_logout_no_session
    delete :destroy
    
    assert_redirected_to new_person_session_url(secure_redirect_options)
    assert_nil assigns["person_session"], "@person_session"
    assert_nil session[:person_credentials], "Should not have :person_credentials in session"
    assert_nil cookies["person_credentials"], "person_credentials cookie"    
    assert_nil session[:return_to], ":return_to in session"
  end
  
  def test_logout_no_ssl
    administrator = FactoryGirl.create(:administrator)
    @request.env['HTTPS'] = nil
    PersonSession.create(administrator)

    delete :destroy
    
    if RacingAssociation.current.ssl?
      assert_redirected_to "https://test.host/person_session"
    else
      assert_redirected_to "http://test.host/person_session/new"
    end
  end
  
  def test_show
    @request.env['HTTPS'] = nil
    get :show
    if RacingAssociation.current.ssl?
      assert_redirected_to person_session_url(secure_redirect_options)
    else
      assert_redirected_to new_person_session_url(secure_redirect_options)
    end
  end
  
  def test_show_and_return_to
    @request.env['HTTPS'] = nil
    get :show, :return_to => "/admin"
    if RacingAssociation.current.ssl?
      assert_redirected_to person_session_url(secure_redirect_options.merge(:return_to => "/admin"))
    else
      assert_redirected_to new_person_session_url(secure_redirect_options)
    end
  end
  
  def test_show_and_return_to_registration
    @request.env['HTTPS'] = nil
    get :show, :return_to => "/events/123/register"
    if RacingAssociation.current.ssl?
      assert_redirected_to person_session_url(secure_redirect_options.merge(:return_to => "/events/123/register"))
    else
      assert_redirected_to new_person_session_url(secure_redirect_options)
    end
  end
  
  def test_show_loggedin
    @request.env['HTTPS'] = nil
    member = FactoryGirl.create(:person_with_login)
    login_as member
    get :show
    if RacingAssociation.current.ssl?
      assert_redirected_to person_session_url(secure_redirect_options)
    else
      assert_response :success
    end
  end
end
