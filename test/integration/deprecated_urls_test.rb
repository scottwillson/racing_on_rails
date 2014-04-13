require_relative "racing_on_rails/integration_test"

# :stopdoc:
# Replacements for deprecated URLs.
class DeprecatedURLsTest < RacingOnRails::IntegrationTest
  def test_event_results
    event = FactoryGirl.create(:event)

    get "/events/#{event.id}/results"
    assert_response :success
    assert_template "results/event"

    get "/events/#{event.id}"
    assert_response :success
    assert_template "results/event"
  end

  def test_team_results
    team = FactoryGirl.create(:team)

    get "/teams/#{team.id}/results"
    assert_response :success
    assert_template "results/team"

    get "/teams/#{team.id}"
    assert_response :success
    assert_template "results/team"
  end
end
