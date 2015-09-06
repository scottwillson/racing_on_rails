require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class EventTeamsControllerTest < ActionController::TestCase
  test "index" do
    event_team_membership = FactoryGirl.create(:event_team_membership)
    get :index, event_id: event_team_membership.event
    assert_response :success
  end

  test "index empty" do
    event = FactoryGirl.create(:event)
    get :index, event_id: event
    assert_response :success
  end

  test "index for admin" do
    login_as :administrator
    event_team_membership = FactoryGirl.create(:event_team_membership)
    get :index, event_id: event_team_membership.event
    assert_response :success
  end

  test "index for promoter" do
    event_team_membership = FactoryGirl.create(:event_team_membership)
    login_as event_team_membership.event.promoter
    get :index, event_id: event_team_membership.event
    assert_response :success
  end

  test "create requires current_person" do
    event = FactoryGirl.create(:event)
    post :create, event_id: event, team_attributes: { name: "Grant HS" }
    assert_redirected_to new_person_session_path
  end

  test "create" do
    person = FactoryGirl.create(:person)
    event = FactoryGirl.create(:event)

    assert_difference "EventTeamMembership.count" do
      login_as person
      post :create, event_id: event, event_team: { team_attributes: { name: "Grant HS" } }
    end

    event_team_membership = EventTeamMembership.first
    assert_not_nil event_team_membership
    assert_equal person, event_team_membership.person
    assert_equal "Grant HS", event_team_membership.team_name
    assert_redirected_to event_event_teams_path(event)
  end
end
