# FIXME Assert correct team names on BAR results

require File.expand_path("../../../../test_helper", __FILE__)

module Competitions
  # :stopdoc:
  class MbraBarTest < ActiveSupport::TestCase
    test "calculate" do
      road = FactoryGirl.create(:discipline, name: "Road")
      FactoryGirl.create(:discipline, name: "Mountain Bike")
      FactoryGirl.create(:discipline, name: "Cyclocross")

      senior_men = FactoryGirl.create(:category, name: "Category 1/2 Men")
      senior_women = FactoryGirl.create(:category, name: "Category 1/2/3 Women")
      road.bar_categories << senior_men
      road.bar_categories << senior_women

      swan_island = SingleDayEvent.create!(
        name: "Swan Island",
        discipline: "Road",
        date: Date.new(2008, 5, 17)
      )
      swan_island_senior_men = swan_island.races.create(category: senior_men, field_size: 5)

      tonkin = FactoryGirl.create(:person)
      swan_island_senior_men.results.create(
        place: 1,
        person: tonkin
      )

      molly = FactoryGirl.create(:person)
      swan_island_senior_men.results.create(
        place: 2,
        person: molly
      )

      weaver = FactoryGirl.create(:person)
      swan_island_senior_men.results.create(
        place: 3,
        person: weaver
      )

      alice = FactoryGirl.create(:person)
      swan_island_senior_men.results.create(
        place: "DNF",
        person: alice
      )

      matson = FactoryGirl.create(:person)
      swan_island_senior_men.results.create(
        place: "DQ",
        person: matson
      )

      # single racer in category
      senior_women_swan_island = swan_island.races.create(category: senior_women, field_size: 1)
      senior_women_swan_island.results.create(
        place: 1,
        person: molly
      )

      assert_difference "Result.count", 5 do
        MbraBar.calculate!(2008)
      end
      assert_equal(3, MbraBar.where(date: Date.new(2008)).count, "Bar events after calculate!")
      MbraBar.where(date: Date.new(2008)).each do |bar|
        assert(bar.name[/2008.*BAR/], "Name #{bar.name} is wrong")
        assert_equal_dates(Time.zone.today, bar.updated_at, "BAR last updated")
      end

      road_bar = MbraBar.find_by_name("2008 Road BAR")
      men_road_bar = road_bar.races.detect {|b| b.category == senior_men }
      assert_equal(senior_men, men_road_bar.category, "Senior Men BAR race BAR cat")
      assert_equal(4, men_road_bar.results.size, "Senior Men Road BAR results")

      results = men_road_bar.results.sort
      assert_equal(tonkin, results[0].person, "Senior Men Road BAR results person")
      assert_equal("1", results[0].place, "Senior Men Road BAR results place")
      assert_equal(5 + 6, results[0].points, "Senior Men Road BAR results points")

      assert_equal(weaver, results[2].person, "Senior Men Road BAR results person")
      assert_equal("3", results[2].place, "Senior Men Road BAR results place")
      assert_equal(3 + 1, results[2].points, "Senior Men Road BAR results points")

      assert_equal(alice, results[3].person, "Senior Men Road BAR results person")
      assert_equal("4", results[3].place, "Senior Men Road BAR results place - dnf")
      assert_equal(0.5, results[3].points, "Senior Men Road BAR results points - dnf")

      women_road_bar = road_bar.races.detect {|b| b.category == senior_women }
      assert_equal(senior_women, women_road_bar.category, "Senior Women BAR race BAR cat")
      assert_equal(1, women_road_bar.results.size, "Senior Women Road BAR results")

      result = women_road_bar.results.sort.first
      assert_equal(molly, result.person, "Senior Women Road BAR results person")
      assert_equal("1", result.place, "Senior Women Road BAR results place")
      assert_equal((1 + 6), result.points, "Senior Women Road BAR results points")

      #championship event - double points
      duck_island = SingleDayEvent.create!(
        name: "Duck Island",
        discipline: "Road",
        date: Date.new(2008, 6, 17),
        bar_points: 2
      )
      duck_island_senior_men = duck_island.races.create(category: senior_men, field_size: 5)

      duck_island_senior_men.results.create(
        place: 1,
        person: tonkin
      )
      duck_island_senior_men.results.create(
        place: 2,
        person: molly
      )
      #two 2nd place racers both should get 2nd place points
      duck_island_senior_men.results.create(
        place: 2,
        person: weaver
      )
      FactoryGirl.create(:result, place: 4, event: duck_island, race: duck_island_senior_men)
      FactoryGirl.create(:result, place: 5, event: duck_island, race: duck_island_senior_men)

      senior_women_duck_island = duck_island.races.create(category: senior_women, field_size: 1)
      senior_women_duck_island.results.create(
        place: 1,
        person: molly
      )

      # these results should be dropped due to 70% of events rule
      goose_island = SingleDayEvent.create!(
        name: "Goose Island",
        discipline: "Road",
        date: Date.new(2008, 7, 17)
      )
      goose_island_senior_men = goose_island.races.create(category: senior_men, field_size: 2)

      goose_island_senior_men.results.create(
        place: 1,
        person: tonkin
      )
      goose_island_senior_men.results.create(
        place: 2,
        person: molly
      )
      senior_women_goose_island = goose_island.races.create(category: senior_women, field_size: 1)
      senior_women_goose_island.results.create(
        place: 1,
        person: molly
      )

      assert_difference "Result.count", 2 do
        MbraBar.calculate!(2008)
      end
      assert_equal(3, MbraBar.where(date: Date.new(2008)).count, "Bar events after calculate!")

      road_bar = MbraBar.find_by_name("2008 Road BAR")
      men_road_bar = road_bar.races.detect {|b| b.category == senior_men }
      assert_equal(senior_men, men_road_bar.category, "Senior Men BAR race BAR cat")
      assert_equal(6, men_road_bar.results.size, "Senior Men Road BAR results")

      results = men_road_bar.results.sort
      assert_equal(tonkin, results[0].person, "Senior Men Road BAR results person")
      assert_equal("1", results[0].place, "Senior Men Road BAR results place")
      assert_equal((5 + 6) + ((5 + 6) * 2), results[0].points, "Senior Men Road BAR results points")

      assert_equal(molly, results[1].person, "Senior Men Road BAR results person")
      assert_equal("2", results[1].place, "Senior Men Road BAR results place")
      assert_equal((4 + 3) + ((4 + 3) * 2), results[1].points, "Senior Men Road BAR results points")

      assert_equal(weaver, results[2].person, "Senior Men Road BAR results person")
      assert_equal("3", results[2].place, "Senior Men Road BAR results place")
      assert_equal((3 + 1) + ((4 + 3) * 2), results[2].points, "Senior Men Road BAR results points")

      women_road_bar = road_bar.races.detect {|b| b.category == senior_women }
      assert_equal(senior_women, women_road_bar.category, "Senior Women BAR race BAR cat")
      assert_equal(1, women_road_bar.results.size, "Senior Women Road BAR results")

      assert_equal(molly, women_road_bar.results[0].person, "Senior Women Road BAR results person")
      assert_equal("1", women_road_bar.results[0].place, "Senior Women Road BAR results place")
      assert_equal((1 + 6) + ((1 + 6) * 2), women_road_bar.results[0].points, "Senior Women Road BAR results points")

       # No BAR points
       egret_island = SingleDayEvent.create!(
        name: "Egret Island",
        discipline: "Road",
        date: Date.new(2008, 7, 17),
        bar_points: 0
      )
      senior_women_egret_island = egret_island.races.create(category: senior_women, field_size: 99)
      senior_women_egret_island.results.create(
        place: 1,
        person: molly
      )

      assert_difference "Result.count", 0 do
        MbraBar.calculate!(2008)
      end

      road_bar = MbraBar.find_by_name("2008 Road BAR")
      women_road_bar = road_bar.races.detect {|b| b.category == senior_women }
      assert_equal(senior_women, women_road_bar.category, "Senior Women BAR race BAR cat")
      assert_equal(1, women_road_bar.results.size, "Senior Women Road BAR results")
      assert_equal(molly, women_road_bar.results[0].person, "Senior Women Road BAR results person")
      assert_equal("1", women_road_bar.results[0].place, "Senior Women Road BAR results place")
      assert_equal((1 + 6) + ((1 + 6) * 2), women_road_bar.results[0].points, "Senior Women Road BAR results points")
    end

    test "upgrade scoring" do
      road = FactoryGirl.create(:discipline, name: "Road")
      FactoryGirl.create(:discipline, name: "Mountain Bike")
      FactoryGirl.create(:discipline, name: "Cyclocross")

      senior_men = FactoryGirl.create(:category, raw_name: "Category 1/2 Men")
      senior_women = FactoryGirl.create(:category, raw_name: "Category 1/2/3 Women")
      cat_4_women = FactoryGirl.create(:category, raw_name: "Category 4 Women")
      road.bar_categories << senior_men
      road.bar_categories << senior_women
      road.bar_categories << cat_4_women

      swan_island = SingleDayEvent.create!(
        name: "Swan Island",
        discipline: "Road",
        date: Date.new(2008, 5, 17)
      )
      cat_4_women_swan_island = swan_island.races.create(category: cat_4_women, field_size: 23)
      molly = FactoryGirl.create(:person)
      cat_4_women_swan_island.results.create(
        place: 1,
        person: molly
      )
      FactoryGirl.create_list(:result, 22, event: swan_island, race: cat_4_women_swan_island)
      goose_island = SingleDayEvent.create!(
        name: "Goose Island",
        discipline: "Road",
        date: Date.new(2008, 7, 17)
      )
      cat_1_2_3_women_goose_island = goose_island.races.create(category: senior_women, field_size: 3)
      cat_1_2_3_women_goose_island.results.create(
        place: 1,
        person: molly
      )
      FactoryGirl.create_list(:result, 2, event: goose_island, race: cat_1_2_3_women_goose_island)

      MbraBar.calculate!(2008)
      road_bar = MbraBar.find_by_name("2008 Road BAR")
      cat_4_women_road_bar = road_bar.races.detect {|b| b.name == "Category 4 Women" }
      assert_equal(molly, cat_4_women_road_bar.results[0].person, "Category 4 Women Road BAR results person")
      assert_equal("1", cat_4_women_road_bar.results[0].place, "Category 4 Women Road BAR results place")
      assert_equal((23 + 6), cat_4_women_road_bar.results[0].points, "Category 4 Women Road BAR results points")

      cat_1_2_3_women_road_bar = road_bar.races.detect {|b| b.name == "Category 1/2/3 Women" }
      assert_equal(molly, cat_1_2_3_women_road_bar.results[0].person, "Category 1/2/3 Women Road BAR results person")
      assert_equal("1", cat_1_2_3_women_road_bar.results[0].place, "Category 1/2/3 Women Road BAR results place")
      assert_equal(((23 + 6) / 2.0) + (3 + 6), cat_1_2_3_women_road_bar.results[0].points, "Category 1/2/3 Women Road BAR results points")

      # test max 30 upgrade points
      duck_island = SingleDayEvent.create!(
        name: "Duck Island",
        discipline: "Road",
        date: Date.new(2008, 6, 17)
      )
      cat_4_women_duck_island = duck_island.races.create(category: cat_4_women, field_size: 27)
      cat_4_women_duck_island.results.create(
        place: 1,
        person: molly
      )
      FactoryGirl.create_list(:result, 26, event: duck_island, race: cat_4_women_duck_island)
       MbraBar.calculate!(2008)
      road_bar = MbraBar.find_by_name("2008 Road BAR")
      cat_4_women_road_bar = road_bar.races.detect {|b| b.name == "Category 4 Women" }
      assert_equal(molly, cat_4_women_road_bar.results[0].person, "Category 4 Women Road BAR results person")
      assert_equal("1", cat_4_women_road_bar.results[0].place, "Category 4 Women Road BAR results place")
      assert_equal((23 + 6) + (27 + 6), cat_4_women_road_bar.results[0].points, "Category 4 Women Road BAR results points")

      cat_1_2_3_women_road_bar = road_bar.races.detect {|b| b.name == "Category 1/2/3 Women" }
      assert_equal(molly, cat_1_2_3_women_road_bar.results[0].person, "Category 1/2/3 Women Road BAR results person")
      assert_equal("1", cat_1_2_3_women_road_bar.results[0].place, "Category 1/2/3 Women Road BAR results place")
      assert_equal(30 + (3 + 6), cat_1_2_3_women_road_bar.results[0].points, "Category 1/2/3 Women Road BAR results points")
    end
  end
end
