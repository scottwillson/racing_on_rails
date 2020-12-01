# frozen_string_literal: true

require File.expand_path("../test_helper", __dir__)

# :stopdoc:
class PersonSessionsControllerTest < ActionController::TestCase
  test "login page" do
    get :new
    assert_response :success
  end

  test "admin login" do
    FactoryBot.create(:administrator)
    post :create, params: { person_session: { login: "admin@example.com", password: "secret" } }
    assert_not_nil(assigns["person_session"], "@person_session")
    assert assigns["person_session"].errors.empty?, assigns["person_session"].errors.full_messages.join
    assert_redirected_to admin_home_path
    assert_not_nil session[:person_credentials], "Should have :person_credentials in session"
    assert_not_nil cookies["person_credentials"], "person_credentials cookie"
  end

  test "member login" do
    member = FactoryBot.create(:person_with_login)
    post :create, params: { person_session: { login: member.login, password: "secret" } }
    assert_not_nil(assigns["person_session"], "@person_session")
    assert assigns["person_session"].errors.empty?, assigns["person_session"].errors.full_messages.join
    assert_redirected_to edit_person_path(member)
    assert_not_nil session[:person_credentials], "Should have :person_credentials in session"
    assert_not_nil cookies["person_credentials"], "person_credentials cookie"
  end

  test "login failure" do
    FactoryBot.create(:administrator)
    post :create, params: { person_session: { login: "admin@example.com", password: "bad password" } }
    assert_not_nil(assigns["person_session"], "@person_session")
    assert_not(assigns["person_session"].errors.empty?, "@person_session should have errors")
    assert_response :success
    assert_nil session[:person_credentials], "Should not have :person_credentials in session"
    assert_nil cookies["person_credentials"], "person_credentials cookie"
  end

  test "blank login should fail" do
    FactoryBot.create(:administrator)
    post :create, params: { person_session: { login: "", password: "" } }
    assert_not_nil(assigns["person_session"], "@person_session")
    assert(assigns["person_session"].errors.present?, "@person_session should have errors")
    assert_response :success
    assert_nil session[:person_credentials], "Should not have :person_credentials in session. @current_person: #{assigns[:current_person]}"
    assert_nil cookies["person_credentials"], "person_credentials cookie"
  end

  test "blank login should fail with blank email address" do
    Person.create!
    post :create, params: { person_session: { email: "", password: "" }, login: "Login" }
    assert_not_nil(assigns["person_session"], "@person_session")
    assert_not(assigns["person_session"].errors.empty?, "@person_session should have errors")
    assert_response :success
    assert_nil cookies["person_credentials"], "person_credentials cookie"
    assert_nil session[:person_credentials], "Authlogic should not put :person_credentials in session"
  end

  test "logout" do
    member = FactoryBot.create(:person_with_login)
    login_as member

    delete :destroy

    assert_redirected_to new_person_session_url
    assert_nil assigns["person_session"], "@person_session"
    assert_nil session[:person_credentials], "Should not have :person_credentials in session"
    assert_nil cookies["person_credentials"], "person_credentials cookie"
    assert_nil session[:return_to], ":return_to in session"
  end

  test "logout administrator" do
    administrator = FactoryBot.create(:administrator)
    login_as administrator

    delete :destroy

    assert_redirected_to new_person_session_url
    assert_nil assigns["person_session"], "@person_session"
    assert_nil session[:person_credentials], "Should not have :person_credentials in session"
    assert_nil cookies["person_credentials"], "person_credentials cookie"
    assert_nil session[:return_to], ":return_to in session"
  end

  test "logout no session" do
    delete :destroy

    assert_redirected_to new_person_session_url
    assert_nil assigns["person_session"], "@person_session"
    assert_nil session[:person_credentials], "Should not have :person_credentials in session"
    assert_nil cookies["person_credentials"], "person_credentials cookie"
    assert_nil session[:return_to], ":return_to in session"
  end

  test "logout no ssl" do
    administrator = FactoryBot.create(:administrator)
    PersonSession.create(administrator)

    delete :destroy

    assert_redirected_to "http://test.host/person_session/new"
  end

  test "show" do
    get :show
    assert_redirected_to new_person_session_url
  end

  test "show and return to" do
    get :show, params: { return_to: "/admin" }
    assert_redirected_to new_person_session_url
  end

  test "show and return to registration" do
    get :show, params: { return_to: "/events/123/register" }
    assert_redirected_to new_person_session_url
  end

  test "show loggedin" do
    member = FactoryBot.create(:person_with_login)
    login_as member
    get :show
    assert_response :success
  end
end
