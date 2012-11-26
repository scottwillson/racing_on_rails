require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class AdminPagesTest < ActionController::IntegrationTest
  def test_events
    if RacingAssociation.current.ssl?
      FactoryGirl.create(:administrator)
      https! false
      get admin_events_path
      assert_redirected_to "https://www.example.com/admin/events"
      https!
      follow_redirect!
      assert_redirected_to "https://www.example.com/person_session/new"
      follow_redirect!
      assert_equal "Please login to your #{RacingAssociation.current.short_name} account", flash[:notice]

      login :person_session => { :login => 'admin@example.com', :password => 'secret' }
      assert_redirected_to "https://www.example.com/admin/events"

      get admin_events_path
      assert_response :success
    end
  end

  private

  def go_to_login
    https! if RacingAssociation.current.ssl?
    get new_person_session_path
    assert_response :success
    assert_template "person_sessions/new"
  end

  def login(options)
    https! if RacingAssociation.current.ssl?
    post person_session_path, options
    assert_response :redirect
  end
end
