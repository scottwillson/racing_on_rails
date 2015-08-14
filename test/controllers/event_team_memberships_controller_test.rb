require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class EventTeamMembershipsControllerTest < ActionController::TestCase
  test "new" do
    event = FactoryGirl.create(:event)
    get :new, event_id: event
    assert_redirected_to new_person_session_path
  end

  test "new with person" do
    event = FactoryGirl.create(:event)
    person = FactoryGirl.create(:person)

    get :new, event_id: event, person_id: person

    assert_redirected_to new_person_session_path
  end

  test "new with current person" do
    person = FactoryGirl.create(:person)
    login_as person
    event = FactoryGirl.create(:event)

    get :new, event_id: event

    assert_response :success
  end

  test "new with current person and person ID" do
    person = FactoryGirl.create(:person)
    login_as person
    event = FactoryGirl.create(:event)

    get :new, event_id: event, person_id: person

    assert_response :success
  end

  test "new should redirect to show if already exists" do
    person = FactoryGirl.create(:person)
    login_as person
    event_team_membership = FactoryGirl.create(:event_team_membership, person: person)

    get :new, event_id: event_team_membership.event, person_id: person

    assert_redirected_to event_team_membership_path(event_team_membership)
  end

  test "create for team name" do
    person = FactoryGirl.create(:person)
    login_as person
    event = FactoryGirl.create(:event)

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
    person = FactoryGirl.create(:person)
    login_as person
    event = FactoryGirl.create(:event)
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
    person = FactoryGirl.create(:person)
    login_as person
    event_team_membership = FactoryGirl.create(:event_team_membership, person: person)

    get :show, id: event_team_membership
    assert_response :success
  end

  test "destroy" do
    person = FactoryGirl.create(:person)
    login_as person
    event_team_membership = FactoryGirl.create(:event_team_membership, person: person)

    delete :destroy, id: event_team_membership

    assert_redirected_to new_event_person_event_team_membership_path(event_team_membership.event, event_team_membership.person)
    assert !EventTeamMembership.exists?(event_team_membership.id)
  end
end
