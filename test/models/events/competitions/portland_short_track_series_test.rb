require "test_helper"

module Competitions
  # :stopdoc:
  class PortlandShortTrackSeriesTest < ActiveSupport::TestCase
    test "calculate" do
      weekly_series = FactoryGirl.create(:weekly_series, name: "Portland Short Track Series MTB STXC")
      weekly_series.races.create!(category: Category.create!(name: "Elite Men")).results.create!(place: 1, person: Person.new, age: 30)

      PortlandShortTrackSeries::Overall.calculate!
      PortlandShortTrackSeries::MonthlyStandings.calculate!
      PortlandShortTrackSeries::TeamStandings.calculate!
    end

    test "partition_results_by_age_and_gender" do
      results = [
        { "category_name" => "Junior Men 10-14", "age" => 10, "gender" => "M" },
        { "category_name" => "Junior Men 10-14", "age" => 14, "gender" => "M" }
      ]
      team_standings = PortlandShortTrackSeries::TeamStandings.new

      partitioned_results = team_standings.partition_results_by_age_and_gender(results)
      assert_equal 1, partitioned_results.keys.size, partitioned_results.keys
      assert_equal "Men 10-14", partitioned_results.keys.first.name
      assert_equal [ results ], partitioned_results.values
    end

    test "partition_category_for" do
      team_standings = PortlandShortTrackSeries::TeamStandings.new

      result = { "category_name" => "Junior Men 10-14", "age" => 11, "gender" => "M", "category_ages_begin" => 10 }
      assert_equal "Men 10-14", team_standings.partition_category_for(result).name, "Junior Men 10-14"

      result = { "category_name" => "Category 2 Women U35", "age" => 33, "gender" => "F", "category_ages_begin" => 19 }
      assert_equal "Women 19-34", team_standings.partition_category_for(result).name, "Category 2 Women U35"

      result = { "category_name" => "Elite Men", "age" => 22, "gender" => "M", "category_ages_begin" => 0 }
      assert_equal "Men 19-34", team_standings.partition_category_for(result).name, "Elite Men"

      result = { "category_name" => "Men 19-34", "gender" => "M", "category_ages_begin" => 19 }
      assert_equal "Men 19-34", team_standings.partition_category_for(result).name, "Men 19-34, no result age"
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

      actual = team_standings.sort_by_ability_category_and_place(results)

      assert_equal expected, actual
    end

    test "reject_worst_category_results" do
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

      actual = team_standings.reject_worst_category_results(results)

      assert_equal expected, actual
    end

    test "add_category_points" do
      team_standings = PortlandShortTrackSeries::TeamStandings.new
      results = [
        { "category_ability" => 0, "place" => "1" },
        { "category_ability" => 2, "place" => "1" },
        { "category_ability" => 2, "place" => "2" },
        { "category_ability" => 3, "place" => "1" },
        { "category_ability" => 3, "place" => "2" },
      ]

      expected = [
        { "category_ability" => 0, "place" => "1", "points" => 100 },
        { "category_ability" => 2, "place" => "1", "points" => 80 },
        { "category_ability" => 2, "place" => "2", "points" => 60 },
        { "category_ability" => 3, "place" => "1", "points" => 40 },
        { "category_ability" => 3, "place" => "2", "points" => 20 },
      ]

      actual = team_standings.add_category_points(results)

      assert_equal expected, actual
    end
  end
end
