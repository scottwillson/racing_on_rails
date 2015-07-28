require "test_helper"

module Competitions
  # :stopdoc:
  class PortlandShortTrackSeriesTest < ActiveSupport::TestCase
    test "calculate" do
      weekly_series = FactoryGirl.create(:weekly_series, name: "Portland Short Track Series")
      event = FactoryGirl.create(:event, parent: weekly_series)
      event.races.create!(category: Category.create!(name: "Elite Men")).results.create!(place: 1, person: Person.new, age: 30)

      PortlandShortTrackSeries::Overall.calculate!
      PortlandShortTrackSeries::TeamStandings.calculate!
    end

    test "calculate upgrades" do
      weekly_series = FactoryGirl.create(:weekly_series, name: "Portland Short Track Series")

      person = FactoryGirl.create(:person)
      event = FactoryGirl.create(:event, parent: weekly_series)
      event.races.create!(category: Category.create!(name: "Category 2 Women 35-44")).results.create!(place: 1, person: person)

      event = FactoryGirl.create(:event, parent: weekly_series)
      event.races.create!(category: Category.create!(name: "Elite/Category 1 Women")).results.create!(place: 13, person: person)

      PortlandShortTrackSeries::Overall.calculate!

      overall = PortlandShortTrackSeries::Overall.first

      race = overall.races.detect { |r| r.name == "Category 2 Women 35-44" }
      assert_equal 1, race.results.size
      assert_equal 100, race.results.first.points

      race = overall.races.detect { |r| r.name == "Elite/Category 1 Women" }
      assert_equal 1, race.results.size
      assert_equal 70, race.results.first.points
    end

    test "group_results_by_team_standings_categories" do
      results = [
        { "category_name" => "Junior Men 10-14", "age" => 10, "category_gender" => "M", "category_ages_begin" => 10, "category_ages_end" => 14 },
        { "category_name" => "Junior Men 10-14", "age" => 14, "category_gender" => "M", "category_ages_begin" => 10, "category_ages_end" => 14 }
      ]
      team_standings = PortlandShortTrackSeries::TeamStandings.new

      partitioned_results = team_standings.group_results_by_team_standings_categories(results)
      assert_equal 1, partitioned_results.keys.size, partitioned_results.keys
      assert_equal "Men 10-14", partitioned_results.keys.first.name
      assert_equal [ results ], partitioned_results.values
    end

    test "team_standings_category_for" do
      team_standings = PortlandShortTrackSeries::TeamStandings.new

      result = { "category_name" => "Junior Men 10-14", "age" => 11, "category_gender" => "M", "category_ages_begin" => 10, "category_ages_end" => 14 }
      assert_equal "Men 10-14", team_standings.team_standings_category_for(result).name, "Junior Men 10-14"

      result = { "category_name" => "Category 2 Women U35", "age" => 33, "category_gender" => "F", "category_ages_begin" => 0, "category_ages_end" => 34 }
      assert_equal "Women 19-34", team_standings.team_standings_category_for(result).name, "Category 2 Women U35"

      result = { "category_name" => "Elite Men", "age" => 22, "category_gender" => "M", "category_ages_begin" => 0, "category_ages_end" => 999 }
      assert_equal "Men 19-34", team_standings.team_standings_category_for(result).name, "Elite Men"

      result = { "category_name" => "Men 19-34", "category_gender" => "M", "category_ages_begin" => 19, "category_ages_end" => 34 }
      assert_equal "Men 19-34", team_standings.team_standings_category_for(result).name, "Men 19-34, no result age"

      result = { "category_name" => "Category 2 Men U35", "category_gender" => "M", "category_ages_begin" => 0, "category_ages_end" => 34, "age" => 16 }
      assert_equal "Men 15-18", team_standings.team_standings_category_for(result).name, "Men 15-18"

      result = { "category_name" => "Category 1 Men 45+", "category_gender" => "M", "category_ages_begin" => 45, "category_ages_end" => 999, "age" => 59 }
      assert_equal "Men 55+", team_standings.team_standings_category_for(result).name, "Category 1 Men 45+"

      result = { "category_name" => "Category 3 Men 19-44", "category_gender" => "M", "category_ages_begin" => 29, "category_ages_end" => 44, "age" => 43 }
      assert_equal "Men 35-44", team_standings.team_standings_category_for(result).name, "Category 3 Men 19-44"
    end

    test "sort_results_by_ability_category_and_place" do
      team_standings = PortlandShortTrackSeries::TeamStandings.new

      results = [
        { "category_ability" => 3, "place" => "4" },
        { "category_ability" => 0, "place" => "5" },
        { "category_ability" => 2, "place" => "4" },
        { "category_ability" => 2, "place" => "63" },
        { "category_ability" => 2, "place" => "9" },
        { "category_ability" => 2, "place" => "51" },
        { "category_ability" => 1, "place" => "4" },
      ]

      expected = [
        { "category_ability" => 0, "place" => "5" },
        { "category_ability" => 1, "place" => "4" },
        { "category_ability" => 2, "place" => "4" },
        { "category_ability" => 2, "place" => "9" },
        { "category_ability" => 2, "place" => "51" },
        { "category_ability" => 2, "place" => "63" },
        { "category_ability" => 3, "place" => "4" },
      ]

      actual = team_standings.sort_by_ability_and_place(results)

      assert_equal expected, actual
    end

    test "reject_worst_results" do
      team_standings = PortlandShortTrackSeries::TeamStandings.new

      results = [
        { "category_ability" => 0, "place" => "5" },
        { "category_ability" => 1, "place" => "4" },
        { "category_ability" => 2, "place" => "4" },
        { "category_ability" => 2, "place" => "9" },
        { "category_ability" => 2, "place" => "51" },
        { "category_ability" => 2, "place" => "63" },
        { "category_ability" => 2, "place" => "64" },
        { "category_ability" => 2, "place" => "65" },
        { "category_ability" => 2, "place" => "66" },
        { "category_ability" => 2, "place" => "66" },
        { "category_ability" => 2, "place" => "66" },
        { "category_ability" => 2, "place" => "67" },
        { "category_ability" => 2, "place" => "68" },
        { "category_ability" => 2, "place" => "69" },
        { "category_ability" => 3, "place" => "102" },
      ]

      expected = [
        { "category_ability" => 0, "place" => "5" },
        { "category_ability" => 1, "place" => "4" },
        { "category_ability" => 2, "place" => "4" },
        { "category_ability" => 2, "place" => "9" },
        { "category_ability" => 2, "place" => "51" },
        { "category_ability" => 2, "place" => "63" },
        { "category_ability" => 2, "place" => "64" },
        { "category_ability" => 2, "place" => "65" },
        { "category_ability" => 2, "place" => "66" },
        { "category_ability" => 2, "place" => "66" },
        { "category_ability" => 2, "place" => "66" },
        { "category_ability" => 2, "place" => "67" },
        { "category_ability" => 2, "place" => "68" },
        { "category_ability" => 3, "place" => "102" },
      ]

      actual = team_standings.reject_worst_results(results)

      assert_equal expected, actual
    end

    test "add_points" do
      team_standings = PortlandShortTrackSeries::TeamStandings.new
      results = [
        { "category_ability" => 0, "place" => "1" },
        { "category_ability" => 2, "place" => "1" },
        { "category_ability" => 2, "place" => "2" },
        { "category_ability" => 3, "place" => "1" },
        { "category_ability" => 3, "place" => "2" },
      ]

      expected = [
        { "category_ability" => 0, "place" => "1", "points" => 100, "notes"=>"1/5 in " },
        { "category_ability" => 2, "place" => "1", "points" => 80, "notes"=>"2/5 in " },
        { "category_ability" => 2, "place" => "2", "points" => 60, "notes"=>"3/5 in " },
        { "category_ability" => 3, "place" => "1", "points" => 40, "notes"=>"4/5 in " },
        { "category_ability" => 3, "place" => "2", "points" => 20, "notes"=>"5/5 in " },
      ]

      actual = team_standings.add_points(Category.new, results)

      assert_equal expected, actual
    end
  end
end
