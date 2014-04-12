require_relative "racing_on_rails/integration_test"

# :stopdoc:
class AdminPagesTest < RacingOnRails::IntegrationTest
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
end
