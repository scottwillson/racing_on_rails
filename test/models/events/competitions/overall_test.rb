require File.expand_path("../../../../test_helper", __FILE__)

module Competitions
  # :stopdoc:
  class OverallTest < ActiveSupport::TestCase
    class TestOverall < Overall
      def self.parent_event_name
        "Test Series"
      end

      def category_names
        [ "Men A" ]
      end

      def point_schedule
        [ 26, 20, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ]
      end

      def minimum_events
        2
      end

      def maximum_events(race)
        6
      end
    end

    test "calculate with no series" do
      assert_no_difference "Competition.count" do
        TestOverall.calculate!
        TestOverall.calculate! 2007
      end
    end

    test "preliminary results after event minimum" do
      series = Series.create!(name: "Test Series")

      series.children.create!(date: Date.new(2007, 10, 7))
      series.children.create!(date: Date.new(2007, 10, 14))
      series.children.create!(date: Date.new(2007, 10, 21))
      series.children.create!(date: Date.new(2007, 10, 28))
      series.children.create!(date: Date.new(2007, 11, 5))

      men_a = Category.find_or_create_by(name: "Men A")
      men_a_race = series.children[0].races.create!(category: men_a)
      weaver = FactoryGirl.create(:person)
      men_a_race.results.create!(place: 1, person: weaver)
      tonkin = FactoryGirl.create(:person)
      men_a_race.results.create!(place: 2, person: tonkin)

      men_a_race = series.children[1].races.create!(category: men_a)
      men_a_race.results.create!(place: 43, person: weaver)

      men_a_race = series.children[2].races.create!(category: men_a)
      men_a_race.results.create!(place: 1, person: weaver)

      men_a_race = series.children[3].races.create!(category: men_a)
      men_a_race.results.create!(place: 8, person: tonkin)

      TestOverall.calculate!(2007)

      men_a_overall_race = series.overall(true).races.detect { |race| race.category == men_a }
      assert_not_nil(men_a_overall_race, "Should have Men A overall race")
      results = men_a_overall_race.results(true).sort
      result = results.first
      assert_equal(false, result.preliminary?, "Weaver did three races. His result should not be preliminary")

      result = men_a_overall_race.results.last
      assert_equal(false, result.preliminary?, "Tonkin did two races. His result should not be preliminary")
      assert_equal Date.new(2007, 10, 7), series.reload.date, "date"
      assert_equal Date.new(2007, 11, 5), series.end_date, "end_date"
    end

    test "count six best results" do
      series = Series.create!(name: "Test Series")
      men_a = Category.find_or_create_by(name: "Men A")
      person = Person.create!(name: "Kevin Hulick")

      date = Date.new(2008, 10, 19)
      [8, 3, 10, 7, 8, 7, 8].each do |place|
        series.children.create!(date: date).races.create!(category: men_a).results.create!(place: place, person: person)
        date = date + 7
      end

      # Simulate 7 of 8 events. Last, double-point event still in future
      series.children.create!(date: date).races.create!(category: men_a)

      TestOverall.calculate!(2008)

      men_a_overall_race = series.overall(true).races.detect { |race| race.category == men_a }
      assert_not_nil(men_a_overall_race, "Should have Men A overall race")
      results = men_a_overall_race.results(true).sort
      result = results.first
      assert_equal(6, result.scores.size, "Scores")
      assert_equal(16 + 12 + 12 + 11 + 11 + 11, result.points, "points")
    end

    test "choose best results by place" do
      series = Series.create!(name: "Test Series")
      men_a = Category.find_or_create_by(name: "Men A")
      person = Person.create!(name: "Kevin Hulick")

      date = Date.new(2008, 10, 19)
      [8, 8, 8, 7, 6, 8, 7, 9].each do |place|
        series.children.create!(date: date).races.create!(category: men_a).results.create!(place: place, person: person)
        date = date + 7
      end

      TestOverall.calculate!(2008)

      men_a_overall_race = series.overall(true).races.detect { |race| race.category == men_a }
      assert_not_nil(men_a_overall_race, "Should have Men A overall race")
      result = men_a_overall_race.results.sort.first
      assert_equal(6, result.scores.size, "Scores")
      assert_equal(11 + 12 + 13 + 11 + 12 + 11, result.points, "points")
    end

    test "ensure dnf sorted correctly" do
      series = Series.create!(name: "Test Series")
      men_a = Category.find_or_create_by(name: "Men A")
      person = Person.create!(name: "Kevin Hulick")

      date = Date.new(2008, 10, 19)
      [8, 3, 10, "DNF", 8, 7, 8].each do |place|
        series.children.create!(date: date).races.create!(category: men_a).results.create!(place: place, person: person)
        date = date + 7
      end

      # Simulate 7 of 8 events. Last, double-point, event, still in future
      series.children.create!(date: date).races.create!(category: men_a)

      TestOverall.calculate!(2008)

      men_a_overall_race = series.overall(true).races.detect { |race| race.category == men_a }
      assert_not_nil(men_a_overall_race, "Should have Men A overall race")
      result = men_a_overall_race.results.sort.first
      assert_equal(6, result.scores.size, "Scores")
      assert_equal(16 + 12 + 11 + 11 + 11 + 9, result.points, "points")
    end

    test "ignore age graded bar" do
      series = Series.create!(name: "Test Series")
      men_a = Category.find_or_create_by(name: "Men A")
      series.children.create!(date: Date.new(2007, 10, 7))
      event = series.children.create!(date: Date.new(2007, 10, 14))

      men_a_race = event.races.create!(category: men_a)
      alice = FactoryGirl.create(:person)
      men_a_race.results.create!(place: 17, person: alice)

      age_graded_race = AgeGradedBar.create!(name: "Age Graded Results for BAR/Championships").races.create!(category: men_a)
      age_graded_race.results.create!(place: 1, person: alice)

      TestOverall.calculate!(2007)

      men_a_overall_race = series.overall(true).races.detect { |race| race.category == men_a }
      assert_equal(1, men_a_overall_race.results.size, "Cat A results")
      assert_equal(1, men_a_overall_race.results.first.scores.size, "Should ignore age-graded BAR")
    end

    test "should count for bar, nor ironman" do
      series = Series.create!(name: "Test Series")
      men_a = Category.find_or_create_by(name: "Men A")
      series.children.create!(date: Date.new(2008)).races.create!(category: men_a).results.create!(place: "4", person: FactoryGirl.create(:person))

      TestOverall.calculate!(2008)
      series.reload

      overall_results = series.overall(true)
      assert_equal(false, overall_results.ironman, "Ironman")
      assert_equal(0, overall_results.bar_points, "BAR points")

      men_a_overall_race = overall_results.races.detect { |race| race.category == men_a }
      assert_equal(0, men_a_overall_race.bar_points, "Race BAR points")
    end
  end
end
