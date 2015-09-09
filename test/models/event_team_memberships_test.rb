require "test_helper"

# :stopdoc:
class EventTeamMembershipsTest < ActiveSupport::TestCase
  test "create for existing team" do
    person = FactoryGirl.create(:person)
    event_team = FactoryGirl.create(:event_team)

    new_membership = event_team.event_team_memberships.create!(person: person)

    assert_equal event_team, new_membership.event_team
    assert_equal person, new_membership.person
    assert_equal 1, EventTeamMembership.count
  end

  test "replace with person ID" do
    event_team_membership = FactoryGirl.create(:event_team_membership)
    different_team = FactoryGirl.create(:event_team, event: event_team_membership.event)

    new_membership = different_team.event_team_memberships.create(person: event_team_membership.person.reload)
    assert new_membership.errors.present?
    assert_equal 1, EventTeamMembership.count
  end
end
