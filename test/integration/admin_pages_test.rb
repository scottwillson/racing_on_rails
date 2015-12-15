require_relative "racing_on_rails/integration_test"

# :stopdoc:
class AdminPagesTest < RacingOnRails::IntegrationTest
  test "admin pages" do
    FactoryGirl.create(:administrator)
    get admin_events_path
    assert_redirected_to "http://www.example.com/person_session/new"
    assert_equal "Please login to your #{RacingAssociation.current.short_name} account", flash[:notice]

    login person_session: { login: 'admin@example.com', password: 'secret' }
    assert_redirected_to "http://www.example.com/admin/events"

    get admin_events_path
    assert_response :success

    get duplicate_people_path
    assert_response :success
  end
end
