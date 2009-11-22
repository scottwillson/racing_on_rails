require "test_helper"

class LoginStoriesTest < ActionController::IntegrationTest
  if ASSOCIATION.ssl?
    # logged-in?, person_id?, same person?, admin?
    def test_member_account
      get "/account"
      assert_redirected_to "https://www.example.com/account"
      https!
      follow_redirect!
      assert_redirected_to "https://www.example.com/person_session/new"
      login :person_session => { :login => 'bob.jones', :password => 'secret' }
      assert_redirected_to "https://www.example.com/account"
      follow_redirect!
      assert_redirected_to "https://www.example.com/people/#{people(:member).id}/edit"

      get "/account"
      assert_redirected_to "https://www.example.com/people/#{people(:member).id}/edit"

      get "/people/#{people(:member).id}/account"
      assert_redirected_to "https://www.example.com/people/#{people(:member).id}/edit"

      get "/people/account"
      assert_redirected_to "https://www.example.com/people/#{people(:member).id}/edit"

      another_member = Person.create!.id
      get "/people/#{another_member}/account"
      assert_redirected_to "https://www.example.com/people/#{another_member}/edit"
      follow_redirect!
      assert_redirected_to unauthorized_path

      get "/logout"
      get "/account"
      login :person_session => { :login => 'admin@example.com', :password => 'secret' }
      assert_redirected_to "https://www.example.com/account"
      follow_redirect!
      assert_redirected_to "https://www.example.com/people/#{people(:administrator).id}/edit"

      get "/people/#{people(:member).id}/account"
      assert_redirected_to "https://www.example.com/people/#{people(:member).id}/edit"

      get "/people/account"
      assert_redirected_to "https://www.example.com/people/#{people(:administrator).id}/edit"

      get "/people/#{another_member}/account"
      assert_redirected_to "https://www.example.com/people/#{another_member}/edit"

      get "/people/#{people(:administrator).id}/account"
      assert_redirected_to "https://www.example.com/people/#{people(:administrator).id}/edit"
    end

    def test_redirect_from_old_paths
      get "/account/login"
      assert_redirected_to "https://www.example.com/account/login"
      follow_redirect!

      get "/account/logout"
      assert_redirected_to "https://www.example.com/person_session/new"
      follow_redirect!
    end

    def test_login
      get "/login"
      assert_redirected_to "https://www.example.com/login"

      https!
      get "/login"

      login :person_session => { :login => 'bob.jones', :password => 'secret' }
      assert_redirected_to "https://www.example.com/people/#{people(:member).id}/edit"

      get "/login"
    end

    def test_valid_admin_login
      https!
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
      assert_redirected_to edit_person_path(people(:member))
    end

    def test_should_fail_cookie_login
      https!
      PersonSession.create(people(:administrator))
      cookies["person_credentials"] = "invalid_auth_token"
      get '/admin/events'
      assert_redirected_to "/person_session/new"
    end

    def test_blank_login_should_not_work
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
      assert_equal "You must be an administrator to access this page", flash[:notice]
    end

  # No-SSL tests
  else
    # logged-in?, person_id?, same person?, admin?
    def test_member_account
      get "/account"
      assert_redirected_to "http://www.example.com/person_session/new"
      follow_redirect!
      login :person_session => { :login => 'bob.jones', :password => 'secret' }
      assert_redirected_to "http://www.example.com/account"
      follow_redirect!
      assert_redirected_to "http://www.example.com/people/#{people(:member).id}/edit"

      get "/account"
      assert_redirected_to "http://www.example.com/people/#{people(:member).id}/edit"

      get "/people/#{people(:member).id}/account"
      assert_redirected_to "http://www.example.com/people/#{people(:member).id}/edit"

      get "/people/account"
      assert_redirected_to "http://www.example.com/people/#{people(:member).id}/edit"

      another_member = Person.create!.id
      get "/people/#{another_member}/account"
      assert_redirected_to "http://www.example.com/people/#{another_member}/edit"
      follow_redirect!
      assert_redirected_to unauthorized_path

      get "/logout"
      get "/account"
      login :person_session => { :login => 'admin@example.com', :password => 'secret' }
      assert_redirected_to "http://www.example.com/account"
      follow_redirect!
      assert_redirected_to "http://www.example.com/people/#{people(:administrator).id}/edit"

      get "/people/#{people(:member).id}/account"
      assert_redirected_to "http://www.example.com/people/#{people(:member).id}/edit"

      get "/people/account"
      assert_redirected_to "http://www.example.com/people/#{people(:administrator).id}/edit"

      get "/people/#{another_member}/account"
      assert_redirected_to "http://www.example.com/people/#{another_member}/edit"

      get "/people/#{people(:administrator).id}/account"
      assert_redirected_to "http://www.example.com/people/#{people(:administrator).id}/edit"
    end

    def test_redirect_from_old_paths
      get "/account/login"
      assert_response :success

      get "/account/logout"
      assert_redirected_to "http://www.example.com/person_session/new"
      follow_redirect!
    end

    def test_login
      get "/login"

      login :person_session => { :login => 'bob.jones', :password => 'secret' }
      assert_redirected_to "http://www.example.com/people/#{people(:member).id}/edit"

      get "/login"
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
      assert_redirected_to edit_person_path(people(:member))
    end

    def test_should_fail_cookie_login
      PersonSession.create(people(:administrator))
      cookies["person_credentials"] = "invalid_auth_token"
      get '/admin/events'
      assert_redirected_to "/person_session/new"
    end

    def test_blank_login_should_not_work
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

  end
  
  def test_unauthorized
    get "/unauthorized"
    assert_response :success
  end

  private
  
  def go_to_login
    https! if ASSOCIATION.ssl?
    get new_person_session_path
    assert_response :success
    assert_template "person_sessions/new"
  end
  
  def login(options)
    post person_session_path, options
    assert_response :redirect
  end
end
