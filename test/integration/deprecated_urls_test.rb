require_relative "racing_on_rails/integration_test"

# :stopdoc:
# Replacements for deprecated URLs.
class DeprecatedURLsTest < RacingOnRails::IntegrationTest
  test "event results" do
    event = FactoryGirl.create(:event)

    get "/events/#{event.id}/results"
    assert_response :success
    assert_template "results/event"

    get "/events/#{event.id}"
    assert_response :success
    assert_template "results/event"
  end

  test "team results" do
    team = FactoryGirl.create(:team)

    get "/teams/#{team.id}/results"
    assert_response :success
    assert_template "results/team"

    get "/teams/#{team.id}"
    assert_response :success
    assert_template "results/team"
  end
end
