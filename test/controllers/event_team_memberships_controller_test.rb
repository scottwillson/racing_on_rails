require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class EventTeamMembershipsControllerTest < ActionController::TestCase
  test "new" do
    event = FactoryGirl.create(:event)
    person = FactoryGirl.create(:person)

    get :new, event_id: event, person_id: person

    assert_response :success
  end

  test "new should redirect to show if already exists" do
    event_team_membership = FactoryGirl.create(:event_team_membership)
    get :new, event_id: event_team_membership.event, person_id: event_team_membership.person
    assert_redirected_to event_team_membership_path(event_team_membership)
  end

  test "create for team name" do
    event = FactoryGirl.create(:event)
    person = FactoryGirl.create(:person)

    post :create, event_team_membership: {
      event_id: event,
      person_id: person,
      team_attributes: { name: "Grant HS" }
    }

    event_team_membership = assigns(:event_team_membership)
    assert_not_nil event_team_membership
    assert_redirected_to event_team_membership_path(event_team_membership)
  end

  test "create choose team" do
    event = FactoryGirl.create(:event)
    person = FactoryGirl.create(:person)
    team = FactoryGirl.create(:team)

    post :create, event_team_membership: {
      event_id: event,
      person_id: person,
      team_id: team
    }

    event_team_membership = assigns(:event_team_membership)
    assert_not_nil event_team_membership
    assert_equal team, event_team_membership.team
    assert_redirected_to event_team_membership_path(event_team_membership)
  end

  test "show" do
    event_team_membership = FactoryGirl.create(:event_team_membership)
    get :show, id: event_team_membership
    assert_response :success
  end

  test "destroy" do
    event_team_membership = FactoryGirl.create(:event_team_membership)

    delete :destroy, id: event_team_membership

    assert_redirected_to new_event_person_event_team_membership_path(event_team_membership.event, event_team_membership.person)
    assert !EventTeamMembership.exists?(event_team_membership.id)
  end
end
