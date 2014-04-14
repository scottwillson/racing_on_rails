# There is duplication between BAR tests, but refactring the tests should wait until the Competition refactoring is complete

require File.expand_path("../../../../test_helper", __FILE__)

# :stopdoc:
class OverallBarTest < ActiveSupport::TestCase
  def test_calculate
    alice  = FactoryGirl.create(:person)
    matson = FactoryGirl.create(:person)
    molly  = FactoryGirl.create(:person)
    tonkin = FactoryGirl.create(:person)
    weaver = FactoryGirl.create(:person)

    kona = FactoryGirl.create(:team)

    association_category = FactoryGirl.create(:category, name: "CBRA")
    senior_men           = FactoryGirl.create(:category, name: "Senior Men", parent: association_category)
    men_a                = FactoryGirl.create(:category, name: "Men A", parent: senior_men)
    sr_p_1_2             = FactoryGirl.create(:category, name: "Senior Men Pro 1/2", parent: senior_men)
    senior_women         = FactoryGirl.create(:category, name: "Senior Women", parent: association_category)
    senior_women_1_2_3 = FactoryGirl.create(:category, name: "Senior Women 1/2/3", parent: senior_women)

    discipline = FactoryGirl.create(:discipline, name: "Road")
    discipline.bar_categories << senior_men
    discipline.bar_categories << senior_women

    discipline = FactoryGirl.create(:discipline, name: "Time Trial")
    discipline.bar_categories << senior_men
    discipline.bar_categories << senior_women

    discipline = FactoryGirl.create(:discipline, name: "Cyclocross")
    discipline.bar_categories << men_a

    discipline = FactoryGirl.create(:discipline, name: "Track")
    discipline.bar_categories << senior_men

    discipline = FactoryGirl.create(:discipline, name: "Criterium")
    discipline.bar_categories << senior_men

    discipline = FactoryGirl.create(:discipline, name: "Mountain Bike")
    discipline.bar_categories << senior_men

    discipline = FactoryGirl.create(:discipline, name: "Overall")
    discipline.bar_categories << senior_men
    discipline.bar_categories << senior_women

    cross_crusade = Series.create!(name: "Cross Crusade")
    barton = SingleDayEvent.create!(
      name: "Cross Crusade: Barton Park",
      discipline: "Cyclocross",
      date: Date.new(2004, 11, 7),
      parent: cross_crusade
    )
    barton_a = barton.races.create!(category: men_a, field_size: 5)
    barton_a.results.create!(
      place: 3,
      person: tonkin
    )
    barton_a.results.create!(
      place: 15,
      person: weaver
    )

    swan_island = SingleDayEvent.create!(
      name: "Swan Island",
      discipline: "Criterium",
      date: Date.new(2004, 5, 17),
    )
    swan_island_senior_men = swan_island.races.create!(category: senior_men, field_size: 4)
    swan_island_senior_men.results.create!(
      place: 12,
      person: tonkin
    )
    swan_island_senior_men.results.create!(
      place: 2,
      person: molly
    )
    # No BAR points
    senior_women_swan_island = swan_island.races.create!(category: senior_women, field_size: 3, bar_points: 0)
    senior_women_swan_island.results.create!(
      place: 1,
      person: molly
    )

    thursday_track_series = Series.create!(name: "Thursday Track")
    thursday_track = SingleDayEvent.create!(
      name: "Thursday Track",
      discipline: "Track",
      date: Date.new(2004, 5, 12),
      parent: thursday_track_series
    )
    thursday_track_senior_men = thursday_track.races.create!(category: senior_men, field_size: 6)
    r = thursday_track_senior_men.results.create!(
      place: 5,
      person: weaver
    )
    thursday_track_senior_men.results.create!(
      place: 14,
      person: tonkin,
      team: kona
    )

    team_track = SingleDayEvent.create!(
      name: "Team Track State Championships",
      discipline: "Track",
      date: Date.new(2004, 9, 1),
      bar_points: 2
    )
    team_track_senior_men = team_track.races.create!(category: senior_men, field_size: 6)
    team_track_senior_men.results.create!(
      place: 1,
      person: weaver,
      team: kona
    )
    team_track_senior_men.results.create!(
      place: 1,
      person: tonkin,
      team: kona
    )
    team_track_senior_men.results.create!(
      place: 1,
      person: molly
    )
    team_track_senior_men.results.create!(
      place: 5,
      person: alice
    )
    team_track_senior_men.results.create!(
      place: 5,
      person: matson
    )
    # Weaver and Erik's second ride should not count
    team_track_senior_men.results.create!(
      place: 15,
      person: weaver,
      team: kona
    )
    team_track_senior_men.results.create!(
      place: 15,
      person: tonkin,
      team: kona
    )

    larch_mt_hillclimb = SingleDayEvent.create!(
      name: "Larch Mountain Hillclimb",
      discipline: "Time Trial",
      date: Date.new(2004, 2, 1)
    )
    larch_mt_hillclimb_senior_men = larch_mt_hillclimb.races.create!(category: senior_men, field_size: 6)
    larch_mt_hillclimb_senior_men.results.create!(
      place: 13,
      person: tonkin,
      team: kona
    )

    event = FactoryGirl.create(:event, date: Date.new(2004))
    race = event.races.create!(category: sr_p_1_2)
    race.results.create!(place: "1", person: tonkin)
    race.results.create!(place: "2", person: weaver)
    race.results.create!(place: "3", person: matson)
    race = event.races.create!(category: senior_women_1_2_3)
    race.results.create!(place: "2", person: alice)
    race.results.create!(place: "15", person: molly)

    # previous year does note count
    event = FactoryGirl.create(:event, date: Date.new(2003, 12, 31))
    race = event.races.create!(category: sr_p_1_2)
    race.results.create!(place: "4", person: tonkin)

    # next year does note count
    event = FactoryGirl.create(:event, date: Date.new(2005, 1, 1))
    race = event.races.create!(category: sr_p_1_2)
    race.results.create!(place: "5", person: tonkin)

    Bar.calculate!(2004)
    # Discipline BAR results past 300 don't count -- add fake result
    bar = Bar.find_by_year_and_discipline(2004, "Road")
    assert_not_nil bar.parent, "Should have parent"
    sr_men_road_bar = bar.races.detect {|r| r.category == senior_men}
    sr_men_road_bar.results.create!(place: 305, person: alice)

    assert_difference "Result.count", 7 do
      OverallBar.calculate!(2004)
    end
    overall_bar = OverallBar.find_for_year!(2004)
    assert_equal(Date.new(2004, 1, 1), overall_bar.date, "2004 Bar date")
    assert_equal("2004 Overall BAR", overall_bar.name, "2004 Bar name")
    assert_equal_dates(Time.zone.today, overall_bar.updated_at, "BAR last updated")
    assert_equal(15, overall_bar.races.size, "2004 Overall Bar races")
    assert_equal 6, overall_bar.children.size, "Overall BAR children"

    senior_men_overall_bar = overall_bar.races.detect do |b|
      b.name == "Senior Men"
    end

    assert_equal(senior_men, senior_men_overall_bar.category, "Senior Men BAR race BAR cat")
    assert_equal(5, senior_men_overall_bar.results.size, "Senior Men Overall BAR results")
    assert_equal_dates(Time.zone.today, senior_men_overall_bar.updated_at, "BAR last updated")
    results = senior_men_overall_bar.results.to_a.sort

    assert_equal(tonkin, results[0].person, "Senior Men Overall BAR results person")
    assert_equal("1", results[0].place, "Senior Men Overall BAR results place")
    assert_equal(1498, results[0].points, "Tonkin Senior Men Overall BAR results points")
    assert_equal(5, results[0].scores.size, "Tonkin Overall BAR results scores")
    scores = results[0].scores.sort {|x, y| y.points <=> x.points}
    assert_equal(300, scores[0].points, "Tonkin overall BAR points for discipline 0")
    assert_equal(300, scores[1].points, "Tonkin overall BAR points for discipline 1")
    assert_equal(300, scores[2].points, "Tonkin overall BAR points for discipline 2")
    assert_equal(299, scores[3].points, "Tonkin overall BAR points for discipline 3")
    assert_equal(299, scores[4].points, "Tonkin overall BAR points for discipline 4")

    assert_equal(weaver, results[1].person, "Senior Men Overall BAR results person")
    assert_equal("2", results[1].place, "Senior Men Overall BAR results place")
    assert_equal(898, results[1].points, "Senior Men Overall BAR results points")
    assert_equal(3, results[1].scores.size, "Weaver Overall BAR results scores")

    assert_equal(molly, results[2].person, "Senior Men Overall BAR results person")
    assert_equal("3", results[2].place, "Senior Men Overall BAR results place")
    assert_equal(596, results[2].points, "Senior Men Overall BAR results points")

    women_overall_bar = overall_bar.races.detect do |b|
      b.name == "Senior Women"
    end
    assert_equal(senior_women, women_overall_bar.category, "Senior Women BAR race BAR cat")
    assert_equal(2, women_overall_bar.results.size, "Senior Women Overall BAR results")

    results = women_overall_bar.results.to_a.sort
    assert_equal(alice, results[0].person, "Senior Women Overall BAR results person")
    assert_equal("1", results[0].place, "Senior Women Overall BAR results place")
    assert_equal(300, results[0].points, "Senior Women Overall BAR results points")

    assert_equal(molly, results[1].person, "Senior Women Overall BAR results person")
    assert_equal("2", results[1].place, "Senior Women Overall BAR results place")
    assert_equal(299, results[1].points, "Senior Women Overall BAR results points")
    assert_equal(1, results[1].scores.size, "Molly Women Overall BAR results scores")
  end

  def test_drop_cat_5_discipline_results
    alice  = FactoryGirl.create(:person, name: "Alice Pennington")
    matson = FactoryGirl.create(:person, name: "Mark Matson")
    molly  = FactoryGirl.create(:person, name: "Molly Cameron")
    tonkin = FactoryGirl.create(:person, name: "Erik Tonkin")
    weaver = FactoryGirl.create(:person)

    association_category = FactoryGirl.create(:category, name: "CBRA")
    senior_men           = FactoryGirl.create(:category, name: "Senior Men", parent: association_category)
    men_a                = FactoryGirl.create(:category, name: "Men A", parent: senior_men)
    sr_p_1_2             = FactoryGirl.create(:category, name: "Senior Men Pro 1/2", parent: senior_men)
    senior_women         = FactoryGirl.create(:category, name: "Senior Women", parent: association_category)
    senior_women_1_2_3   = FactoryGirl.create(:category, name: "Senior Women 1/2/3", parent: senior_women)
    category_3_men       = FactoryGirl.create(:category, name: "Category 3 Men", parent: association_category)
    category_4_5_men     = FactoryGirl.create(:category, name: "Category 4/5 Men", parent: association_category)
    category_4_men       = FactoryGirl.create(:category, name: "Category 4 Men", parent: category_4_5_men)
    category_5_men       = FactoryGirl.create(:category, name: "Category 5 Men", parent: category_4_5_men)

    discipline = FactoryGirl.create(:discipline, name: "Road")
    discipline.bar_categories << senior_men
    discipline.bar_categories << senior_women
    discipline.bar_categories << category_3_men
    discipline.bar_categories << category_4_men
    discipline.bar_categories << category_5_men

    discipline = FactoryGirl.create(:discipline, name: "Time Trial")
    discipline.bar_categories << senior_men
    discipline.bar_categories << senior_women
    discipline.bar_categories << category_3_men
    discipline.bar_categories << category_4_men
    discipline.bar_categories << category_5_men

    discipline = FactoryGirl.create(:discipline, name: "Cyclocross")
    discipline.bar_categories << men_a

    discipline = FactoryGirl.create(:discipline, name: "Track")
    discipline.bar_categories << senior_men
    discipline.bar_categories << category_3_men
    discipline.bar_categories << category_4_men
    discipline.bar_categories << category_5_men

    discipline = FactoryGirl.create(:discipline, name: "Criterium")
    discipline.bar_categories << senior_men
    discipline.bar_categories << senior_women
    discipline.bar_categories << category_3_men
    discipline.bar_categories << category_4_men
    discipline.bar_categories << category_5_men

    discipline = FactoryGirl.create(:discipline, name: "Mountain Bike")
    discipline.bar_categories << senior_men
    discipline.bar_categories << category_3_men
    discipline.bar_categories << category_4_men
    discipline.bar_categories << category_5_men

    discipline = FactoryGirl.create(:discipline, name: "Overall")
    discipline.bar_categories << senior_men
    discipline.bar_categories << senior_women
    discipline.bar_categories << category_3_men
    discipline.bar_categories << category_4_5_men

    event = SingleDayEvent.create!(discipline: 'Road')
    cat_4_race = event.races.create!(category: category_4_men)
    cat_4_race.results.create!(place: '4', person: weaver)
    cat_4_race.results.create!(place: '5', person: matson)

    cat_5_race = event.races.create!(category: category_5_men)
    cat_5_race.results.create!(place: '6', person: matson)
    cat_5_race.results.create!(place: '15', person: tonkin)

    event = SingleDayEvent.create!(discipline: 'Road')
    cat_5_race = event.races.create!(category: category_5_men)
    cat_5_race.results.create!(place: '15', person: tonkin)

    # Add several different discipline results to expose ordering bug
    event = SingleDayEvent.create!(discipline: "Criterium")
    event.races.create!(category: category_4_men).results.create!(place: 3, person: matson)
    event.races.create!(category: category_4_men).results.create!(place: 6, person: tonkin)
    event.races.create!(category: category_4_men).results.create!(place: 12, person: molly)
    event.races.create!(category: category_4_men).results.create!(place: 15, person: weaver)

    event = SingleDayEvent.create!(discipline: "Mountain Bike")
    event.races.create!(category: category_3_men).results.create!(place: 14, person: matson)
    event.races.create!(category: category_3_men).results.create!(place: 15, person: weaver)

    event = SingleDayEvent.create!(discipline: "Track")
    event.races.create!(category: category_4_men).results.create!(place: 6, person: tonkin)
    event.races.create!(category: category_4_men).results.create!(place: 14, person: matson)
    event.races.create!(category: category_4_men).results.create!(place: 15, person: weaver)

    event.races.create!(category: category_5_men).results.create!(place: 1, person: weaver)

    sevent = SingleDayEvent.create!(discipline: "Time Trial")
    sevent.races.create!(category: category_5_men).results.create!(place: 1, person: weaver)
    sevent.races.create!(category: category_5_men).results.create!(place: 15, person: matson)

    Bar.calculate!
    OverallBar.calculate!

    current_year = Time.zone.today.year
    road_bar = Bar.find_by_year_and_discipline(current_year, "Road")
    cat_4_road_bar = road_bar.races.detect { |race| race.category == category_4_men }
    assert_equal(2, cat_4_road_bar.results.size, "Cat 4 Overall BAR results")
    cat_5_road_bar = road_bar.races.detect { |race| race.category == category_5_men }
    assert_equal(2, cat_5_road_bar.results.size, "Cat 5 Overall BAR results")

    overall_bar = OverallBar.find_by_date(Date.new(current_year, 1, 1))
    cat_4_5_overall_bar = overall_bar.races.detect { |race| race.category == category_4_5_men }
    assert_equal(4, cat_4_5_overall_bar.results.size, "Cat 4/5 Overall BAR results")

    matson_result = cat_4_5_overall_bar.results.detect { |result| result.person == matson }
    assert_equal("1", matson_result.place, "Matson Cat 4/5 Overall BAR place")
    assert_equal(1497.0, matson_result.points, "Matson Cat 4/5 Overall BAR points")
    assert_equal(5, matson_result.scores.size, "Matson Cat 4/5 Overall BAR 1st place scores")

    weaver_result = cat_4_5_overall_bar.results.detect { |result| result.person == weaver }
    assert_equal("2", weaver_result.place, "Weaver Cat 4/5 Overall BAR place")
    assert_equal(300, weaver_result.scores.detect { |s| s.source_result.race.discipline == "Road" }.points, "Road points")
    assert_equal(300, weaver_result.scores.detect { |s| s.source_result.race.discipline == "Time Trial" }.points, "Time Trial points")
    assert_equal(299, weaver_result.scores.detect { |s| s.source_result.race.discipline == "Mountain Bike" }.points, "Mountain Bike points")
    assert_equal(298, weaver_result.scores.detect { |s| s.source_result.race.discipline == "Track" }.points, "Track points")
    assert_equal(297, weaver_result.scores.detect { |s| s.source_result.race.discipline == "Criterium" }.points, "Criterium points")
    assert_equal(300 + 300 + 299 + 298 + 297, weaver_result.points, "Weaver Cat 4/5 Overall BAR points")
    assert_equal(5, weaver_result.scores.size, "Weaver Cat 4/5 Overall BAR 1st place scores")

    tonkin_result = cat_4_5_overall_bar.results.detect { |result| result.person == tonkin }
    assert_equal("3", tonkin_result.place, "Tonkin Cat 4/5 Overall BAR place")
    assert_equal(898.0, tonkin_result.points, "Tonkin Cat 4/5 Overall BAR points")
    assert_equal(3, tonkin_result.scores.size, "Tonkin Cat 4/5 Overall BAR 1st place scores")
    assert_equal(299, tonkin_result.scores.detect { |s| s.source_result.race.discipline == "Road" }.points, "Road points")
    assert_equal(category_5_men, tonkin_result.scores.detect { |s| s.source_result.race.discipline == "Road" }.source_result.race.category, "Road category")
    assert_equal(300, tonkin_result.scores.detect { |s| s.source_result.race.discipline == "Track" }.points, "Track points")
    assert_equal(category_4_men, tonkin_result.scores.detect { |s| s.source_result.race.discipline == "Track" }.source_result.race.category, "Road category")
    assert_equal(299, tonkin_result.scores.detect { |s| s.source_result.race.discipline == "Criterium" }.points, "Criterium points")
    assert_equal(category_4_men, tonkin_result.scores.detect { |s| s.source_result.race.discipline == "Criterium" }.source_result.race.category, "Road category")
  end
end
