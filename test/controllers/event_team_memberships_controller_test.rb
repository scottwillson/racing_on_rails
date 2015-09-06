require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class EventTeamMembershipsControllerTest < ActionController::TestCase
  test "#create for person name" do
    person = FactoryGirl.create(:person)
    event_team = FactoryGirl.create(:event_team)
    login_as event_team.event.promoter

    post :create,
      event_team_id: event_team,
      event_team_membership: {
        person_attributes: {
          name: "Jane Racer"
        }
      }

    event_team_membership = assigns(:event_team_membership)
    assert_not_nil event_team_membership
    assert_equal "Jane Racer", event_team_membership.person.name, "Name for new person"
    assert_redirected_to event_event_teams_path(event_team.event)
  end

  test "#create for existing person" do
    person = FactoryGirl.create(:person)
    event_team = FactoryGirl.create(:event_team)
    login_as event_team.event.promoter

    post :create,
      event_team_id: event_team,
      event_team_membership: {
        person_id: person,
        person_attributes: {
          name: person.name
        }
      }

    event_team_membership = assigns(:event_team_membership)
    assert_not_nil event_team_membership
    assert_equal person, event_team_membership.person
    assert_redirected_to event_event_teams_path(event_team.event)
  end

  test "#create current person" do
    person = FactoryGirl.create(:person)
    login_as person
    event_team = FactoryGirl.create(:event_team)

    post :create, event_team_id: event_team

    event_team_membership = assigns(:event_team_membership)
    assert_not_nil event_team_membership
    assert_equal event_team, event_team_membership.event_team
    assert_equal person, event_team_membership.person
    assert_redirected_to event_event_teams_path(event_team.event)
  end

  test "#create current person join different team" do
    event_team_membership = FactoryGirl.create(:event_team_membership)
    person = event_team_membership.person
    event_team = event_team_membership.event_team
    login_as person
    different_event_team = FactoryGirl.create(:event_team, event: event_team_membership.event)

    post :create, event_team_id: different_event_team

    event_team_membership = assigns(:event_team_membership)
    assert event_team_membership.errors.empty?, event_team_membership.errors.full_messages.join(", ")
    assert_not_nil event_team_membership
    assert_equal different_event_team, event_team_membership.event_team
    assert_equal person, event_team_membership.person
    assert_redirected_to event_event_teams_path(event_team.event)
    assert_equal 1, EventTeamMembership.count
  end

  test "#create current_person required" do
    event_team = FactoryGirl.create(:event_team)
    post :create, event_team_id: event_team
    assert_redirected_to new_person_session_path
  end

  test "#create admin required" do
    person = FactoryGirl.create(:person)
    different_person = FactoryGirl.create(:person)
    login_as person
    event_team = FactoryGirl.create(:event_team)

    post :create,
      event_team_id: event_team,
      event_team_membership: {
        person_id: different_person,
      }

    assert_redirected_to unauthorized_path
  end

  test "#destroy" do
    person = FactoryGirl.create(:person)
    login_as person
    event_team_membership = FactoryGirl.create(:event_team_membership, person: person)

    delete :destroy, id: event_team_membership

    assert_equal person, event_team_membership.person
    assert !EventTeamMembership.exists?(event_team_membership.id)
    assert_redirected_to event_event_teams_path(event_team_membership.event)
  end

  test "#destroy for another person" do
    administrator = FactoryGirl.create(:administrator)
    different_person = FactoryGirl.create(:person)
    login_as administrator
    event_team_membership = FactoryGirl.create(:event_team_membership, person: different_person)

    delete :destroy, id: event_team_membership

    assert !EventTeamMembership.exists?(event_team_membership.id)
    assert_redirected_to event_event_teams_path(event_team_membership.event)
  end

    test "#destroy current_person required" do
      event_team_membership = FactoryGirl.create(:event_team_membership)
      delete :destroy, id: event_team_membership
      assert_redirected_to new_person_session_path
    end
end
