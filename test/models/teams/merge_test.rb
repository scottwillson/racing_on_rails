# frozen_string_literal: true

require File.expand_path("../../test_helper", __dir__)

# :stopdoc:
module Teams
  class MergeTest < ActiveSupport::TestCase
    test "merge" do
      team_to_keep = FactoryBot.create(:team, name: "Vanilla")
      team_to_keep.aliases.create!(name: "Vanilla Bicycles")
      FactoryBot.create(:result, team: team_to_keep)
      FactoryBot.create(:time_trial_result, team: team_to_keep)
      FactoryBot.create(:person, team: team_to_keep)

      team_to_merge = FactoryBot.create(:team, name: "Gentle Lovers")
      team_to_merge.aliases.create!(name: "Gentile Lovers")
      FactoryBot.create(:time_trial_result, team: team_to_merge)
      FactoryBot.create(:person, team: team_to_merge)
      FactoryBot.create(:person, team: team_to_merge)
      FactoryBot.create(:person, team: team_to_merge)
      event = FactoryBot.create(:event)
      event_team = EventTeam.create!(team: team_to_merge, event: event)
      FactoryBot.create(:event_team_membership, event_team: event_team)
      event_team = EventTeam.create!(team: team_to_keep, event: event)
      FactoryBot.create(:event_team_membership, event_team: event_team)

      assert_not_nil(Team.find_by(name: team_to_keep.name), "#{team_to_keep.name} should be in DB")
      assert_equal(2, Result.where(team_id: team_to_keep.id).count, "Vanilla's results")
      assert_equal(1, Person.where(team_id: team_to_keep.id).count, "Vanilla's people")
      assert_equal(1, Alias.where(aliasable_id: team_to_keep.id).count, "Vanilla's aliases")

      assert_not_nil(Team.find_by(name: team_to_merge.name), "#{team_to_merge.name} should be in DB")
      assert_equal(1, Result.where(team_id: team_to_merge.id).count, "Gentle Lovers's results")
      assert_equal(3, Person.where(team_id: team_to_merge.id).count, "Gentle Lovers's people")
      assert_equal(1, Alias.where(aliasable_id: team_to_merge.id).count, "Gentle Lovers's aliases")

      promoter_events = [Event.create!(team: team_to_keep), Event.create!(team: team_to_merge)]

      team_to_keep.merge(team_to_merge)

      assert_not_nil(Team.find_by(name: team_to_keep.name), "#{team_to_keep.name} should be in DB")
      assert_equal(3, Result.where(team_id: team_to_keep.id).count, "Vanilla's results")
      assert_equal(4, Person.where(team_id: team_to_keep.id).count, "Vanilla's people")
      aliases = Alias.where(aliasable_id: team_to_keep.id)
      lovers_alias = aliases.detect { |a| a.name == "Gentle Lovers" }
      assert_not_nil(lovers_alias, "Vanilla should have Gentle Lovers alias")
      assert_equal(3, aliases.size, "Vanilla's aliases")

      assert_nil(Team.find_by(name: team_to_merge.name), "#{team_to_merge.name} should not be in DB")
      assert_equal(0, Result.where(team_id: team_to_merge.id).count, "Gentle Lovers's results")
      assert_equal(0, Person.where(team_id: team_to_merge.id).count, "Gentle Lovers's people")
      assert_equal(0, Alias.where(aliasable_id: team_to_merge.id).count, "Gentle Lovers's aliases")
      assert_same_elements(promoter_events, team_to_keep.events.reload, "Should merge sponsored events")
      assert_equal 1, EventTeam.count, "event teams"
      assert_equal 1, team_to_keep.event_teams.reload.count, "event teams"
      assert_equal 2, EventTeamMembership.count, "event team memberships"
      assert_equal team_to_keep, EventTeamMembership.first.team
      assert_equal team_to_keep, EventTeamMembership.second.team
    end

    test "merge with names" do
      current_year = Time.zone.today.year
      last_year = current_year - 1

      team_to_keep = Team.create!(name: "Team Oregon/River City Bicycles")
      team_to_keep_last_year = team_to_keep.names.create!(name: "Team Oregon/River City Bicycles", year: last_year)

      event = SingleDayEvent.create!
      senior_men = FactoryBot.create(:category)
      event.races.create!(category: senior_men).results.create!(place: "10", team: team_to_keep)

      event = SingleDayEvent.create!(date: Date.new(last_year))
      event.races.create!(category: senior_men).results.create!(place: "2", team: team_to_keep)

      team_to_merge = Team.create!(name: "Team O/RCB")
      team_to_merge.names.create!(name: "Team o IRCB", year: last_year)

      event = SingleDayEvent.create!
      event.races.create!(category: senior_men).results.create!(place: "4", team: team_to_merge)

      event = SingleDayEvent.create!(date: Date.new(last_year))
      team_to_merge_last_year_result = event.races.create!(category: senior_men).results.create!(place: "19", team: team_to_merge)

      team_to_keep.merge(team_to_merge)

      assert_not(Team.exists?(team_to_merge.id), "Should delete merged team")
      assert_equal(1, team_to_keep.names.count, "Target team historical names")
      assert_equal(team_to_keep_last_year, team_to_keep.names.first, "Target team historical name")

      # Ensure old results have proper team name
      assert_equal("Team o IRCB", team_to_merge_last_year_result.team_name)

      assert_equal(4, team_to_keep.results.count, "Target team's results")
      assert_equal(1, team_to_keep.names.count, "Target team's historical names")
      assert_equal(1, team_to_keep.aliases.count, "Target team's aliases")
    end

    test "merge with names no historical name" do
      current_year = Time.zone.today.year
      last_year = current_year - 1

      team_to_keep = Team.create!(name: "Team Oregon/River City Bicycles")

      event = SingleDayEvent.create!
      senior_men = FactoryBot.create(:category)
      event.races.create!(category: senior_men).results.create!(place: "10", team: team_to_keep)

      event = SingleDayEvent.create!(date: Date.new(last_year))
      event.races.create!(category: senior_men).results.create!(place: "2", team: team_to_keep)

      team_to_merge = Team.create!(name: "Team O/RCB")
      team_to_merge.names.create!(name: "Team o IRCB", year: last_year)

      event = SingleDayEvent.create!
      event.races.create!(category: senior_men).results.create!(place: "4", team: team_to_merge)

      event = SingleDayEvent.create!(date: Date.new(last_year))
      team_to_merge_last_year_result = event.races.create!(category: senior_men).results.create!(place: "19", team: team_to_merge)

      team_to_keep.merge(team_to_merge)

      assert_not(Team.exists?(team_to_merge.id), "Should delete merged team")
      assert_equal(1, team_to_keep.names.count, "Target team historical names")
      assert_equal("Team o IRCB", team_to_keep.names.first.name, "Target team historical name")

      # Ensure old results have proper team name
      assert_equal("Team o IRCB", team_to_merge_last_year_result.team_name)

      assert_equal(4, team_to_keep.results.count, "Target team's results")
      assert_equal(1, team_to_keep.aliases.count, "Target team's aliases")
    end

    test "merge with names that match existing team" do
      current_year = Time.zone.today.year
      last_year = current_year - 1

      team_to_keep = Team.create!(name: "Team Oregon/River City Bicycles")
      # Team to keep from last year
      team_to_keep.names.create!(name: "Team Oregon/River City Bicycles", year: last_year)

      team_to_merge = Team.create!(name: "Team O/RCB")
      team_to_merge.names.create!(name: "Team o IRCB", year: last_year)

      Team.create!(name: "Team o IRCB")

      person_with_team_name = Person.create!
      person_with_team_name.aliases.create! name: "Team Oregon/River City Bicycles"

      team_to_keep.merge team_to_merge
    end
  end
end
