# frozen_string_literal: true

require "test_helper"

# :stopdoc:
module Results
  # FIXME: DNF's not handled correctly.

  class ResultsFileTest < ActiveSupport::TestCase
    setup :setup_number_issuer

    def setup_number_issuer
      FactoryBot.create(:discipline)
      FactoryBot.create(:number_issuer)
    end

    test "new" do
      file = Tempfile.new("test_results.txt")
      ResultsFile.new(file, SingleDayEvent.new)

      ResultsFile.new("text \t results", SingleDayEvent.new)
    end

    test "import excel" do
      current_members = Person.where("member_to >= ?", Time.zone.now)
      event = SingleDayEvent.create!(discipline: "Road", date: Date.new(2006, 1, 16))
      source_path = File.expand_path("../../fixtures/results/pir_2006_format.xlsx", __dir__)
      results_file = ResultsFile.new(File.new(source_path), event)
      assert_equal(source_path, results_file.source.path, "file path")
      results_file.import

      expected_races = get_expected_races
      assert_equal(expected_races.size, event.races.size, "Expected #{expected_races.size} event races but was #{event.races.size}")
      expected_races.each_with_index do |expected_race, index|
        actual_race = event.races[index]
        assert_not_nil(actual_race, "race #{index}")
        assert_not_nil(actual_race.results, "results for category #{expected_race.category}")
        assert_equal(expected_race.results.size, actual_race.results.size, "Results")
        race_date = actual_race.date
        actual_race.results.sort.each_with_index do |result, result_index|
          expected_result = expected_race.results[result_index]
          assert_equal(expected_result.place, result.place, "place for race #{index} result #{result_index} #{expected_result.first_name} #{expected_result.last_name}")
          if result.license && result.license.empty? # may have found person by license
            if expected_result.first_name
              assert_equal(expected_result.first_name, result.first_name, "first_name for race #{index} result #{result_index}")
            else
              assert_nil(result.first_name, "first_name for race #{index} result #{result_index}")
            end

            if expected_result.last_name
              assert_equal(expected_result.last_name, result.last_name, "last_name for race #{index} result #{result_index}")
            else
              assert_nil(result.last_name, "last_name for race #{index} result #{result_index}")
            end
          end

          if expected_result.team_name
            assert_equal(expected_result.team_name, result.team_name, "team name for race #{index} result #{result_index}")
          else
            assert_nil(result.team_name, "team name for race #{index} result #{result_index}")
          end

          assert_equal(expected_result.points, result.points, "points for race #{index} result #{result_index}")
          next unless result.person

          if RaceNumber.rental?(result.number, Discipline[event.discipline])
            assert_not(result.person.member?(race_date), "Person should not be a member because he has a rental number")
          elsif RacingAssociation.current.add_members_from_results? || current_members.include?(result.person)
            assert(result.person.member?(race_date), "member? for race #{index} result #{result_index} #{result.name} #{result.person.member_from} #{result.person.member_to}")
            assert_not_equal(
              Time.zone.today,
              result.person.member_from,
              "#{result.name} membership date should existing date or race date, but never today (#{result.person.member_from})"
            )
          else
            assert_not(result.person.member?(race_date), "member? for race #{index} result #{result_index} #{result.name} #{result.person.member_from} #{result.person.member_to}")
          end
          # test result by license (some with name misspelled)
          if result.license && RacingAssociation.current.eager_match_on_license?
            person_by_lic = Person.find_by(license: result.license)
            assert_equal(result.person, person_by_lic, "Result should be assigned to #{person_by_lic.name} by license but was given to #{result.person.name}") if person_by_lic
          end
        end
      end
    end

    test "import time trial people with same name" do
      FactoryBot.create(:discipline, name: "Time Trial")
      bruce_109 = Person.create!(first_name: "Bruce", last_name: "Carter")
      bruce_109.race_numbers.create(year: Time.zone.today.year, value: "109")

      bruce_1300 = Person.create!(first_name: "Bruce", last_name: "Carter")
      bruce_1300.race_numbers.create!(year: Time.zone.today.year, value: "1300")

      existing_weaver = FactoryBot.create(:person, name: "Ryan Weaver", road_number: "341")
      existing_matson = FactoryBot.create(:person, name: "Mark Matson", road_number: "340")

      event = SingleDayEvent.create!(discipline: "Time Trial")

      results_file = ResultsFile.new(File.new(File.expand_path("../../fixtures/results/tt.xlsx", __dir__)), event)
      results_file.import

      assert_equal(2, event.races.reload.size, "event races")
      assert_equal(7, event.races[0].results.size, "Results")
      sorted_results = event.races[0].results.sort
      assert_equal("1", sorted_results.first.place, "First result place")
      assert_in_delta(2252.0, sorted_results.first.time, 0.0001, "First result time")
      assert_equal("7", sorted_results.last.place, "Last result place")
      assert_in_delta(2762.0, sorted_results.last.time, 0.0001, "Last result time")

      race = event.races.first
      assert_equal(8, race.result_columns.size, "Columns size")
      assert_equal("place", race.result_columns[0], "Column 0 name")
      assert_equal("category_name", race.result_columns[2], "Column 2 name")

      assert_equal(2, Person.where(first_name: "bruce", last_name: "carter").count, "Bruce Carters after import")

      assert_not(event.races.empty?, "event.races should not be empty")

      # Existing people, same name, different numbers
      bruce_1300 = event.races.first.results[6].person
      bruce_109 = event.races.last.results[2].person
      assert_not_nil(bruce_1300, "bruce_1300")
      assert_not_nil(bruce_109, "bruce_109")
      assert_equal(bruce_1300.name.downcase, bruce_109.name.downcase, "Bruces with different numbers should have same name")
      assert_not_equal(bruce_1300, bruce_109, "Bruces with different numbers should be different people")
      assert_not_equal(bruce_1300.id, bruce_109.id, "Bruces with different numbers should have different IDs")

      # New person, same name, different number
      scott_90 = event.races.first.results[5].person
      scott_400 = event.races.last.results[3].person
      assert_equal(scott_90.name.downcase, scott_400.name.downcase, "New people with different numbers should have same name")
      assert_equal(scott_90, scott_400, "New people with different numbers should be same people")
      assert_equal(scott_90.id, scott_400.id, "New people with different numbers should have same IDs")

      # Existing person, same name, different number
      new_weaver = event.races.last.results.first.person
      assert_equal(existing_weaver.name, new_weaver.name, "Weavers with different numbers should have same name")
      assert_equal(existing_weaver, new_weaver, "Weavers with different numbers should be same people")
      assert_equal(existing_weaver.id, new_weaver.id, "Weavers with different numbers should have same IDs")

      # New person, different name, same number
      kurt = event.races.first.results[2].person
      alan = event.races.first.results[3].person
      assert_not_equal(kurt, alan, "Person with different names, same numbers should be different people")

      # Existing person, different name, same number
      new_matson = event.races.first.results.first.person
      assert_not_equal(existing_matson, new_matson, "Person with different numbers should be different people")
    end

    test "import 2006 v2" do
      FactoryBot.create(:discipline, name: "Circuit")
      expected_races = []

      paul_bourcier = Person.create!(first_name: "Paul", last_name: "Bourcier", member: true)
      eweb = Team.create!(name: "EWEB Windpower")
      paul_bourcier.team = eweb
      paul_bourcier.save!
      assert(paul_bourcier.errors.empty?)
      assert(eweb.errors.empty?)
      assert_equal(eweb, paul_bourcier.team.reload, "Paul Bourcier team")

      chris_myers = Person.create!(first_name: "Chris", last_name: "Myers", member: true)
      assert_nil(chris_myers.team, "Chris Myers team")

      race = Race.new(category: Category.new(name: "Pro/1/2"))
      race.results << Result.new(place: "1", first_name: "Paul", last_name: "Bourcier", number: "146", team_name: "Hutch's Eugene", points: "10.0")
      race.results << Result.new(place: "2", first_name: "John", last_name: "Browning", number: "197", team_name: "Half Fast Velo", points: "3.0")
      race.results << Result.new(place: "3", first_name: "Seth", last_name: "Hosmer", number: "158", team_name: "CMG Racing", points: "")
      race.results << Result.new(place: "4", first_name: "Sam", last_name: "Johnson", number: "836", team_name: "Broadmark Berman/Hagens LLC", points: "")
      race.results << Result.new(place: "5", first_name: "Mark", last_name: "Steger", number: "173", team_name: "CMG Racing", points: "3.0")
      race.results << Result.new(place: "6", first_name: "Nick", last_name: "Skenzick", number: "114", team_name: "Hutch's Eugene", points: "")
      race.results << Result.new(place: "7", first_name: "Chris", last_name: "Myers", number: "812", team_name: "Camerati", points: "")
      race.results << Result.new(place: "8", number: "Logie", points: "")
      race.results << Result.new(place: "9", first_name: "Dan", last_name: "Quirk", number: "117", team_name: "Veloce/Felt", points: "1.0")
      race.results << Result.new(place: "DNF", first_name: "Jason", last_name: "Chapman", number: "185", points: "")
      race.results << Result.new(place: "DNF", first_name: "Jay", last_name: "Freyensee", number: "826", team_name: "Easton", points: "")
      expected_races << race

      race = Race.new(category: Category.new(name: "Cat 3"))
      race.results << Result.new(place: "1", first_name: "Aaron", last_name: "Coker", number: "519", team_name: "CMG Racing", points: "5.0")
      race.results << Result.new(place: "2", first_name: "David", last_name: "Roth", number: "593", team_name: "Team Green Eugene", points: "")
      race.results << Result.new(place: "3", first_name: "Bradley", last_name: "Ritter", number: "571", team_name: "Garage", points: "")
      expected_races << race

      # TODO: Import starters/field size
      race = Race.new(category: Category.new(name: "Cat 4/5"))
      race.results << Result.new(place: "1", first_name: "John", last_name: "Wilson", number: "1107", team_name: "EWEB Windpower", points: "")
      race.results << Result.new(place: "2", first_name: "Jonathan", last_name: "Long", number: "412", team_name: "Bicycling Hub", points: "")
      race.results << Result.new(place: "3", first_name: "Kenneth", last_name: "Peterson", number: "2216", team_name: "UofO", points: "")
      race.results << Result.new(place: "4", first_name: "Brady", last_name: "Brady", number: "415", team_name: "Team Oregon/River City Bicycles", points: "")
      expected_races << race

      event = SingleDayEvent.create!(discipline: "Circuit")
      results_file = ResultsFile.new(File.new(File.expand_path("../../fixtures/results/2006_v2.xls", __dir__)), event)
      results_file.import

      assert_equal(expected_races.size, event.races.size, "event races")
      expected_races.each_with_index do |expected_race, index|
        actual_race = event.races[index]
        assert_not_nil(actual_race, "race #{index}")
        assert_not_nil(actual_race.results, "results for category #{expected_race.category}")
        assert_equal(expected_race.results.size, actual_race.results.size, "Results size for race #{index}")
        actual_race.results.sort.each_with_index do |result, result_index|
          expected_result = expected_race.results[result_index]
          assert_equal(expected_result.place, result.place, "place for race #{index} result #{result_index}")
          if expected_result.first_name
            assert_equal(expected_result.first_name, result.first_name, "first_name for race #{index} result #{result_index}")
          else
            assert_nil(result.first_name, "first_name for race #{index} result #{result_index}")
          end

          if expected_result.last_name
            assert_equal(expected_result.last_name, result.last_name, "last_name for race #{index} result #{result_index}")
          else
            assert_nil(result.last_name, "last_name for race #{index} result #{result_index}")
          end

          if expected_result.team_name
            assert_equal(expected_result.team_name, result.team_name, "team name for race #{index} result #{result_index}")
          else
            assert_nil(result.team_name, "team name for race #{index} result #{result_index}")
          end
          assert_equal(expected_result.points, result.points, "points for race #{index} result #{result_index}")
          assert_equal(expected_result.number, result.number, "Result number for race #{index} result #{result_index}")
          assert_nil(result.person.road_number, "Road number") if result.person && RaceNumber.rental?(result.number, Discipline[event.discipline])
        end
      end

      paul_bourcier.reload
      assert_equal(eweb, paul_bourcier.team.reload, "Paul Bourcier team should not be overwritten by results")
      chris_myers.reload
      assert_nil(chris_myers.team, "Chris Myers team should not be updated by results")

      browning = Person.find_by(name: "John Browning")
      assert_equal(event.name, browning.created_by_name, "created_by_name")
      assert_equal("SingleDayEvent", browning.created_by_type, "created_by")
      assert_equal("SingleDayEvent", browning.updated_by_type, "updated_by_paper_trail")
      assert_equal(event.id, browning.created_by_id, "team created_by")
      assert_equal(event.id, browning.updated_by_id, "team updated_by_paper_trail")
      assert_equal("SingleDayEvent", browning.team.created_by_type, "created_by")
      assert_equal("SingleDayEvent", browning.team.updated_by_type, "updated_by_paper_trail")
      assert_equal(event.id, browning.team.created_by_id, "team created_by")
      assert_equal(event.id, browning.team.updated_by_id, "team updated_by_paper_trail")
    end

    test "import and reuse races" do
      # race       exists?   in_results_file   order?   after_import
      # pro_1_2    Y          Y                 Y         Y + results
      # cat_3      Y          Y                           Y + results
      # cat_4      Y                            Y         Y
      # cat_5      Y                                      Y
      # w_1_2                 Y                           Y + results
      # Other combinations are invalid

      event = SingleDayEvent.create!(date: Time.zone.today + 3)
      pro_1_2_race = event.races.create! category: Category.find_or_create_by(name: "Pro/1/2")
      event.races.create! category: Category.find_or_create_by(name: "Category 3"), visible: false
      event.races.create! category: Category.find_or_create_by(name: "Category 4")
      event.races.create! category: Category.find_or_create_by(name: "Category 5")

      weaver = FactoryBot.create(:person)
      pro_1_2_race.results.create! place: 1, person: weaver

      results_file = ResultsFile.new(File.new(File.expand_path("../../fixtures/results/small_event.xls", __dir__)), event)
      results_file.import

      event = Event.find(event.id)

      assert_equal 5, event.races.size, "Races"
      assert event.races.all?(&:visible?), "Uploaded races should all be visible"
      ["Pro/1/2", "Category 3", "Category 4", "Category 5", "Women 1/2"].each do |cat_name|
        assert event.races.detect { |race| race.name == cat_name }, "Should have race #{cat_name}"
        assert_equal 1, event.races.count { |race| race.name == cat_name }, "Should only one of race #{cat_name}"
      end

      ["Pro/1/2", "Category 3", "Women 1/2"].each do |cat_name|
        assert_equal 3, event.races.detect { |race| race.name == cat_name }.results.count, "Race #{cat_name} results"
      end
    end

    test "stage race" do
      event = SingleDayEvent.create!
      results_file = ResultsFile.new(File.new(File.expand_path("../../fixtures/results/stage_race.xls", __dir__)), event)
      results_file.import

      assert_equal(1, event.races.size, "event races")
      actual_race = event.races.first
      assert_equal(80, actual_race.results.size, "Results")
      assert_equal(
        %w[place
           number
           first_name
           last_name
           team_name
           state
           time
           time_bonus_penalty
           time_total
           time_gap_to_leader],
        actual_race.result_columns,
        "Results"
      )

      index = 0
      result_index = 0
      result = actual_race.results[result_index]
      assert_equal("1", result.place, "place for race #{index} result #{result_index} #{result.first_name} #{result.last_name}")
      assert_equal("Roland", result.first_name, "first_name for race #{index} result #{result_index}")
      assert_equal("Green", result.last_name, "last_name for race #{index} result #{result_index}")
      assert_equal("Kona Mountain Bikes", result.team_name, "team name for race #{index} result #{result_index}")
      assert_equal("BC", result.state, "state for race #{index} result #{result_index}")
      assert_equal("03:32:04.00", result.time_s, "time_s for race #{index} result #{result_index}")
      assert_equal("", result.time_bonus_penalty_s, "time_bonus_penalty_s for race #{index} result #{result_index}")
      assert_equal("03:32:04.00", result.time_total_s, "time_total_s for race #{index} result #{result_index}")
      assert_equal("", result.time_gap_to_leader_s, "time_gap_to_leader_s for race #{index} result #{result_index}")

      result_index = 79
      result = actual_race.results[result_index]
      assert_equal("80", result.place, "place for race #{index} result #{result_index} #{result.first_name} #{result.last_name}")
      assert_equal("David", result.first_name, "first_name for race #{index} result #{result_index}")
      assert_equal("Robinson", result.last_name, "last_name for race #{index} result #{result_index}")
      assert_equal("TIAA-CREF Professional Cycling Team", result.team_name, "team name for race #{index} result #{result_index}")
      assert_equal("OR", result.state, "state for race #{index} result #{result_index}")
      assert_equal("", result.time_s, "time_s for race #{index} result #{result_index}")
      assert_equal("", result.time_bonus_penalty_s, "time_bonus_penalty_s for race #{index} result #{result_index}")
      assert_equal("", result.time_total_s, "time_total_s for race #{index} result #{result_index}")
      assert_equal("", result.time_gap_to_leader_s, "time_gap_to_leader_s for race #{index} result #{result_index}")

      result_index = 51
      result = actual_race.results[result_index]
      assert_equal("52", result.place, "place for race #{index} result #{result_index} #{result.first_name} #{result.last_name}")

      result_index = 68
      result = actual_race.results[result_index]
      assert_equal("Mikkel", result.first_name, "first_name for race #{index} result #{result_index}")
      assert_equal("Bossen", result.last_name, "last_name for race #{index} result #{result_index}")
      assert_equal("Team Oregon", result.team_name, "team name for race #{index} result #{result_index}")
      assert_equal("OR", result.state, "state for race #{index} result #{result_index}")
      assert_equal("03:52:09.00", result.time_s, "time_s for race #{index} result #{result_index}")

      result_index = 49
      result = actual_race.results[result_index]
      assert_equal("03:44:37.00", result.time_s, "time_s for race #{index} result #{result_index}")
      assert_equal("04:40.00", result.time_bonus_penalty_s, "time_bonus_penalty_s for race #{index} result #{result_index}")
      assert_equal("03:49:17.00", result.time_total_s, "time_total_s for race #{index} result #{result_index}")
      assert_equal("17:13.00", result.time_gap_to_leader_s, "time_gap_to_leader_s for race #{index} result #{result_index}")
    end

    # File causes error -- just import to recreate
    test "dh" do
      FactoryBot.create(:discipline, name: "Downhill")
      event = SingleDayEvent.create(discipline: "Downhill")
      results_file = ResultsFile.new(File.new(File.expand_path("../../fixtures/results/dh.xls", __dir__)), event)
      results_file.import
    end

    test "mtb" do
      FactoryBot.create(:mtb_discipline)
      pro_semi_pro_men = FactoryBot.create(:category, name: "Pro, Semi-Pro Men")
      pro_semi_pro_men.children.create(name: "Pro Men")
      pro_semi_pro_men.children.create(name: "Expert Men")
      pro_expert_women = FactoryBot.create(:category, name: "Pro, Expert Women")
      pro_expert_women.children.create(name: "Pro/Expert Women")

      event = SingleDayEvent.create!(discipline: "Mountain Bike")
      results_file = ResultsFile.new(File.new(File.expand_path("../../fixtures/results/mtb.xls", __dir__)), event)
      results_file.import
      assert_equal(6, event.races.reload.size, "Races after import")
    end

    test "custom columns" do
      FactoryBot.create(:discipline, name: "Downhill")
      event = SingleDayEvent.create(discipline: "Downhill")
      results_file = ResultsFile.new(File.new(File.expand_path("../../fixtures/results/custom_columns.xls", __dir__)), event)
      results_file.import
      assert_equal [:bogus_column_name], results_file.custom_columns.to_a, "ResultsFile Custom columns"
      assert_equal [:bogus_column_name], event.races.first.custom_columns, "Race custom_columns"
    end

    test "add custom columns to existing race" do
      FactoryBot.create(:discipline, name: "Downhill")
      event = SingleDayEvent.create(discipline: "Downhill")
      event.races.create!(category: Category.create!(name: "Pro/Elite Men"))
      results_file = ResultsFile.new(File.new(File.expand_path("../../fixtures/results/custom_columns.xls", __dir__)), event)
      results_file.import
      assert_equal [:bogus_column_name], results_file.custom_columns.to_a, "ResultsFile Custom columns"
      assert_equal [:bogus_column_name], event.races.first.custom_columns, "Race custom_columns"
    end

    test "non sequential results" do
      event = SingleDayEvent.create!
      results_file = ResultsFile.new(File.new(File.expand_path("../../fixtures/results/non_sequential_results.xls", __dir__)), event)
      results_file.import
      assert results_file.import_warnings.present?, "Should have import warnings for non-sequential results"

      results_file = ResultsFile.new(File.new(File.expand_path("../../fixtures/results/no_first_place_finisher.xls", __dir__)), event)
      results_file.import
      assert results_file.import_warnings.present?, "Should have import warnings for no first place finisher"
    end

    test "TTT results should not trigger non-sequential results warnings" do
      event = SingleDayEvent.create!
      results_file = ResultsFile.new(File.new(File.expand_path("../../fixtures/results/ttt.xls", __dir__)), event)
      results_file.import
      assert(
        results_file.import_warnings.empty?,
        "Should have no import warnings for TTT results, but have #{results_file.import_warnings.to_a.join(', ')}"
      )
    end

    test "times" do
      event = FactoryBot.create(:event)
      results_file = ResultsFile.new(File.new(File.expand_path("../../fixtures/results/times.xlsx", __dir__)), event)
      results_file.import
      results = event.races.first.results

      assert_equal(12.64, results[0].time, "row 0: 12.64")
      assert_equal(12.64, results[1].time, "row 1: 0:12.64")
      assert_equal(12.64, results[2].time, "row 2: 00:12.6")
      assert_equal(390, results[3].time, "row 3: 0:06:30")
      assert_equal(6236, results[4].time, "row 4: 1:43:56")
      assert_in_delta(3821, results[5].time, 0.00001, "row 5: 1:03:41")
      assert_in_delta(1641, results[6].time, 0.00001, "row 6: 0:27:21")
      assert_in_delta(6735, results[7].time, 0.00001, "row 7: 1:52:15")
      assert_equal 6735, results[8].time, "row 8: st"
      assert_in_delta(6735, results[9].time, 0.00001, "row 9: s.t.")
      assert_in_delta(7440, results[10].time, 0.00001, "row 10: 2:04")
      assert_in_delta(7440, results[11].time, 0.00001, "row 11: st")
      # Translated as hour:minutes, though minutes:seconds is the intention
      assert_in_delta(13_500.0, results[12].time, 0.00001, "row 12: 3:45")
      assert_in_delta(2252, results[13].time, 0.00001, "row 13: 0:37:32")
      assert_in_delta(172.28, results[14].time, 0.00001, "row 14: 2:52.28")
      # Translated as hour:minutes, though minutes:seconds is the intention
      assert_in_delta(13_920, results[15].time, 0.00001, "row 15: 3:52")
      assert_equal 0.161, results[16].time, "row 16: 0.161111111"
      assert_equal(2752.917, results[17].time, "row 17: 45:52.917")
      assert_equal(36_000, results[18].time, "row 18: 10:00:00")
      # Document edge case bug. Custom format causes fractional seconds to be dropped.
      assert_equal 1086, results[19].time, "row 19: 18:06.23 formatted as 18:06.2 in Excel"
    end

    test "#same_time?" do
      table = Tabular::Table.new([
                                   { place: "1", name: "Joanne Eastwood", time: "24:21" },
                                   { place: "2", name: "Nicole Pressprich", time: "" }
                                 ])

      assert ResultsFile.same_time?(table.rows.second)
    end

    test "#same_time? should consider place" do
      table = Tabular::Table.new([
                                   { place: "1", name: "Joanne Eastwood", time: "24:21" },
                                   { place: "DNS", name: "Nicole Pressprich", time: "DNS" }
                                 ])

      assert_not ResultsFile.same_time?(table.rows.second)
    end

    def expected_results(_event)
      expected_races = []

      race = Race.new(category: Category.new(name: "Category 3"))

      build_result(race, "1", "Greg", "Tyler", "Corben Huntair")
      build_result(race, "2", "Mark", "Price", "Corben Huntair")
      build_result(race, "3", "Chris", "Cook", "river City/Team Oregon")
      build_result(race, "4", "Noel", "Johnson")
      build_result(race, "5", "Kendal", "Kuhar", "Presto Velo/Bike & Hike")

      expected_races << race

      race = Race.new(category: Category.new(name: "Masters 35+"))

      build_result(race, "1", "David", "Zimbleman", "Excell Sports")
      build_result(race, "2", "Bruce", "Connelly", "Logie Velo")
      build_result(race, "3", "Mike", "Mauch", "Coben Huntair")

      expected_races << race

      race = Race.new(category: Category.new(name: "Pro/1/2"))

      build_result(race, "1", "Erik", "Tonkin", "Team S&M")
      build_result(race, "2", "Barry", "Wicks", "Kona")
      build_result(race, "3", "Billy", "Truelove", "EWEB Windpower")

      expected_races << race

      race = Race.new(category: Category.new(name: "Cat 4/5"))

      build_result(race, "1", "Hans", "Dyhrman")
      build_result(race, "2", "Shaun", "McLeod", "Half Fast Velo")
      build_result(race, "3", "Rob", "Dengel", "River City")

      expected_races << race

      race = Race.new(category: Category.new(name: "Women Category 1,2,3"))

      build_result(race, "1", "Kerry", "Rohan", "Compass Commercial")
      build_result(race, "2", "Suzanne", "King", "Compass Commercial")
      build_result(race, "3", "Colleen", "McClenahan", "Sorella Forte")

      expected_races << race

      race = Race.new(category: Category.new(name: "Women Category 4"))

      build_result(race, "1", "Martha", "Brown")
      build_result(race, "2", "Debbie", "Krichko")
      build_result(race, "3", "Joan", "Jasper", "Sorella Forte")

      expected_races << race

      expected_races
    end

    test "race notes" do
      event = SingleDayEvent.create!
      results_file = ResultsFile.new(File.new(File.expand_path("../../fixtures/results/tt.xlsx", __dir__)), event)
      results_file.import
      assert_equal("Field Size: 40 riders, 40 Laps, Sunny, cool, 40K", event.races.reload.first.notes, "Race notes")
    end

    test "race" do
      results_file = ResultsFile.new(nil, nil)
      table = Tabular::Table.new([
                                   { place: "1.0", name: "Merckx" },
                                   { place: "1.0", name: "Moser" },
                                   { place: "1.0", name: "De Vlaminck" },
                                   { place: "1.0", name: "De Wolfe" }
                                 ])

      table.rows.each do |row|
        assert_not results_file.race?(row), "Should not be a race: #{row}"
        assert results_file.result?(row), "Should be a result: #{row}"
      end
    end

    test "race for empty row" do
      results_file = ResultsFile.new(nil, nil)
      source = Tabular::Table.new
      row = Tabular::Row.new(source)
      assert_not results_file.race?(row)
    end

    def get_expected_races
      races = []

      race = Race.new(category: Category.new(name: "Senior Men Pro/1/2/3"))
      race.results << Result.new(place: "1", first_name: "Evan", last_name: "Elken", number: "154", license: "999999999", team_name: "Jittery Joe's", points: "23.0")
      if RacingAssociation.current.sanctioning_organizations.include?("USA Cycling")
        race.results << Result.new(place: "2", first_name: "Erik", last_name: "Tonkin", number: "102", license: "7123811", team_name: "Bike Gallery/Trek/VW", points: "19.0")
      else
        race.results << Result.new(place: "2", first_name: "Erik", last_name: "Torkin", number: "102", license: "7123811", team_name: "Bike Gallery/Trek/VW", points: "19.0")
      end
      race.results << Result.new(place: "3", first_name: "John", last_name: "Browning", number: "159", team_name: "Half Fast Velo", points: "12.0")
      race.results << Result.new(place: "4", first_name: "Doug", last_name: "Ollerenshaw", number: "132", team_name: "Health Net", points: "8.0")
      race.results << Result.new(place: "5", first_name: "Dean", last_name: "Tracy", number: "A76", team_name: "Team Rubicon", points: "7.0")
      race.results << Result.new(place: "6", first_name: "Kent", last_name: "Johnston", number: "195", team_name: "Fred Meyer/Lakeside", points: "6.0")
      race.results << Result.new(place: "7", first_name: "Nathan", last_name: "Dills", number: "J25", team_name: "Bike Gallery/TREK", points: "5.0")
      race.results << Result.new(place: "8", first_name: "David", last_name: "Oliphant", number: "112", team_name: "Team TAI", points: "4.0")
      race.results << Result.new(place: "9", first_name: "Richard", last_name: "Barrows", number: "568", team_name: "North River Racing", points: "3.0")
      race.results << Result.new(place: "10", first_name: "George", last_name: "Gardner", number: "385", team_name: nil, points: "2.0")
      race.results << Result.new(place: "11", first_name: "Kendall", last_name: "Kuhar", number: "152", team_name: "Bike N Hike/Giant", points: "1.0")
      race.results << Result.new(place: "12", first_name: "Ryan", last_name: "Weaver", number: "341", team_name: "Gentle Lovers")
      race.results << Result.new(place: "13", first_name: "Sal", last_name: "Collura", number: "A99", team_name: "Hutch's")
      race.results << Result.new(place: "14", number: "X52")
      race.results << Result.new(place: "15", first_name: "Miranda", last_name: "Duff", number: "201", team_name: "Team Rubicon")
      race.results << Result.new(place: "16", team_name: "Team Oregon")
      race.results << Result.new(place: "17", first_name: "Tom", last_name: "Simon", number: "C19", team_name: "North River Racing")
      race.results << Result.new(place: "18", first_name: "Stephen", last_name: "Hemminger", number: "559", team_name: "Team Oregon")
      race.results << Result.new(place: "19", first_name: "Al", last_name: "VanNoy", number: "186", team_name: "Fondriest-Mavic")
      race.results << Result.new(place: "20", first_name: "Eric", last_name: "Tsai", number: "A65", team_name: "Bike Gallery")
      race.results << Result.new(place: "21", first_name: "Jon", last_name: "Bridenbaugh", number: "X07", team_name: "Casa Bruno")
      race.results << Result.new(place: "22", number: "184")
      race.results << Result.new(place: "23", first_name: "Noreene", last_name: "Godfrey", number: "265", team_name: "Team Rubicon")
      race.results << Result.new(place: "24", first_name: "William", last_name: "Fasano", number: "H86", team_name: "Broadmark")
      race.results << Result.new(place: "25", first_name: "John", last_name: "Wiest", number: "313", team_name: "NoMad Sports Club")
      race.results << Result.new(place: "26", first_name: "Bret", last_name: "Berner", number: "X24")
      race.results << Result.new(place: "27", first_name: "Melissa", last_name: "Sanborn", number: "X51", team_name: "Subway")
      race.results << Result.new(place: "28", first_name: "Andrew", last_name: "Schlabach", number: "C96", team_name: "North River Racing")
      race.results << Result.new(place: "29", first_name: "Steven", last_name: "Mullen", number: "143", team_name: "NoMad Sports Club")
      race.results << Result.new(place: "30", first_name: "Jeff", last_name: "Thompson", number: "320", team_name: "North River Racing")
      race.results << Result.new(place: "31", first_name: "Shanan", last_name: "Whitlatch", number: "205", team_name: "Fred Meyer")
      race.results << Result.new(place: "32", first_name: "Mike", last_name: "Murray", number: "123", team_name: "Team Oregon")
      race.results << Result.new(place: "33", first_name: "Danny", last_name: "Knudsen", number: "305")
      race.results << Result.new(place: "34", first_name: "Mikkel", last_name: "Anderson", number: "C32", team_name: "NoMad Sports Club")
      race.results << Result.new(place: "35", first_name: "Brian", last_name: "Abers", number: "A44", team_name: "Team Rubicon")
      race.results << Result.new(place: "36", first_name: "Omer", last_name: "Kem", number: "J38", team_name: "Subway")
      race.results << Result.new(place: "37", first_name: "Joseph", last_name: "Cech", number: "X03")
      race.results << Result.new(place: "38", first_name: "Carl", last_name: "Anton", number: "399", team_name: "North River Racing")
      race.results << Result.new(place: "39", first_name: "Tim", last_name: "Coffey", number: "X04", team_name: "Gründelbrüisers")
      race.results << Result.new(place: "40", first_name: "Ryan", last_name: "Thomson", number: "557", team_name: "Gentle Lovers")
      race.results << Result.new(place: "41", first_name: "Carl", last_name: "Hoefer", number: "194", team_name: "Team Rubicon")
      race.results << Result.new(place: "42", first_name: "Jon", last_name: "Myers", number: "117", team_name: "Team S&M")
      race.results << Result.new(place: "", first_name: "Yann", last_name: "Blindert", number: "177", team_name: "Bike Gallery")
      race.results << Result.new(place: "DNF", first_name: "Jeff", last_name: "Mitchem", number: "151", team_name: "Casa Bruno")
      race.results << Result.new(place: "DNF", first_name: "Craig", last_name: "Broberg", number: "500", team_name: "FredMeyer Cycling Team")
      race.results << Result.new(place: "DNF", first_name: "Brad", last_name: "Ganz", number: "770")
      race.results << Result.new(place: "DNF", first_name: "Bryan", last_name: "Curry", number: "393", team_name: "Fred Meyer")
      race.results << Result.new(place: "DQ", first_name: "Chris", last_name: "Alling", number: "168", team_name: "Columbia River Velo")
      race.results << Result.new(place: "DNS", first_name: "Dickie", last_name: "Mallison", number: "140", team_name: "Guinness Cycling")
      races << race

      race = Race.new(category: Category.new(name: "Senior Men 3/4"))
      race.results << Result.new(place: "1", first_name: "Chuck", last_name: "Sowers", number: "404", team_name: "Huntair", points: "18.0")
      race.results << Result.new(place: "2", first_name: "Jason", last_name: "Pfeifer", number: "C02", team_name: "Bike n Hike/Giant/Presto Velo", points: "17.0")
      race.results << Result.new(place: "3", first_name: "Steven", last_name: "Beardsley", number: "478", team_name: "Team Oregon", points: "10.0")
      race.results << Result.new(place: "4", first_name: "Erik", last_name: "Voldengen", number: "554", team_name: "BBC/Bike N Hike", points: "10.0")
      race.results << Result.new(place: "5", first_name: "Heather", last_name: "VanValkenburg", number: "209", team_name: "Sorella Forte/TVG", points: "8.0")
      race.results << Result.new(place: "6", first_name: "Martin", last_name: "Baker", number: "N40", team_name: "Presto Velo", points: "8.0")
      race.results << Result.new(place: "7", first_name: "Chad", last_name: "Cherefko", number: "H59", team_name: "Presto Velo", points: "6.0")
      race.results << Result.new(place: "8", first_name: "Matt", last_name: "Brownfield", number: "729", team_name: "Team Oregon", points: "4.0")
      race.results << Result.new(place: "9", first_name: "Jason", last_name: "Kentner", number: "917", team_name: "BBC", points: "4.0")
      race.results << Result.new(place: "10", first_name: "Mike", last_name: "Alligood", number: "603", team_name: "Gateway/Speedzone", points: "2.0")
      race.results << Result.new(place: "11", first_name: "Richard", last_name: "Fattic", number: "429", points: "2.0")
      race.results << Result.new(place: "12", first_name: "Bryan", last_name: "Brock", number: "583", team_name: "Presto Velo")
      race.results << Result.new(place: "13", first_name: "David", last_name: "Pilz", number: "816", team_name: "The Bike Peddler")
      race.results << Result.new(place: "14", first_name: "Michael", last_name: "Resnick", number: "X26", team_name: "NoMad Sports Club")
      race.results << Result.new(place: "15", first_name: "Robert", last_name: "Chavier", number: "C13", team_name: "The Bike Peddler")
      race.results << Result.new(place: "16", first_name: "Jon", last_name: "Frommelt", number: "453")
      race.results << Result.new(place: "17", first_name: "Steven", last_name: "Lisac", number: "X50")
      race.results << Result.new(place: "18", first_name: "Josh", last_name: "Friberg", number: "452", team_name: "Bike & Hike")
      race.results << Result.new(place: "19", first_name: "Jess", last_name: "Graden", number: "27", team_name: "veloshop")
      race.results << Result.new(place: "20", first_name: "Jeff", last_name: "Tedder", number: "840", team_name: "Huntair")
      race.results << Result.new(place: "21", first_name: "David", last_name: "Strader", number: "773", team_name: "Team Oregon")
      race.results << Result.new(place: "22", first_name: "Jeff", last_name: "Stong", number: "803", team_name: "North River Racing")
      race.results << Result.new(place: "23", first_name: "Richard", last_name: "Lorenz", number: "K81", team_name: "EWEB Windpower")
      race.results << Result.new(place: "24", first_name: "Daniel", last_name: "Ashcom", number: "H64")
      race.results << Result.new(place: "25", first_name: "Tommy", last_name: "Tuite", number: "26", team_name: "veloshop")
      race.results << Result.new(place: "26", first_name: "Robert", last_name: "White", number: "853")
      race.results << Result.new(place: "27", first_name: "Doug", last_name: "Evans", number: "H33", team_name: "Bike&Hike")
      race.results << Result.new(place: "28", first_name: "Ian", last_name: "Megale", number: "C00", team_name: "Fred Meyer")
      race.results << Result.new(place: "29", first_name: "Jeff", last_name: "Vine", number: "874", team_name: "NoMad Sports Club")
      race.results << Result.new(place: "30", first_name: "Mary", last_name: "Ross", number: "279", team_name: "NoMad Sports Club")
      race.results << Result.new(place: "31", first_name: "Joseph", last_name: "Boquiren", number: "713", team_name: "Team Oregon")
      race.results << Result.new(place: "32", first_name: "Jerry", last_name: "Inscoe", number: "728", team_name: "Presto Velo")
      race.results << Result.new(place: "DNF", first_name: "Stephen", last_name: "Perkins", number: "N99")
      race.results << Result.new(place: "DNF", first_name: "Robert", last_name: "Nobles", number: "C98", team_name: "GS Camerati")
      # Expect AndersEn because cat 3/4 race is imported later with same OBRA number
      race.results << Result.new(place: "DNF", first_name: "Mikkel", last_name: "Andersen", number: "C32", team_name: "NoMad Sports Club")
      race.results << Result.new(place: "DNF", first_name: "R. Jim", last_name: "Moore", number: "C85")
      races << race

      race = Race.new(category: Category.new(name: "Senior Men 4/5"))
      race.results << Result.new(place: "1", first_name: "Richard", last_name: "Suditu", number: "909", team_name: "BBC", points: "16.0")
      race.results << Result.new(place: "2", first_name: "John", last_name: "Gleaves", number: "886", team_name: "BBC", points: "13.0")
      race.results << Result.new(place: "3", first_name: "Chrios", last_name: "Wood", number: "919", team_name: "Forza Jet Velo", points: "12.0")
      race.results << Result.new(place: "4", first_name: "Paul", last_name: "Kanz", number: "801", team_name: "Huntair", points: "9.0")
      race.results << Result.new(place: "5", first_name: "Greg", last_name: "Edwards", number: "K91", points: "8.0")
      race.results << Result.new(place: "6", first_name: "Gary", last_name: "Medley", number: "924", points: "6.0")
      race.results << Result.new(place: "7", first_name: "Larry", last_name: "Holzman", number: "K92", team_name: "North River Racing", points: "5.0")
      race.results << Result.new(place: "8", first_name: "Charissa", last_name: "Hallquist", number: "274", team_name: "BBC", points: "4.0")
      race.results << Result.new(place: "9", first_name: "Thomas", last_name: "Bradford", number: "700", team_name: "North River Racing", points: "3.0")
      race.results << Result.new(place: "10", first_name: "Ronald", last_name: "Kizzior", number: "H24", points: "2.0")
      race.results << Result.new(place: "11", first_name: "Don", last_name: "Vandervort", number: "C45", team_name: "Forza Jet Velo")
      race.results << Result.new(place: "12", first_name: "Eric", last_name: "Kimble", number: "X34")
      race.results << Result.new(place: "13", first_name: "Cameron", last_name: "Sparr", number: "768", team_name: "BBC")
      race.results << Result.new(place: "14", first_name: "Ian", last_name: "Hendry", number: "X36")
      race.results << Result.new(place: "15", first_name: "Joel", last_name: "Morrissette", number: "X90")
      race.results << Result.new(place: "16", first_name: "Eryn", last_name: "Barker", number: "X33")
      race.results << Result.new(place: "17", first_name: "Risha", last_name: "Kelley", number: "X14", team_name: "n/a")
      race.results << Result.new(place: "18", first_name: "Jim", last_name: "Hinkley", number: "698")
      race.results << Result.new(place: "19", first_name: "Fiona", last_name: "Graham", number: "215", team_name: "BBC")
      race.results << Result.new(place: "DNF", first_name: "Kallen", last_name: "Dewey", number: "X53", team_name: "BBC")
      race.results << Result.new(place: "DNF", first_name: "Eric", last_name: "Aleskus", number: "636")
      races << race

      races
    end

    def build_result(race, place, first_name = nil, last_name = nil, team_name = nil)
      person = nil
      if !first_name.nil? && !last_name.nil?
        person = Person.new
        person.first_name = first_name
        person.last_name = last_name
      end
      team = nil
      unless teamName.nil?
        team = Team.new
        team.name = team_name
      end
      result = race.results.build(place: place)
      result.person = person
      result.team = team
      race.results << result
    end

    def assert_import(event)
      assert_not_nil(event)
      assert_equal("Camas Road Race", event.name, "name")
      assert_equal("Camas", event.city, "city")
      assert_equal("Washington", event.state, "state")
      assert_equal_dates("2003-08-03", event.date, "start_date")
      assert_equal(6, event.races.size, "children size")
      expected_races = expected_races(event)
      expected_races.each do |expected_race|
        actual_race = event.races[expected_races.index(expected_race)]
        assert_equal(expected_race.name, actual_race.name, "name")
        assert_equal(expected_race.city, actual_race.city, "city")
        assert_equal(expected_race.state, actual_race.state, "state")
        assert_equal(actual_race.results.size, actual_race.results.size, "results size for #{expected_race.name}")
        expected_race.results.each do |expected_result|
          result = actual_race.results[expected_race.results.index(expected_result)]
          assert_equal(expected_result.place, result.place, "Place")
          assert_equal(expected_result.first_name, result.first_name, "Person first name")
          assert_equal(expected_result.last_name, result.last_name, "Person last name")
          assert_equal(expected_result.team_name, result.team_name, "Team name")
        end
      end
    end

    def assert_columns(expected_fields, actual_columns)
      expected_fields.each_with_index do |field, index|
        assert_equal(field, actual_columns[index].field, "Result column #{index} field") if actual_columns[index].field
      end
    end
  end
end
