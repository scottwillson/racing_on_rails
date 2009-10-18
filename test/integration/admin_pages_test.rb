require "test_helper"

class PublicPagesTest < ActionController::IntegrationTest
  if ASSOCIATION.ssl?
    def test_events
      get admin_events_path
      assert_redirected_to "https://www.example.com/admin/events"
      https!
      follow_redirect!
      assert_redirected_to "https://www.example.com/person_session/new"
      follow_redirect!
      assert_equal "You must be an administrator to access this page", flash[:notice]

      login :person_session => { :login => 'admin@example.com', :password => 'secret' }
      assert_redirected_to "https://www.example.com/admin/events"

      get admin_events_path
      assert_response :success
    end
  end

  private

  def go_to_login
    https! if ASSOCIATION.ssl?
    get new_person_session_path
    assert_response :success
    assert_template "person_sessions/new"
  end

  def login(options)
    https! if ASSOCIATION.ssl?
    post person_session_path, options
    assert_response :redirect
  end
end
