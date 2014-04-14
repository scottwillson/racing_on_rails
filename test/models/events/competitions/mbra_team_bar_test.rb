require File.expand_path("../../../../test_helper", __FILE__)

# :stopdoc:
class MbraTeamBarTest < ActiveSupport::TestCase
  def test_calculate
    road = FactoryGirl.create(:discipline, name: "Road")

    senior_men   = FactoryGirl.create(:category, name: "Cat 1/2 Men")
    senior_women = FactoryGirl.create(:category, name: "Cat 1/2/3 Women")
    road.bar_categories << senior_men
    road.bar_categories << senior_women

    kona          = FactoryGirl.create(:team)
    chocolate     = FactoryGirl.create(:team, member: false)
    gentle_lovers = FactoryGirl.create(:team)
    vanilla = FactoryGirl.create(:team)

    swan_island = SingleDayEvent.create!(
      name: "Swan Island",
      discipline: "Road",
      date: Date.new(2008, 5, 17),
      team: kona
    )

    # future event, no results
    pigeon_island = SingleDayEvent.create!(
      name: "Pigeon Island",
      discipline: "Road",
      date: Date.new(2008, 7, 17),
      team: gentle_lovers
    )

    swan_island_senior_men = swan_island.races.create(category: senior_men, field_size: 7)

    tonkin = FactoryGirl.create(:person)
    swan_island_senior_men.results.create(
      place: 1,
      person: tonkin,
      team: kona
    )

    weaver = FactoryGirl.create(:person)
    swan_island_senior_men.results.create(
      place: 2,
      person: weaver,
      team: kona
    )

    matson = FactoryGirl.create(:person)
    swan_island_senior_men.results.create(
      place: 3,
      person: matson,
      team: kona
    )

    # non-member team -> no bat results
    molly = FactoryGirl.create(:person)
    swan_island_senior_men.results.create(
      place: 4,
      person: molly,
      team: chocolate
    )

    # no team -> no bat results
    member = FactoryGirl.create(:person)
    swan_island_senior_men.results.create(
      place: 5,
      person: member
    )

    # team does not sponsor an event for the discipline -> no bat results
    member = FactoryGirl.create(:person)
    swan_island_senior_men.results.create(
      place: 6,
      person: member,
      team: vanilla
    )

    alice = FactoryGirl.create(:person)
    swan_island_senior_men.results.create(
      place: "dnf",
      person: alice,
      team: gentle_lovers
    )

    # No BAT points
    senior_women_swan_island = swan_island.races.create(category: senior_women, field_size: 3, bar_points: 0)
    senior_women_swan_island.results.create(
      place: 1,
      person: tonkin,
      team: kona
    )

    assert_difference "Result.count", 2 do
      MbraTeamBar.calculate!(2008)
    end

    #MBRA BAR scoring rules: http://www.montanacycling.net/documents/racers/MBRA%20BAR-BAT.pdf

    road_bat = MbraTeamBar.find_by_name("2008 Road BAT")
    men_road_bat = road_bat.races.detect {|b| b.category == senior_men }
    assert_equal(senior_men, men_road_bat.category, "Senior Men BAT race BAT cat")
    assert_equal(2, men_road_bat.results.size, "Senior Men Road BAT results")

    results = men_road_bat.results.sort
    assert_equal(kona, results[0].team, "Senior Men Road BAT results team")
    assert_equal("1", results[0].place, "Senior Men Road BAT results place")
    assert_equal((7 + 6) + (6 + 3), results[0].points, "Senior Men Road BAT results points")

    assert_equal(gentle_lovers, results[1].team, "Senior Men Road BAT results team")
    assert_equal("2", results[1].place, "Senior Men Road BAT results place")
    assert_equal(0.5, results[1].points, "Senior Men Road BAT results points")

    women_road_bar = road_bat.races.detect {|b| b.category == senior_women }
    assert_equal(senior_women, women_road_bar.category, "Senior Women BAT race BAT cat")
    assert_equal(0, women_road_bar.results.size, "Senior Women Road BAT results")

    # championship event - double points for bar but not bat
    duck_island = SingleDayEvent.create!(
      name: "Duck Island",
      discipline: "Road",
      date: Date.new(2008, 6, 17),
      bar_points: 2
    )
    duck_island_senior_men = duck_island.races.create(category: senior_men, field_size: 2)

    duck_island_senior_men.results.create(
      place: 1,
      person: tonkin,
      team: kona
    )
    # team change
    duck_island_senior_men.results.create(
      place: 2,
      person: weaver,
      team: gentle_lovers
    )

    assert_difference "Result.count", 0 do
      MbraTeamBar.calculate!(2008)
    end

    road_bat = MbraTeamBar.find_by_name("2008 Road BAT")
    men_road_bat = road_bat.races.detect {|b| b.category == senior_men }
    assert_equal(senior_men, men_road_bat.category, "Senior Men BAT race BAT cat")
    assert_equal(2, men_road_bat.results.size, "Senior Men Road BAT results")

    results = men_road_bat.results.sort
    assert_equal(kona, results[0].team, "Senior Men Road BAT results team")
    assert_equal("1", results[0].place, "Senior Men Road BAT results place")
    assert_equal((7 + 6) + (6 + 3) + (2 + 6), results[0].points, "Senior Men Road BAT results points")

    assert_equal(gentle_lovers, results[1].team, "Senior Men Road BAT results team")
    assert_equal("2", results[1].place, "Senior Men Road BAT results place")
    assert_equal(0.5 + (1 + 3), results[1].points, "Senior Men Road BAT results points")
  end
end
