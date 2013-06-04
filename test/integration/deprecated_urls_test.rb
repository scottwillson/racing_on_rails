require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
# Replacements for deprecated URLs.
class DeprecatedURLsTest < ActionController::IntegrationTest
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
