require File.expand_path("../../../../../test_helper", __FILE__)

module Competitions
  module OregonJuniorCyclocrossSeries
    # :stopdoc:
    class TeamTest < ActiveSupport::TestCase
      test "calculate" do
        series = OregonJuniorCyclocrossSeries::Team.create!
        event = SingleDayEvent.create!
        series.source_events << event

        team = ::Team.create!(name: "Cazenovia High School")
        event_team = EventTeam.create!(team: team, event: series)

        junior_men_10_12 = Category.find_or_create_by(name: "Junior Men 10-12")
        person = FactoryGirl.create(:person)
        person.event_team_memberships.create!(event_team: event_team)
        race = event.races.create!(category: junior_men_10_12)
        race.results.create!(place: 3, person: person)

        person = FactoryGirl.create(:person)
        person.event_team_memberships.create!(event_team: event_team)
        race.results.create!(place: 5, person: person)

        person = FactoryGirl.create(:person)
        person.event_team_memberships.create!(event_team: event_team)
        race.results.create!(place: 17, person: person)

        # Fourth-best result
        person = FactoryGirl.create(:person)
        person.event_team_memberships.create!(event_team: event_team)
        race.results.create!(place: 18, person: person)

        team = ::Team.create!(name: "Chittenango High School")
        event_team = EventTeam.create!(team: team, event: series)

        # Only members (people) count
        person = FactoryGirl.create(:past_member)
        person.event_team_memberships.create!(event_team: event_team)
        race.results.create!(place: 2, person: person)

        # Only 2 members
        person = FactoryGirl.create(:person)
        person.event_team_memberships.create!(event_team: event_team)
        race.results.create!(place: 4, person: person)

        OregonJuniorCyclocrossSeries::Team.calculate!

        series = OregonJuniorCyclocrossSeries::Team.last
        assert_equal 1, series.races.count, "races"
        assert_equal "Oregon Junior Cyclocross Team Series", series.races.first.name
        results = series.races.first.results
        assert_equal 1, results.count, "results"
        result = results.first
        assert_equal "Cazenovia High School", result.team.name, "team"
        assert_equal 3, result.scores.size
        assert_equal 68, result.points
      end
    end
  end
end
