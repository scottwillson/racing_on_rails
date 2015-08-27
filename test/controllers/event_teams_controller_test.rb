require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class EventTeamsControllerTest < ActionController::TestCase
  test "index" do
    event_team_membership = FactoryGirl.create(:event_team_membership)

    get :index, event_id: event_team_membership.event

    assert_response :success
  end

  test "show" do
    event_team_membership = FactoryGirl.create(:event_team_membership)

    get :show, event_id: event_team_membership.event, id: event_team_membership.team

    assert_response :success
  end
end
