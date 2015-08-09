require "test_helper"

# :stopdoc:
class EventTeamMembershipsTest < ActiveSupport::TestCase
  test "create for existing team" do
    event = FactoryGirl.create(:event)
    person = FactoryGirl.create(:person)
    team = FactoryGirl.create(:team)

    team_event_membership = EventTeamMembership.create!(
      event: event,
      person: person,
      team_attributes: { name: team.name }
    )
  end
end
