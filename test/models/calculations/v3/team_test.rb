# frozen_string_literal: true

require "test_helper"

# :stopdoc:
class Calculations::V3::TeamTest < ActiveSupport::TestCase
  setup { FactoryBot.create :discipline }

  test "Team BAR" do
    Timecop.travel(2019, 11) do
      road_discipline = Discipline[:road]
      road = Calculations::V3::Calculation.create!(
        discipline: road_discipline,
        disciplines: [road_discipline],
        key: "road_bar",
        name: "Road BAR",
        members_only: true,
        points_for_place: [15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
        weekday_events: false
      )
      road.categories << ::Category.find_or_create_by(name: "Senior Women")

      calculation = Calculations::V3::Calculation.create!(
        association_sanctioned_only: true,
        members_only: true,
        points_for_place: [15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
        team: true,
        weekday_events: false,
        year: 2019
      )

      event = FactoryBot.create(:event, date: Time.zone.local(2019, 2, 3))
      race = FactoryBot.create(:race, event: event)
      team = FactoryBot.create(:team)
      person = FactoryBot.create(:person)
      race.results.create!(place: 5, person: person, team: team)

      road.calculate!
      calculation.calculate!

      calculation_event = calculation.reload.event
      assert_equal 1, calculation_event.races.size, calculation_event.races.map(&:name)
      team_race = calculation_event.races.detect { |r| r.category.name == "Team" }
      assert_not_nil(team_race, "Should have only Team race")

      results = team_race.results.sort
      assert_equal 1, results.size

      result = results.first
      assert_not result.rejected?, result.rejection_reason
      assert_equal "1", result.place
      assert_equal 11, result.points
      assert_equal team, result.team
      assert_nil result.person
      assert result.team_competition_result?
    end
  end

  test "#calculate!" do
    series = WeeklySeries.create!(date: Time.zone.local(2018, 10, 6))
    source_child_event = series.children.create!(date: Time.zone.local(2018, 10, 6))

    athena = ::Category.find_or_create_by_normalized_name("Athena")
    source_race = source_child_event.races.create!(category: athena)
    person_1 = FactoryBot.create(:person)
    team = FactoryBot.create(:team, member: false)
    source_race.results.create!(place: 1, person: person_1, team: team)
    person_2 = FactoryBot.create(:person)
    team_2 = FactoryBot.create(:team)
    source_race.results.create!(place: 2, person: person_2, team: team_2)
    source_race.results.create!(place: 3, person: person_2)

    women_345 = ::Category.find_or_create_by_normalized_name("Women 3/4/5")
    source_race = source_child_event.races.create!(category: women_345)
    source_race.results.create!(place: 1, person: person_1, team: team)

    # Don't count overall
    calculation = series.calculations.create!(year: 2018)
    overall = ::Event.create!(date: Time.zone.local(2018, 10, 6))
    calculation.event = overall
    race = overall.races.create!(category: athena)
    race.results.create!(competition_result: true, place: 1, person: person_1, team: team)

    calculation = series.calculations.create!(
      key: :team_comp,
      missing_result_penalty: 100,
      place_by: "fewest_points",
      points_for_place: (1..100).to_a,
      results_per_event: 10,
      team: true,
      year: 2018
    )
    calculation.calculation_categories.create! category: women_345, reject: true

    2.times do
      calculation.calculate!

      calculation_event = calculation.reload.event
      assert_equal 1, calculation_event.races.size, calculation_event.races.map(&:name)
      team_race = calculation_event.races.detect { |r| r.category.name == "Team" }
      assert_not_nil(team_race, "Should have only Team race")

      results = team_race.results.sort
      assert_equal 2, results.size

      result = results.first
      assert_nil result.person
      assert_equal "1", result.place
      assert_equal 901, result.points
      assert_equal team, result.team
      assert result.team_competition_result?

      assert_equal 3, result.sources.size
      assert_equal [0, 1, 900], result.sources.map(&:points).sort

      result = results.last
      assert_nil result.person
      assert_equal "2", result.place
      assert_equal 902, result.points
      assert_equal team_2, result.team

      assert_equal 2, result.sources.size
      sources = result.sources.sort
      assert_equal 2, sources.first.points
      assert_equal 900, sources.last.points
    end
  end
end
