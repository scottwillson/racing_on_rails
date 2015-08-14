require_relative "racing_on_rails/integration_test"

# :stopdoc:
class EventTeamMembershipTest < RacingOnRails::IntegrationTest
  test "join" do
    event = FactoryGirl.create(:event, slug: "ojcs-team")
    get "/ojcs-team/join"
    assert_redirected_to new_person_session_path
  end
end
