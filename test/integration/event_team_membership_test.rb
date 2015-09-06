require_relative "racing_on_rails/integration_test"

# :stopdoc:
class EventTeamMembershipTest < RacingOnRails::IntegrationTest
  test "join" do
    https!
    event = FactoryGirl.create(:event, slug: "ojcs-team")
    get "/ojcs-team/join"
    assert_redirected_to event_event_teams_path(event)
  end
end
