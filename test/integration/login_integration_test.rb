require_relative "racing_on_rails/integration_test"

# :stopdoc:
class LoginIntegrationTest < RacingOnRails::IntegrationTest
  def setup
    super
    @administrator = FactoryGirl.create(:administrator)
    @member = FactoryGirl.create(:person_with_login, login: "bob.jones")
  end

  # logged-in?, person_id?, same person?, admin?
  test "member account" do
    if RacingAssociation.current.ssl?
      get "/account"
      assert_redirected_to "https://www.example.com/account"
      https!
      follow_redirect!
      assert_redirected_to "https://www.example.com/person_session/new"
      login person_session: { login: 'bob.jones', password: 'secret' }
      assert_redirected_to "https://www.example.com/account"
      follow_redirect!
      assert_redirected_to "https://www.example.com/people/#{@member.id}/edit"

      get "/account"
      assert_redirected_to "https://www.example.com/people/#{@member.id}/edit"

      get "/people/#{@member.id}/account"
      assert_redirected_to "https://www.example.com/people/#{@member.id}/edit"

      get "/people/account"
      assert_redirected_to "https://www.example.com/people/#{@member.id}/edit"

      another_member = Person.create!.id
      get "/people/#{another_member}/account"
      assert_redirected_to "https://www.example.com/people/#{another_member}/edit"
      follow_redirect!
      assert_redirected_to unauthorized_path

      get "/logout"
      get "/account"
      login person_session: { login: 'admin@example.com', password: 'secret' }
      assert_redirected_to "https://www.example.com/account"
      follow_redirect!
      assert_redirected_to "https://www.example.com/people/#{@administrator.id}/edit"

      get "/people/#{@member.id}/account"
      assert_redirected_to "https://www.example.com/people/#{@member.id}/edit"

      get "/people/account"
      assert_redirected_to "https://www.example.com/people/#{@administrator.id}/edit"

      get "/people/#{another_member}/account"
      assert_redirected_to "https://www.example.com/people/#{another_member}/edit"

      get "/people/#{@administrator.id}/account"
      assert_redirected_to "https://www.example.com/people/#{@administrator.id}/edit"

      assert_redirected_to "https://www.example.com/people/#{@administrator.id}/edit"
    else
      get "/account"
      assert_redirected_to "http://www.example.com/person_session/new"
      login person_session: { login: 'bob.jones', password: 'secret' }
      assert_redirected_to "http://www.example.com/account"
      follow_redirect!
      assert_redirected_to "http://www.example.com/people/#{@member.id}/edit"

      get "/account"
      assert_redirected_to "http://www.example.com/people/#{@member.id}/edit"

      get "/people/#{@member.id}/account"
      assert_redirected_to "http://www.example.com/people/#{@member.id}/edit"

      get "/people/account"
      assert_redirected_to "http://www.example.com/people/#{@member.id}/edit"

      another_member = Person.create!.id
      get "/people/#{another_member}/account"
      assert_redirected_to "http://www.example.com/people/#{another_member}/edit"
      follow_redirect!
      assert_redirected_to unauthorized_path

      get "/logout"
      get "/account"
      login person_session: { login: 'admin@example.com', password: 'secret' }
      assert_redirected_to "http://www.example.com/account"
      follow_redirect!
      assert_redirected_to "http://www.example.com/people/#{@administrator.id}/edit"

      get "/people/#{@member.id}/account"
      assert_redirected_to "http://www.example.com/people/#{@member.id}/edit"

      get "/people/account"
      assert_redirected_to "http://www.example.com/people/#{@administrator.id}/edit"

      get "/people/#{another_member}/account"
      assert_redirected_to "http://www.example.com/people/#{another_member}/edit"

      get "/people/#{@administrator.id}/account"
      assert_redirected_to "http://www.example.com/people/#{@administrator.id}/edit"
    end
  end

  test "redirect from old paths" do
    if RacingAssociation.current.ssl?
      get "/account/login"
      assert_redirected_to "https://www.example.com/account/login"
      follow_redirect!

      get "/account/logout"
      assert_redirected_to "https://www.example.com/person_session/new"
      follow_redirect!
    else
      get "/account/login"
      assert_response :success

      get "/account/logout"
      assert_redirected_to "http://www.example.com/person_session/new"
      follow_redirect!
    end
  end

  test "login" do
    if RacingAssociation.current.ssl?
      get "http://www.example.com/login"
      assert_redirected_to "https://www.example.com/login"

      https!
      get "/login"

      login person_session: { login: 'bob.jones', password: 'secret' }
      assert_redirected_to "https://www.example.com/people/#{@member.id}/edit"
    else
      get "http://www.example.com/login"
      assert_response :success

      login person_session: { login: 'bob.jones', password: 'secret' }
      assert_redirected_to "http://www.example.com/people/#{@member.id}/edit"
    end
  end

  test "login on nonstandard port" do
    if RacingAssociation.current.ssl?
      get "http://www.example.com:8080/login"
      assert_redirected_to "https://www.example.com/login"

      https!
      get "/login"

      login person_session: { login: 'bob.jones', password: 'secret' }
      assert_redirected_to "https://www.example.com/people/#{@member.id}/edit"
    else
      get "http://www.example.com:8080/login"
      assert_response :success

      login person_session: { login: 'bob.jones', password: 'secret' }
      assert_redirected_to "http://www.example.com:8080/people/#{@member.id}/edit"
    end
  end

  test "valid admin login" do
    https!
    get admin_people_path
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_template "person_sessions/new"
    assert_equal "Please login to your #{RacingAssociation.current.short_name} account", flash[:notice]

    login person_session: { login: 'admin@example.com', password: 'secret' }
    assert_redirected_to admin_people_path
  end

  test "should redirect to admin home after admin login" do
    go_to_login
    login person_session: { login: 'admin@example.com', password: 'secret' }
    assert_redirected_to "/admin"
  end

  test "valid member login" do
    go_to_login
    login person_session: { login: 'bob.jones', password: 'secret' }
    assert_redirected_to edit_person_path(@member)
  end

  test "should fail cookie login" do
    https!
    PersonSession.create(@administrator)
    cookies["person_credentials"] = "invalid_auth_token"
    get '/admin/events'
    assert_redirected_to "/person_session/new"
  end

  test "blank login should not work" do
    Person.create!

    https!
    post person_session_path, "person_session" => { "email" => "", "password" => "" }, "login" => "Login"
    assert_response :success
    assert_template "person_sessions/new"

    get admin_people_path
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_template "person_sessions/new"
    assert_equal "Please login to your #{RacingAssociation.current.short_name} account", flash[:notice]
  end

  test "unauthorized" do
    https!
    get "/unauthorized"
    assert_response :success
  end
end
