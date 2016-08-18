require "test_helper"

module Competitions
  # :stopdoc:
  class CrossCrusadeOverallTest < ActiveSupport::TestCase
    test "recalc with one event" do
      series = Series.create!(name: "Cross Crusade")
      event = series.children.create!(date: Date.new(2017, 10, 7), name: "Cross Crusade #4")

      series.children.create!(date: Date.new(2017, 10, 14))
      series.children.create!(date: Date.new(2017, 10, 21))
      series.children.create!(date: Date.new(2017, 10, 28))
      series.children.create!(date: Date.new(2017, 11, 5))

      series.reload
      assert_equal(Date.new(2017, 10, 7), series.date, "Series date")

      category_1_2 = Category.create!(name: "Category 1/2")
      category_1_2_race = event.races.create!(category: category_1_2)
      weaver = FactoryGirl.create(:person)
      category_1_2_race.results.create!(place: 1, person: weaver)
      tonkin = FactoryGirl.create(:person)
      category_1_2_race.results.create!(place: 9, person: tonkin)

      masters_35_plus_women = Category.find_or_create_by(name: "Masters Women 35+ 1/2")
      masters_race = event.races.create!(category: masters_35_plus_women)
      alice = FactoryGirl.create(:person)
      masters_race.results.create!(place: 15, person: alice)
      molly = FactoryGirl.create(:person)
      masters_race.results.create!(place: 19, person: molly)

      # Previous year should be ignored
      previous_event = Series.create!(name: "Cross Crusade").children.create!(date: Date.new(2006), name: "Cross Crusade #3")
      previous_event.races.create!(category: category_1_2).results.create!(place: 6, person: weaver)

      # Following year should be ignored
      following_event = Series.create!(name: "Cross Crusade").children.create!(date: Date.new(2018))
      following_event.races.create!(category: category_1_2).results.create!(place: 10, person: weaver)

      CrossCrusadeOverall.calculate!(2017)
      series = Series.find(series.id)
      overall = CrossCrusadeOverall.last
      assert_not_nil(overall, "Should add new Overall Competition child to parent Series")
      assert_equal 31, overall.races.size, "Overall races"

      assert_equal "Series Overall", overall.name, "Overall name"
      assert_equal "Cross Crusade: Series Overall", overall.full_name, "Overall full name"
      assert(!overall.notes.blank?, "Should have notes about rules")
      assert_equal_dates Date.new(2017, 10, 7), overall.date, "Overall series date"
      assert_equal_dates Date.new(2017, 10, 7), overall.start_date, "Overall series start date"
      assert_equal_dates Date.new(2017, 11, 5), overall.end_date, "Overall series end date"

      cx_a_overall_race = overall.races.detect { |race| race.category == category_1_2 }
      assert_not_nil(cx_a_overall_race, "Should have Category 1/2 overall race")
      assert_equal(2, cx_a_overall_race.results.size, "Category 1/2 race results")
      results = cx_a_overall_race.results(true).sort
      result = results.first
      assert_equal(false, result.preliminary?, "Preliminary?")
      assert_equal("1", result.place, "Category 1/2 first result place")
      assert_equal(26, result.points, "Category 1/2 first result points")
      assert_equal(weaver, result.person, "Category 1/2 first result person")
      result = results.last
      assert_equal(false, result.preliminary?, "Preliminary?")
      assert_equal("2", result.place, "Category 1/2 second result place")
      assert_equal(10, result.points, "Category 1/2 second result points (double points for last result)")
      assert_equal(tonkin, result.person, "Category 1/2 second result person")

      masters_35_plus_women_overall_race = overall.races.detect { |race| race.category == masters_35_plus_women }
      assert_not_nil(masters_35_plus_women_overall_race, "Should have Masters Women overall race")
      assert_equal(1, masters_35_plus_women_overall_race.results.size, "Masters Women race results")
      result = masters_35_plus_women_overall_race.results.first
      assert_equal(false, result.preliminary?, "Preliminary?")
      assert_equal("1", result.place, "Masters Women first result place")
      assert_equal(4, result.points, "Masters Women first result points  (double points for last result)")
      assert_equal(alice, result.person, "Masters Women first result person")
    end

    test "many results" do
      series = Series.create!(name: "Cross Crusade")
      masters = Category.find_or_create_by(name: "Masters 35+ 1/2")
      category_1_2 = Category.find_or_create_by(name: "Category 1/2")
      singlespeed = Category.find_or_create_by(name: "Singlespeed")
      person = Person.create!(name: "John Browning")

      event = series.children.create!(date: Date.new(2018, 10, 5))
      event.races.create!(category: masters).results.create!(place: 1, person: person)

      event = series.children.create!(date: Date.new(2018, 10, 12))
      event.races.create!(category: masters).results.create!(place: 1, person: person)

      event = series.children.create!(date: Date.new(2018, 10, 19))
      event.races.create!(category: masters).results.create!(place: 2, person: person)
      event.races.create!(category: category_1_2).results.create!(place: 4, person: person)
      event.races.create!(category: singlespeed).results.create!(place: 5, person: person)

      event = series.children.create!(date: Date.new(2018, 10, 26))
      event.races.create!(category: masters).results.create!(place: 1, person: person)

      event = series.children.create!(date: Date.new(2018, 11, 2))
      event.races.create!(category: masters).results.create!(place: 2, person: person)

      event = series.children.create!(date: Date.new(2018, 11, 9))
      event.races.create!(category: masters).results.create!(place: 1, person: person)
      event.races.create!(category: category_1_2).results.create!(place: 20, person: person)
      event.races.create!(category: singlespeed).results.create!(place: 12, person: person)

      event = series.children.create!(date: Date.new(2018, 11, 10))
      event.races.create!(category: masters).results.create!(place: 1, person: person)

      event = series.children.create!(date: Date.new(2018, 11, 17))
      event.races.create!(category: masters).results.create!(place: 3, person: person)
      event.races.create!(category: category_1_2).results.create!(place: 20, person: person)

      CrossCrusadeOverall.calculate! 2018

      masters_overall_race = CrossCrusadeOverall.last.races.detect { |race| race.category == masters }
      assert_not_nil(masters_overall_race, "Should have Masters overall race")
      results = masters_overall_race.results(true).sort
      result = results.first
      assert_equal(false, result.preliminary?, "Preliminary?")
      assert_equal("1", result.place, "place")
      assert_equal(6, result.scores.size, "Scores")
      assert_equal(26 + 26 + 0 + 26 + 0 + 26 + 20 + 26 + 0, result.points, "points")
      assert_equal(person, result.person, "person")

      category_1_2_overall_race = CrossCrusadeOverall.last.races.detect { |race| race.category == category_1_2 }
      assert_not_nil(category_1_2_overall_race, "Should have Category 1/2 overall race")
      results = category_1_2_overall_race.results(true).sort
      result = results.first
      assert_equal(false, result.preliminary?, "Preliminary?")
      assert_equal("1", result.place, "place")
      assert_equal(1, result.scores.size, "Scores")
      assert_equal(15, result.points, "points")
      assert_equal(person, result.person, "person")

      singlespeed_overall_race = CrossCrusadeOverall.last.races.detect { |race| race.category == singlespeed }
      assert_not_nil(singlespeed_overall_race, "Should have Singlespeed overall race")
      assert(singlespeed_overall_race.results.empty?, "Should not have any singlespeed results, but have #{singlespeed_overall_race.results.size}")
    end
  end
end
