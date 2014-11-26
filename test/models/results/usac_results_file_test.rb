# coding: utf-8

require "test_helper"

# :stopdoc:
module Results
  class USACResultsFileTest < ActiveSupport::TestCase
    test "race" do
      results_file = USACResultsFile.new(File.new(File.expand_path("../../../fixtures/results/tt_usac.xls", __FILE__)), SingleDayEvent.new)
      book = ::Spreadsheet.open(File.expand_path("../../../fixtures/results/tt_usac.xls", __FILE__))
      results_file.create_rows(book.worksheet(0))

      assert(results_file.race?(results_file.rows[0]), 'New race')
      assert(!results_file.race?(results_file.rows[1]), 'New race')
      assert(!results_file.race?(results_file.rows[2]), 'New race')
      assert(!results_file.race?(results_file.rows[3]), 'New race')
      assert(!results_file.race?(results_file.rows[4]), 'New race')
      assert(results_file.race?(results_file.rows[5]), "New race: #{results_file.rows[5]}")
      assert(!results_file.race?(results_file.rows[6]), "New race: #{results_file.rows[6]}")
      assert(!results_file.race?(results_file.rows[7]), 'New race')
    end

    test "create columns" do
      book = ::Spreadsheet.open(File.expand_path("../../../fixtures/results/tt_usac.xls", __FILE__))
      spreadsheet_row = book.worksheet(0).row(0)
      results_file = USACResultsFile.new(File.new(File.expand_path("../../../fixtures/results/tt_usac.xls", __FILE__)), SingleDayEvent.new)
      column_indexes = results_file.create_columns(spreadsheet_row)
      assert_equal({
        time: 14,
        last_name: 10,
        first_name: 11,
        category_class: 7,
        team_name: 13,
        category_name: 5,
        place: 15,
        number: 12,
        gender: 6,
        license: 9,
        age: 8
      }, column_indexes, "column_indexes")
    end

    test "non sequential results" do
      event = SingleDayEvent.create!
      results_file = USACResultsFile.new(File.new(File.expand_path("../../../fixtures/results/non_sequential_usac_results.xls", __FILE__)), event)
      results_file.import
      assert results_file.import_warnings.present?, "Should have import warnings for non-sequential usac results"
    end

    test "import excel" do
      event = SingleDayEvent.create!(discipline: 'Road', date: Date.new(2008, 5, 11))
      source_path = File.expand_path("../../../fixtures/results/tt_usac.xls", __FILE__)
      results_file = USACResultsFile.new(File.new(source_path), event)
      assert_equal(source_path, results_file.source.path, "file path")
      results_file.import

      expected_races = get_expected_races
      assert_equal(expected_races.size, event.races.size, "Expected #{expected_races.size} event races but was #{event.races.size}")
      expected_races.each_with_index do |expected_race, index|
        actual_race = event.races[index]
        assert_not_nil(actual_race, "race #{index}")
        assert_not_nil(actual_race.results, "results for category #{expected_race.category}")
        assert_equal(expected_race.results.size, actual_race.results.size, "Results")
        assert_equal(expected_race.name, actual_race.name, "Name")
        actual_race.results.sort.each_with_index do |result, result_index|
          expected_result = expected_race.results[result_index]
          assert_equal(expected_result.place, result.place, "place for race #{index} result #{result_index} #{expected_result.first_name} #{expected_result.last_name}")
          if result.license && result.license.empty? #may have found person by license
            assert_equal(expected_result.first_name, result.first_name, "first_name for race #{index} result #{result_index}")
            assert_equal(expected_result.last_name, result.last_name, "last_name for race #{index} result #{result_index}")
          end
          assert_equal(expected_result.team_name, result.team_name, "team name for race #{index} result #{result_index}")
        end
      end
    end

    test "race notes" do
      event = SingleDayEvent.create!
      results_file = USACResultsFile.new(File.new(File.expand_path("../../../fixtures/results/tt_usac.xls", __FILE__)), event)
      results_file.import
      assert_equal('USCF, 2008, 563, 2012-05-11, Stage Race', event.races(true).first.notes, 'Race notes')
    end

    def get_expected_races
      races = []

      race = Race.new(category: Category.new(name: "Master A Men"))
      race.results << Result.new(place: "1", first_name: "David", last_name: "Landstrom", number:"20", license:"20280", team_name:"Flathead Cycling", time: "0:37:32")
      race.results << Result.new(place: "2", first_name: "Richard", last_name: "Graves", number:"223", license:"13949", team_name:"Flathead Cycling", time: "0:40:36")
      race.results << Result.new(place: "3", first_name: "David", last_name: "West", number:"201", license:"63105", team_name:"Echelon Cycling", time: "0:40:49")
      race.results << Result.new(place: "DQ", first_name: "Robert", last_name: "Ray", number:"237", license:"68315", team_name:"Great Divide")
      race.results << Result.new(place: "DNS", first_name: "Chad", last_name: "Elkin", number:"264", license:"279240", team_name:"Great Falls Bicycle Club")
      races << race

      race = Race.new(category: Category.new(name: "Junior Men 10-18"))
      race.results << Result.new(place: "1", first_name: "Phil", last_name: "Rayner", number:"335", team_name:"Headwinds", time: "0:38:33")
      race.results << Result.new(place: "2", first_name: "Thomas", last_name: "Greason", number:"212", license:"46661", team_name:"Bozeman Masters Velo", time: "0:38:36")
      race.results << Result.new(place: "DNF", first_name: "Maxwell", last_name: "Yanof", number:"468", license:"236853", team_name:"Bozeman Masters Velo")
      races << race

      races
    end
  end
end
