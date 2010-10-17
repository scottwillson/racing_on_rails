# coding: utf-8

require File.expand_path("../../../test_helper", __FILE__)
require "tempfile"
require "spreadsheet"

# :stopdoc:
module Results
  # FIXME DNF's not handled correctly.

  # Most Test fixtures are in OBRA (not USAC) format. Force USAC format in ResultsFile to test logic shared by both formats.
  class ResultsFileTest < ActiveSupport::TestCase
    def test_race?
      results_file = ResultsFile.new(File.new("#{File.dirname(__FILE__)}/../../fixtures/results/tt.xls"), SingleDayEvent.new)
      book = Spreadsheet.open("#{File.dirname(__FILE__)}/../../fixtures/results/tt.xls")
      results_file.create_rows(book.worksheet(0))

      assert(results_file.race?(results_file.rows[0]), 'New race')
      assert(!results_file.race?(results_file.rows[1]), 'New race')
      assert(!results_file.race?(results_file.rows[2]), 'New race')
      assert(!results_file.race?(results_file.rows[3]), 'New race')
      assert(results_file.race?(results_file.rows[8]), "New race: #{results_file.rows[8]}")
      assert(!results_file.race?(results_file.rows[9]), "New race: #{results_file.rows[9]}")
      assert(!results_file.race?(results_file.rows[10]), 'New race')
      assert(!results_file.race?(results_file.rows[11]), 'New race')
      assert(!results_file.race?(results_file.rows[12]), 'New race')
      assert(!results_file.race?(results_file.rows[13]), 'New race')
    end
    
    def test_race_usac
      RacingAssociation.current.usac_results_format = true
      results_file = ResultsFile.new(File.new("#{File.dirname(__FILE__)}/../../fixtures/results/tt_usac.xls"), SingleDayEvent.new)
      book = Spreadsheet.open("#{File.dirname(__FILE__)}/../../fixtures/results/tt_usac.xls")
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

    def test_new
      file = Tempfile.new("test_results.txt")
      ResultsFile.new(file, SingleDayEvent.new)

      ResultsFile.new("text \t results", SingleDayEvent.new)
    end
    
    def test_create_columns
      book = Spreadsheet.open("#{File.dirname(__FILE__)}/../../fixtures/results/pir_2006_format.xls")
      spreadsheet_row = book.worksheet(0).row(0)
      results_file = ResultsFile.new(File.new("#{File.dirname(__FILE__)}/../../fixtures/results/pir_2006_format.xls"), SingleDayEvent.new)
      column_indexes = results_file.create_columns(spreadsheet_row)
      assert_equal({ :place => 0, :number => 1, :license => 2, :last_name => 3, :first_name => 4, :team_name => 5, :points => 6  }, column_indexes, "column_indexes")
    end
    
    def test_create_columns_usac
      RacingAssociation.current.usac_results_format = true
      book = Spreadsheet.open("#{File.dirname(__FILE__)}/../../fixtures/results/tt_usac.xls")
      spreadsheet_row = book.worksheet(0).row(0)
      results_file = ResultsFile.new(File.new("#{File.dirname(__FILE__)}/../../fixtures/results/tt_usac.xls"), SingleDayEvent.new)
      column_indexes = results_file.create_columns(spreadsheet_row)
      assert_equal({
        :time           => 14,
        :last_name      => 10,
        :first_name     => 11,
        :category_class => 7,
        :team_name      => 13,
        :category_name  => 5,
        :place          => 15,
        :number         => 12,
        :gender         => 6,
        :license        => 9,
        :age            => 8
      }, column_indexes, "column_indexes")
    end
  
    def test_import_excel
      current_members = Person.find(:all, :conditions => ["member_to >= ?", RacingAssociation.current.now])
      event = SingleDayEvent.create!(:discipline => 'Road', :date => Date.new(2006, 1, 16))
      source_path = "#{File.dirname(__FILE__)}/../../fixtures/results/pir_2006_format.xls"
      results_file = ResultsFile.new(File.new(source_path), event)
      assert_equal(source_path, results_file.source.path, "file path")
      results_file.import
 
      expected_races = get_expected_races
      assert_equal(expected_races.size, event.races.size, "Expected #{expected_races.size.to_s} event races but was #{event.races.size.to_s}")
      expected_races.each_with_index do |expected_race, index|
        actual_race = event.races[index]
        assert_not_nil(actual_race, "race #{index}")
        assert_not_nil(actual_race.results, "results for category #{expected_race.category}")
        assert_equal(expected_race.results.size, actual_race.results.size, "Results")
        race_date = actual_race.date
        actual_race.results.sort.each_with_index do |result, result_index|
          expected_result = expected_race.results[result_index]
          assert_equal(expected_result.place, result.place, "place for race #{index} result #{result_index} #{expected_result.first_name} #{expected_result.last_name}")
          if result.license && result.license.empty? #may have found person by license
            assert_equal(expected_result.first_name, result.first_name, "first_name for race #{index} result #{result_index}")
            assert_equal(expected_result.last_name, result.last_name, "last_name for race #{index} result #{result_index}")
          end
          assert_equal(expected_result.team_name, result.team_name, "team name for race #{index} result #{result_index}")
          assert_equal(expected_result.points, result.points, "points for race #{index} result #{result_index}")
          if result.person(true)
            if RaceNumber.rental?(result.number, Discipline[event.discipline])
              assert(!result.person.member?(race_date), "Person should not be a member because he has a rental number")
            else
              if RacingAssociation.current.add_members_from_results? || current_members.include?(result.person)
                assert(result.person.member?(race_date), "member? for race #{index} result #{result_index} #{result.name} #{result.person.member_from} #{result.person.member_to}")
                assert_not_equal(
                  Date.today, 
                  result.person.member_from, 
                  "#{result.name} membership date should existing date or race date, but never today (#{result.person.member_from})")
              else
                assert(!result.person.member?(race_date), "member? for race #{index} result #{result_index} #{result.name} #{result.person.member_from} #{result.person.member_to}")
              end
            end
            # test result by license (some with name misspelled)
            if result.license && RacingAssociation.current.eager_match_on_license?
              person_by_lic = Person.find_by_license(result.license)
              assert_equal(result.person, person_by_lic, "Result should be assigned to #{person_by_lic.name} by license but was given to #{result.person.name}") if person_by_lic
            end
          end
        end
      end
    end

    def test_import_time_trial_people_with_same_name
      bruce_109 = Person.create!(:first_name => 'Bruce', :last_name => 'Carter')
      association = number_issuers(:association)
      bruce_109.race_numbers.create(:number_issuer => association, :discipline => Discipline[:road], :year => Date.today.year, :value => '109')
    
      bruce_1300 = Person.create!(:first_name => 'Bruce', :last_name => 'Carter')
      bruce_1300.race_numbers.create!(:number_issuer => association, :discipline => Discipline[:road], :year => Date.today.year, :value => '1300')
    
      event = SingleDayEvent.create!(:discipline => 'Time Trial')

      results_file = ResultsFile.new(File.new("#{File.dirname(__FILE__)}/../../fixtures/results/tt.xls"), event)
      results_file.import
    
      assert_equal(2, event.races(true).size, "event races")
      assert_equal(7, event.races[0].results.size, "Results")
      sorted_results = event.races[0].results.sort
      assert_equal("1", sorted_results.first.place, "First result place")
      assert_in_delta(2252.0, sorted_results.first.time, 0.0001, "First result time")
      assert_equal("7", sorted_results.last.place, "Last result place")
      assert_in_delta(2762.0, sorted_results.last.time, 0.0001, "Last result time")

      race = event.races.first
      assert_equal(10, race.result_columns.size, 'Columns size')
      assert_equal('place', race.result_columns[0], 'Column 0 name')
      assert_equal('category_name', race.result_columns[2], 'Column 2 name')
    
      assert_equal(2, Person.find_all_by_first_name_and_last_name('bruce', 'carter').size, 'Bruce Carters after import')

      assert(!event.races.empty?, 'event.races should not be empty')
      for race in event.races
        assert_kind_of(Race, race, 'race')
        assert_kind_of(Category, race.category, 'race.category')
        for result in race.results.sort
          assert_kind_of(Result, result, 'result')
          assert_kind_of(Person, result.person, 'result.person') unless result.person.nil?
          assert_kind_of(Team, result.team, 'result.team') unless result.team.nil?
          assert_kind_of(Category, result.category, 'result.category') unless result.category.nil?
          result.place
          result.person
          result.team
          result.first_name
        end
      end
    
      # Existing people, same name, different numbers
      bruce_1300 = event.races.first.results[6].person
      bruce_109 = event.races.last.results[2].person
      assert_not_nil(bruce_1300, 'bruce_1300')
      assert_not_nil(bruce_109, 'bruce_109')
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
      existing_weaver = people(:weaver)
      new_weaver = event.races.last.results.first.person
      assert_equal(existing_weaver.name, new_weaver.name, "Weavers with different numbers should have same name")
      assert_equal(existing_weaver, new_weaver, "Weavers with different numbers should be same people")
      assert_equal(existing_weaver.id, new_weaver.id, "Weavers with different numbers should have same IDs")

      # New person, different name, same number
      kurt = event.races.first.results[2].person
      alan = event.races.first.results[3].person
      assert_not_equal(kurt, alan, "Person with different names, same numbers should be different people")

      # Existing person, different name, same number
      existing_matson = people(:matson)
      new_matson = event.races.first.results.first.person
      assert_not_equal(existing_matson, new_matson, "Person with different numbers should be different people")
    end
  
    # Expose bad regex defect
    def test_import_time_trial_with_hundreds
      event = SingleDayEvent.create!(:discipline => "Time Trial")
      results_file = ResultsFile.new(File.new("#{File.dirname(__FILE__)}/../../fixtures/results/tt_hundreds.xls"), event)
      results_file.import
      result = event.races.first.results.first
      assert_equal 1086.23, result.time, "First result time of 18:06.23 formatted as 18:06.2 in Excel"
    end
  
    def test_import_2006_v2
      expected_races = []
    
      paul_bourcier = Person.create!(:first_name => "Paul", :last_name => "Bourcier", :member => true)
      eweb = Team.create!(:name => 'EWEB Windpower')
      paul_bourcier.team = eweb
      paul_bourcier.save!
      assert(paul_bourcier.errors.empty?)
      assert(eweb.errors.empty?)
      assert_equal(eweb, paul_bourcier.team(true), 'Paul Bourcier team')
    
      chris_myers = Person.create!(:first_name => "Chris", :last_name => "Myers", :member => true)
      assert_nil(chris_myers.team(true), 'Chris Myers team')
    
      race = Race.new(:category => Category.new(:name => "Pro/1/2"))
      race.results << Result.new(:place => "1", :first_name => "Paul", :last_name => "Bourcier", :number =>"146", :team_name =>"Hutch's Eugene", :points => "10.0")
      race.results << Result.new(:place => "2", :first_name => "John", :last_name => "Browning", :number =>"197", :team_name =>"Half Fast Velo", :points => "3.0")
      race.results << Result.new(:place => "3", :first_name => "Seth", :last_name => "Hosmer", :number =>"158", :team_name =>"CMG Racing", :points => "")
      race.results << Result.new(:place => "4", :first_name => "Sam", :last_name => "Johnson", :number =>"836", :team_name =>"Broadmark Berman/Hagens LLC", :points => "")
      race.results << Result.new(:place => "5", :first_name => "Mark", :last_name => "Steger", :number =>"173", :team_name =>"CMG Racing", :points => "3.0")
      race.results << Result.new(:place => "6", :first_name => "Nick", :last_name => "Skenzick", :number =>"114", :team_name =>"Hutch's Eugene", :points => "")
      race.results << Result.new(:place => "7", :first_name => "Chris", :last_name => "Myers", :number =>"812", :team_name =>"Camerati", :points => "")
      race.results << Result.new(:place => "8", :number => "Logie", :points => "")
      race.results << Result.new(:place => "9", :first_name => "Dan", :last_name => "Quirk", :number =>"117", :team_name =>"Veloce/Felt", :points => "1.0")
      race.results << Result.new(:place => "DNF", :first_name => "Jason", :last_name => "Chapman", :number => "185", :points => "")
      race.results << Result.new(:place => "DNF", :first_name => "Jay", :last_name => "Freyensee", :number =>"826", :team_name =>"Easton", :points => "")
      expected_races << race

      race = Race.new(:category => Category.new(:name => "Cat 3"))
      race.results << Result.new(:place => "1", :first_name => "Aaron", :last_name => "Coker", :number =>"519", :team_name =>"CMG Racing", :points => "5.0")
      race.results << Result.new(:place => "2", :first_name => "David", :last_name => "Roth", :number =>"593", :team_name =>"Team Green Eugene", :points => "")
      race.results << Result.new(:place => "3", :first_name => "Bradley", :last_name => "Ritter", :number =>"571", :team_name =>"Garage", :points => "")
      expected_races << race

      # TODO Import starters/field size
      race = Race.new(:category => Category.new(:name => "Cat 4/5"))
      race.results << Result.new(:place => "1", :first_name => "John", :last_name => "Wilson", :number =>"1107", :team_name =>"EWEB Windpower", :points => "")
      race.results << Result.new(:place => "2", :first_name => "Jonathan", :last_name => "Long", :number =>"412", :team_name =>"Bicycling Hub", :points => "")
      race.results << Result.new(:place => "3", :first_name => "Kenneth", :last_name => "Peterson", :number =>"2216", :team_name =>"UofO", :points => "")
      race.results << Result.new(:place => "4", :first_name => "Brady", :last_name => "Brady", :number =>"415", :team_name =>"Team Oregon/River City Bicycles", :points => "")
      expected_races << race

      event = SingleDayEvent.create!(:discipline => 'Circuit')
      results_file = ResultsFile.new(File.new("#{File.dirname(__FILE__)}/../../fixtures/results/2006_v2.xls"), event)
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
          assert_equal(expected_result.first_name, result.first_name, "first_name for race #{index} result #{result_index}")
          assert_equal(expected_result.last_name, result.last_name, "last_name for race #{index} result #{result_index}")
          assert_equal(expected_result.team_name, result.team_name, "team name for race #{index} result #{result_index}")
          assert_equal(expected_result.points, result.points, "points for race #{index} result #{result_index}")
          assert_equal(expected_result.number, result.number, "Result number for race #{index} result #{result_index}")
          if result.person and RaceNumber.rental?(result.number, Discipline[event.discipline])
            assert_equal(nil, result.person.road_number, "Road number")
          end
        end
      end
    
      paul_bourcier.reload
      assert_equal(eweb, paul_bourcier.team(true), 'Paul Bourcier team should not be overwritten by results')
      chris_myers.reload
      assert_nil(chris_myers.team(true), 'Chris Myers team should not be updated by results')
    
      browning = Person.find_by_name("John Browning")
      assert_equal(event, browning.created_by, "created_by")
      assert_equal(event, browning.team.created_by, "team created_by")
      assert_equal(event.name, browning.created_by.name, "created_by name")
    end
  
    def test_import_and_reuse_races
      # race       exists?   in_results_file   order?   after_import
      # pro_1_2    Y          Y                 Y         Y + results
      # cat_3      Y          Y                           Y + results
      # cat_4      Y                            Y         Y
      # cat_5      Y                                      Y
      # w_1_2                 Y                           Y + results
      # Other combinations are invalid

      event = SingleDayEvent.create!(:date => Date.today + 3)
      pro_1_2_race = event.races.create! :category => Category.find_or_create_by_name("Pro 1/2")
      event.races.create! :category => Category.find_or_create_by_name("Cat 3")
      cat_4_race = event.races.create! :category => Category.find_or_create_by_name("Cat 4")
      event.races.create! :category => Category.find_or_create_by_name("Cat 5")
    
      pro_1_2_race.results.create! :place => 1, :person => people(:weaver)
    
      results_file = ResultsFile.new(File.new("#{File.dirname(__FILE__)}/../../fixtures/results/small_event.xls"), event)
      results_file.import
    
      event.reload
    
      assert_equal 5, event.races.count, "Races"
      [ "Pro 1/2", "Cat 3", "Cat 4", "Cat 5", "Women 1/2" ].each do |cat_name|
        assert event.races.detect { |race| race.name == cat_name }, "Should have race #{cat_name}"
        assert_equal 1, event.races.select { |race| race.name == cat_name }.size, "Should only one of race #{cat_name}"
      end
    
      [ "Pro 1/2", "Cat 3", "Women 1/2" ].each do |cat_name|
        assert_equal 3, event.races.detect { |race| race.name == cat_name }.results.count, "Race #{cat_name} results"
      end
    end
  
    def test_stage_race
      event = SingleDayEvent.create!
      results_file = ResultsFile.new(File.new("#{File.dirname(__FILE__)}/../../fixtures/results/stage_race.xls"), event)
      results_file.import

      assert_equal(2, event.races.size, "event races")
      actual_race = event.races.first
      assert_equal(80, actual_race.results.size, "Results")
      assert_equal(
        ["place",
         "number",
         "first_name",
         "last_name",
         "team_name",
         "state",
         "time",
         "time_bonus_penalty",
         "time_total",
         "time_gap_to_leader"], 
        actual_race.result_columns, 
        "Results"
      )
    
      index = 0
      result_index = 0
      result = actual_race.results[result_index]
      assert_equal('1', result.place, "place for race #{index} result #{result_index} #{result.first_name} #{result.last_name}")
      assert_equal('Roland', result.first_name, "first_name for race #{index} result #{result_index}")
      assert_equal('Green', result.last_name, "last_name for race #{index} result #{result_index}")
      assert_equal('Kona Mountain Bikes', result.team_name, "team name for race #{index} result #{result_index}")
      assert_equal('BC', result.state, "state for race #{index} result #{result_index}")
      assert_equal('03:32:04.00', result.time_s, "time_s for race #{index} result #{result_index}")
      assert_equal('', result.time_bonus_penalty_s, "time_bonus_penalty_s for race #{index} result #{result_index}")
      assert_equal('03:32:04.00', result.time_total_s, "time_total_s for race #{index} result #{result_index}")
      assert_equal('', result.time_gap_to_leader_s, "time_gap_to_leader_s for race #{index} result #{result_index}")

      result_index = 79
      result = actual_race.results[result_index]
      assert_equal('80', result.place, "place for race #{index} result #{result_index} #{result.first_name} #{result.last_name}")
      assert_equal('David', result.first_name, "first_name for race #{index} result #{result_index}")
      assert_equal('Robinson', result.last_name, "last_name for race #{index} result #{result_index}")
      assert_equal('TIAA-CREF Professional Cycling Team', result.team_name, "team name for race #{index} result #{result_index}")
      assert_equal('OR', result.state, "state for race #{index} result #{result_index}")
      assert_equal('', result.time_s, "time_s for race #{index} result #{result_index}")
      assert_equal('', result.time_bonus_penalty_s, "time_bonus_penalty_s for race #{index} result #{result_index}")
      assert_equal('', result.time_total_s, "time_total_s for race #{index} result #{result_index}")
      assert_equal('', result.time_gap_to_leader_s, "time_gap_to_leader_s for race #{index} result #{result_index}")

      result_index = 51
      result = actual_race.results[result_index]
      assert_equal('52', result.place, "place for race #{index} result #{result_index} #{result.first_name} #{result.last_name}")

      result_index = 68
      result = actual_race.results[result_index]
      assert_equal('Mikkel', result.first_name, "first_name for race #{index} result #{result_index}")
      assert_equal('Bossen', result.last_name, "last_name for race #{index} result #{result_index}")
      assert_equal('Team Oregon', result.team_name, "team name for race #{index} result #{result_index}")
      assert_equal('OR', result.state, "state for race #{index} result #{result_index}")
      assert_equal('03:52:09.00', result.time_s, "time_s for race #{index} result #{result_index}")

      result_index = 49
      result = actual_race.results[result_index]
      assert_equal('03:44:37.00', result.time_s, "time_s for race #{index} result #{result_index}")
      assert_equal('04:40.00', result.time_bonus_penalty_s, "time_bonus_penalty_s for race #{index} result #{result_index}")
      assert_equal('03:49:17.00', result.time_total_s, "time_total_s for race #{index} result #{result_index}")
      assert_equal('17:13.00', result.time_gap_to_leader_s, "time_gap_to_leader_s for race #{index} result #{result_index}")
    end
  
    # File causes error -- just import to recreate
    def test_dh
      event = SingleDayEvent.create(:discipline => 'Downhill')
      results_file = ResultsFile.new(File.new("#{File.dirname(__FILE__)}/../../fixtures/results/dh.xls"), event)
      results_file.import
    end
  
    def test_mtb
      pro_semi_pro_men = categories(:pro_semi_pro_men)
      pro_semi_pro_men.children.create(:name => 'Pro Men')
      pro_semi_pro_men.children.create(:name => 'Expert Men')
      pro_expert_women = categories(:pro_expert_women)
      pro_expert_women.children.create(:name => 'Pro/Expert Women')
    
      event = SingleDayEvent.create!(:discipline => 'Mountain Bike')
      results_file = ResultsFile.new(File.new("#{File.dirname(__FILE__)}/../../fixtures/results/mtb.xls"), event)
      results_file.import
      assert_nil(event.combined_results, 'Should not have combined results')
      assert_equal(6, event.races(true).size, "Races after import")
    end
  
    def test_custom_columns
      event = SingleDayEvent.create(:discipline => 'Downhill')
      results_file = ResultsFile.new(File.new("#{File.dirname(__FILE__)}/../../fixtures/results/custom_columns.xls"), event)
      results_file.import
      assert_equal ["bogus_column_name"], results_file.custom_columns.to_a, "Custom columns"
    end

    def test_times
      event = SingleDayEvent.create(:discipline => 'Track')
      results_file = ResultsFile.new(File.new("#{File.dirname(__FILE__)}/../../fixtures/results/times.xls"), event)
      results_file.import
      assert_equal(1, event.races.size, 'Races')
      results = event.races.first.results
    
      assert_equal(12.64, results[0].time, 'row 0: 12.64')
      assert_equal(12.64, results[1].time, 'row 1: 0:12.64')
      assert_equal(12.64, results[2].time, 'row 2: 00:12.6')
      assert_equal(390, results[3].time, 'row 3: 0:06:30')
      assert_equal(6236, results[4].time, 'row 4: 1:43:56')
      assert_in_delta(3821, results[5].time, 0.00001, 'row 5: 1:03:41')
      assert_in_delta(1641, results[6].time, 0.00001, 'row 6: 0:27:21')
      assert_in_delta(6735, results[7].time, 0.00001, 'row 7: 1:52:15')
      assert_in_delta(6735, results[8].time, 0.00001, 'row 8: st')
      assert_in_delta(6735, results[9].time, 0.00001, 'row 9: s.t.')
      assert_in_delta(7440, results[10].time, 0.00001, 'row 10: 2:04')
      assert_in_delta(7440, results[11].time, 0.00001, 'row 11: st')
      # Translated as hour:minutes, though minutes:seconds is the intention
      assert_in_delta(13500.0, results[12].time, 0.00001, 'row 12: 3:45')
      assert_in_delta(2252, results[13].time, 0.00001, 'row 13: 0:37:32')
      assert_in_delta(172.28, results[14].time, 0.00001, 'row 14: 2:52.28')
      # Translated as hour:minutes, though minutes:seconds is the intention
      assert_in_delta(13920, results[15].time, 0.00001, 'row 15: 3:52')
      assert_in_delta(0.161111111, results[16].time, 0.00001, 'row 16: 0.161111111')
      assert_equal(2752.92, results[17].time, 'row 17: 45:52.917')
      assert_equal(36000, results[18].time, 'row 18: 10:00:00')
    end
  
    def expected_results(event)
      expected_races = []
    
      race = Race.new(:category => Category.new(:name => "Category 3"))

      build_result(race, "1", "Greg", "Tyler", "Corben Huntair")
      build_result(race, "2", "Mark", "Price", "Corben Huntair")
      build_result(race, "3", "Chris", "Cook", "river City/Team Oregon")
      build_result(race, "4", "Noel", "Johnson")
      build_result(race, "5", "Kendal", "Kuhar", "Presto Velo/Bike & Hike")
    
      expected_races << race
    
      race = Race.new(:category => Category.new(:name => "Masters 35+"))

      build_result(race, "1", "David", "Zimbleman", "Excell Sports")
      build_result(race, "2", "Bruce", "Connelly", "Logie Velo")
      build_result(race, "3", "Mike", "Mauch", "Coben Huntair")
    
      expected_races << race
    
      race = Race.new(:category => Category.new(:name => "Pro 1/2"))

      build_result(race, "1", "Erik", "Tonkin", "Team S&M")
      build_result(race, "2", "Barry", "Wicks", "Kona")
      build_result(race, "3", "Billy", "Truelove", "EWEB Windpower")
    
      expected_races << race
    
      race = Race.new(:category => Category.new(:name => "Cat 4/5"))

      build_result(race, "1", "Hans", "Dyhrman")
      build_result(race, "2", "Shaun", "McLeod", "Half Fast Velo")
      build_result(race, "3", "Rob", "Dengel", "River City")
    
      expected_races << race
    
      race = Race.new(:category => Category.new(:name => "Women Category 1,2,3"))

      build_result(race, "1", "Kerry", "Rohan", "Compass Commercial")
      build_result(race, "2", "Suzanne", "King", "Compass Commercial")
      build_result(race, "3", "Colleen", "McClenahan", "Sorella Forte")
    
      expected_races << race
    
      race = Race.new(:category => Category.new(:name => "Women Category 4"))

      build_result(race, "1", "Martha", "Brown")
      build_result(race, "2", "Debbie", "Krichko")
      build_result(race, "3", "Joan", "Jasper", "Sorella Forte")
    
      expected_races << race
    
      return expected_races
    end
  
    def get_expected_races
      races = []
    
      race = Race.new(:category => Category.new(:name => "Senior Men Pro 1/2/3"))
      race.results << Result.new(:place => "1", :first_name => "Evan", :last_name => "Elken", :number =>"154", :license =>"999999999", :team_name =>"Jittery Joe's", :points => "23.0")
      if RacingAssociation.current.sanctioning_organizations.include?("USA Cycling")
        race.results << Result.new(:place => "2", :first_name => "Erik", :last_name => "Tonkin", :number =>"102", :license =>"7123811", :team_name =>"Bike Gallery/Trek/VW", :points => "19.0")
      else
        race.results << Result.new(:place => "2", :first_name => "Erik", :last_name => "Torkin", :number =>"102", :license =>"7123811", :team_name =>"Bike Gallery/Trek/VW", :points => "19.0")
      end
      race.results << Result.new(:place => "3", :first_name => "John", :last_name => "Browning", :number =>"159", :team_name =>"Half Fast Velo", :points => "12.0")
      race.results << Result.new(:place => "4", :first_name => "Doug", :last_name => "Ollerenshaw", :number =>"132", :team_name =>"Health Net", :points => "8.0")
      race.results << Result.new(:place => "5", :first_name => "Dean", :last_name => "Tracy", :number =>"A76", :team_name =>"Team Rubicon", :points => "7.0")
      race.results << Result.new(:place => "6", :first_name => "Kent", :last_name => "Johnston", :number =>"195", :team_name =>"Fred Meyer/Lakeside", :points => "6.0")
      race.results << Result.new(:place => "7", :first_name => "Nathan", :last_name => "Dills", :number =>"J25", :team_name =>"Bike Gallery/TREK", :points => "5.0")
      race.results << Result.new(:place => "8", :first_name => "David", :last_name => "Oliphant", :number =>"112", :team_name =>"Team TAI", :points => "4.0")
      race.results << Result.new(:place => "9", :first_name => "Richard", :last_name => "Barrows", :number =>"568", :team_name =>"North River Racing", :points => "3.0")
      race.results << Result.new(:place => "10", :first_name => "George", :last_name => "Gardner", :number =>"385", :team_name => nil, :points => "2.0")
      race.results << Result.new(:place => "11", :first_name => "Kendall", :last_name => "Kuhar", :number =>"152", :team_name =>"Bike N Hike/Giant", :points => "1.0")
      race.results << Result.new(:place => "12", :first_name => "Ryan", :last_name => "Weaver", :number =>"341", :team_name =>"Gentle Lovers")
      race.results << Result.new(:place => "13", :first_name => "Sal", :last_name => "Collura", :number =>"A99", :team_name =>"Hutch's")
      race.results << Result.new(:place => "14", :number => "X52")
      race.results << Result.new(:place => "15", :first_name => "Miranda", :last_name => "Duff", :number =>"201", :team_name =>"Team Rubicon")
      race.results << Result.new(:place => "16", :team_name => "Team Oregon")
      race.results << Result.new(:place => "17", :first_name => "Tom", :last_name => "Simon", :number =>"C19", :team_name =>"North River Racing")
      race.results << Result.new(:place => "18", :first_name => "Stephen", :last_name => "Hemminger", :number =>"559", :team_name =>"Team Oregon")
      race.results << Result.new(:place => "19", :first_name => "Al", :last_name => "VanNoy", :number =>"186", :team_name =>"Fondriest-Mavic")
      race.results << Result.new(:place => "20", :first_name => "Eric", :last_name => "Tsai", :number =>"A65", :team_name =>"Bike Gallery")
      race.results << Result.new(:place => "21", :first_name => "Jon", :last_name => "Bridenbaugh", :number =>"X07", :team_name =>"Casa Bruno")
      race.results << Result.new(:place => "22", :number => "184")
      race.results << Result.new(:place => "23", :first_name => "Noreene", :last_name => "Godfrey", :number =>"265", :team_name =>"Team Rubicon")
      race.results << Result.new(:place => "24", :first_name => "William", :last_name => "Fasano", :number =>"H86", :team_name =>"Broadmark")
      race.results << Result.new(:place => "25", :first_name => "John", :last_name => "Wiest", :number =>"313", :team_name =>"NoMad Sports Club")
      race.results << Result.new(:place => "26", :first_name => "Bret", :last_name => "Berner", :number =>"X24")
      race.results << Result.new(:place => "27", :first_name => "Melissa", :last_name => "Sanborn", :number =>"X51", :team_name =>"Subway")
      race.results << Result.new(:place => "28", :first_name => "Andrew", :last_name => "Schlabach", :number =>"C96", :team_name =>"North River Racing")
      race.results << Result.new(:place => "29", :first_name => "Steven", :last_name => "Mullen", :number =>"143", :team_name =>"NoMad Sports Club")
      race.results << Result.new(:place => "30", :first_name => "Jeff", :last_name => "Thompson", :number =>"320", :team_name =>"North River Racing")
      race.results << Result.new(:place => "31", :first_name => "Shanan", :last_name => "Whitlatch", :number =>"205", :team_name =>"Fred Meyer")
      race.results << Result.new(:place => "32", :first_name => "Mike", :last_name => "Murray", :number =>"123", :team_name =>"Team Oregon")
      race.results << Result.new(:place => "33", :first_name => "Danny", :last_name => "Knudsen", :number =>"305")
      race.results << Result.new(:place => "34", :first_name => "Mikkel", :last_name => "Anderson", :number =>"C32", :team_name =>"NoMad Sports Club")
      race.results << Result.new(:place => "35", :first_name => "Brian", :last_name => "Abers", :number =>"A44", :team_name =>"Team Rubicon")
      race.results << Result.new(:place => "36", :first_name => "Omer", :last_name => "Kem", :number =>"J38", :team_name =>"Subway")
      race.results << Result.new(:place => "37", :first_name => "Joseph", :last_name => "Cech", :number =>"X03")
      race.results << Result.new(:place => "38", :first_name => "Carl", :last_name => "Anton", :number =>"399", :team_name =>"North River Racing")
      race.results << Result.new(:place => "39", :first_name => "Tim", :last_name => "Coffey", :number =>"X04", :team_name =>"Gründelbrüisers")
      race.results << Result.new(:place => "40", :first_name => "Ryan", :last_name => "Thomson", :number =>"557", :team_name =>"Gentle Lovers")
      race.results << Result.new(:place => "41", :first_name => "Carl", :last_name => "Hoefer", :number =>"194", :team_name =>"Team Rubicon")
      race.results << Result.new(:place => "42", :first_name => "Jon", :last_name => "Myers", :number =>"117", :team_name =>"Team S&M")
      race.results << Result.new(:place => "", :first_name => "Yann", :last_name => "Blindert", :number =>"177", :team_name =>"Bike Gallery")
      race.results << Result.new(:place => "DNF", :first_name => "Jeff", :last_name => "Mitchem", :number =>"151", :team_name =>"Casa Bruno")
      race.results << Result.new(:place => "DNF", :first_name => "Craig", :last_name => "Broberg", :number =>"500", :team_name =>"FredMeyer Cycling Team")
      race.results << Result.new(:place => "DNF", :first_name => "Brad", :last_name => "Ganz", :number =>"770")
      race.results << Result.new(:place => "DNF", :first_name => "Bryan", :last_name => "Curry", :number =>"393", :team_name =>"Fred Meyer")
      race.results << Result.new(:place => "DQ", :first_name => "Chris", :last_name => "Alling", :number =>"168", :team_name =>"Columbia River Velo")
      race.results << Result.new(:place => "DNS", :first_name => "Dickie", :last_name => "Mallison", :number =>"140", :team_name =>"Guinness Cycling")
      races << race
    
      race = Race.new(:category => Category.new(:name => "Senior Men 3/4"))
      race.results << Result.new(:place => "1", :first_name => "Chuck", :last_name => "Sowers", :number =>"404", :team_name =>"Huntair", :points => "18.0")
      race.results << Result.new(:place => "2", :first_name => "Jason", :last_name => "Pfeifer", :number =>"C02", :team_name =>"Bike n Hike/Giant/Presto Velo", :points => "17.0")
      race.results << Result.new(:place => "3", :first_name => "Steven", :last_name => "Beardsley", :number =>"478", :team_name =>"Team Oregon", :points => "10.0")
      race.results << Result.new(:place => "4", :first_name => "Erik", :last_name => "Voldengen", :number =>"554", :team_name =>"BBC/Bike N Hike", :points => "10.0")
      race.results << Result.new(:place => "5", :first_name => "Heather", :last_name => "VanValkenburg", :number =>"209", :team_name =>"Sorella Forte/TVG", :points => "8.0")
      race.results << Result.new(:place => "6", :first_name => "Martin", :last_name => "Baker", :number =>"N40", :team_name =>"Presto Velo", :points => "8.0")
      race.results << Result.new(:place => "7", :first_name => "Chad", :last_name => "Cherefko", :number =>"H59", :team_name =>"Presto Velo", :points => "6.0")
      race.results << Result.new(:place => "8", :first_name => "Matt", :last_name => "Brownfield", :number =>"729", :team_name =>"Team Oregon", :points => "4.0")
      race.results << Result.new(:place => "9", :first_name => "Jason", :last_name => "Kentner", :number =>"917", :team_name =>"BBC", :points => "4.0")
      race.results << Result.new(:place => "10", :first_name => "Mike", :last_name => "Alligood", :number =>"603", :team_name =>"Gateway/Speedzone", :points => "2.0")
      race.results << Result.new(:place => "11", :first_name => "Richard", :last_name => "Fattic", :number =>"429", :points => "2.0")
      race.results << Result.new(:place => "12", :first_name => "Bryan", :last_name => "Brock", :number =>"583", :team_name =>"Presto Velo")
      race.results << Result.new(:place => "13", :first_name => "David", :last_name => "Pilz", :number =>"816", :team_name =>"The Bike Peddler")
      race.results << Result.new(:place => "14", :first_name => "Michael", :last_name => "Resnick", :number =>"X26", :team_name =>"NoMad Sports Club")
      race.results << Result.new(:place => "15", :first_name => "Robert", :last_name => "Chavier", :number =>"C13", :team_name =>"The Bike Peddler")
      race.results << Result.new(:place => "16", :first_name => "Jon", :last_name => "Frommelt", :number =>"453")
      race.results << Result.new(:place => "17", :first_name => "Steven", :last_name => "Lisac", :number =>"X50")
      race.results << Result.new(:place => "18", :first_name => "Josh", :last_name => "Friberg", :number =>"452", :team_name =>"Bike & Hike")
      race.results << Result.new(:place => "19", :first_name => "Jess", :last_name => "Graden", :number =>"27", :team_name =>"veloshop")
      race.results << Result.new(:place => "20", :first_name => "Jeff", :last_name => "Tedder", :number =>"840", :team_name =>"Huntair")
      race.results << Result.new(:place => "21", :first_name => "David", :last_name => "Strader", :number =>"773", :team_name =>"Team Oregon")
      race.results << Result.new(:place => "22", :first_name => "Jeff", :last_name => "Stong", :number =>"803", :team_name =>"North River Racing")
      race.results << Result.new(:place => "23", :first_name => "Richard", :last_name => "Lorenz", :number =>"K81", :team_name =>"EWEB Windpower")
      race.results << Result.new(:place => "24", :first_name => "Daniel", :last_name => "Ashcom", :number =>"H64")
      race.results << Result.new(:place => "25", :first_name => "Tommy", :last_name => "Tuite", :number =>"26", :team_name =>"veloshop")
      race.results << Result.new(:place => "26", :first_name => "Robert", :last_name => "White", :number =>"853")
      race.results << Result.new(:place => "27", :first_name => "Doug", :last_name => "Evans", :number =>"H33", :team_name =>"Bike&Hike")
      race.results << Result.new(:place => "28", :first_name => "Ian", :last_name => "Megale", :number =>"C00", :team_name =>"Fred Meyer")
      race.results << Result.new(:place => "29", :first_name => "Jeff", :last_name => "Vine", :number =>"874", :team_name =>"NoMad Sports Club")
      race.results << Result.new(:place => "30", :first_name => "Mary", :last_name => "Ross", :number =>"279", :team_name =>"NoMad Sports Club")
      race.results << Result.new(:place => "31", :first_name => "Joseph", :last_name => "Boquiren", :number =>"713", :team_name =>"Team Oregon")
      race.results << Result.new(:place => "32", :first_name => "Jerry", :last_name => "Inscoe", :number =>"728", :team_name =>"Presto Velo")
      race.results << Result.new(:place => "DNF", :first_name => "Stephen", :last_name => "Perkins", :number =>"N99")
      race.results << Result.new(:place => "DNF", :first_name => "Robert", :last_name => "Nobles", :number =>"C98", :team_name =>"GS Camerati")
      # Expect AndersEn because cat 3/4 race is imported later with same OBRA number
      race.results << Result.new(:place => "DNF", :first_name => "Mikkel", :last_name => "Andersen", :number =>"C32", :team_name =>"NoMad Sports Club")
      race.results << Result.new(:place => "DNF", :first_name => "R. Jim", :last_name => "Moore", :number =>"C85")
      races << race
    
      race = Race.new(:category => Category.new(:name => "Senior Men 4/5"))
      race.results << Result.new(:place => "1", :first_name => "Richard", :last_name => "Suditu", :number =>"909", :team_name =>"BBC", :points => "16.0")
      race.results << Result.new(:place => "2", :first_name => "John", :last_name => "Gleaves", :number =>"886", :team_name =>"BBC", :points => "13.0")
      race.results << Result.new(:place => "3", :first_name => "Chrios", :last_name => "Wood", :number =>"919", :team_name =>"Forza Jet Velo", :points => "12.0")
      race.results << Result.new(:place => "4", :first_name => "Paul", :last_name => "Kanz", :number =>"801", :team_name =>"Huntair", :points => "9.0")
      race.results << Result.new(:place => "5", :first_name => "Greg", :last_name => "Edwards", :number =>"K91", :points => "8.0")
      race.results << Result.new(:place => "6", :first_name => "Gary", :last_name => "Medley", :number =>"924", :points => "6.0")
      race.results << Result.new(:place => "7", :first_name => "Larry", :last_name => "Holzman", :number =>"K92", :team_name =>"North River Racing", :points => "5.0")
      race.results << Result.new(:place => "8", :first_name => "Charissa", :last_name => "Hallquist", :number =>"274", :team_name =>"BBC", :points => "4.0")
      race.results << Result.new(:place => "9", :first_name => "Thomas", :last_name => "Bradford", :number =>"700", :team_name =>"North River Racing", :points => "3.0")
      race.results << Result.new(:place => "10", :first_name => "Ronald", :last_name => "Kizzior", :number =>"H24", :points => "2.0")
      race.results << Result.new(:place => "11", :first_name => "Don", :last_name => "Vandervort", :number =>"C45", :team_name =>"Forza Jet Velo")
      race.results << Result.new(:place => "12", :first_name => "Eric", :last_name => "Kimble", :number =>"X34")
      race.results << Result.new(:place => "13", :first_name => "Cameron", :last_name => "Sparr", :number =>"768", :team_name =>"BBC")
      race.results << Result.new(:place => "14", :first_name => "Ian", :last_name => "Hendry", :number =>"X36")
      race.results << Result.new(:place => "15", :first_name => "Joel", :last_name => "Morrissette", :number =>"X90")
      race.results << Result.new(:place => "16", :first_name => "Eryn", :last_name => "Barker", :number =>"X33")
      race.results << Result.new(:place => "17", :first_name => "Risha", :last_name => "Kelley", :number =>"X14", :team_name =>"n/a")
      race.results << Result.new(:place => "18", :first_name => "Jim", :last_name => "Hinkley", :number =>"698")
      race.results << Result.new(:place => "19", :first_name => "Fiona", :last_name => "Graham", :number =>"215", :team_name =>"BBC")
      race.results << Result.new(:place => "DNF", :first_name => "Kallen", :last_name => "Dewey", :number =>"X53", :team_name =>"BBC")
      race.results << Result.new(:place => "DNF", :first_name => "Eric", :last_name => "Aleskus", :number =>"636")
      races << race
    
      races
    end
  
    def test_import_excel_usac_format
      RacingAssociation.current.usac_results_format = true
      event = SingleDayEvent.create!(:discipline => 'Road', :date => Date.new(2008, 5, 11))
      source_path = "#{File.dirname(__FILE__)}/../../fixtures/results/tt_usac.xls"
      results_file = ResultsFile.new(File.new(source_path), event)
      assert_equal(source_path, results_file.source.path, "file path")
      results_file.import

      expected_races = get_expected_races_usac_format
      assert_equal(expected_races.size, event.races.size, "Expected #{expected_races.size.to_s} event races but was #{event.races.size.to_s}")
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

    def get_expected_races_usac_format
      races = []

      race = Race.new(:category => Category.new(:name => "Master A Men"))
      race.results << Result.new(:place => "1", :first_name => "David", :last_name => "Landstrom", :number =>"20", :license =>"20280", :team_name =>"Flathead Cycling", :time => "0:37:32")
      race.results << Result.new(:place => "2", :first_name => "Richard", :last_name => "Graves", :number =>"223", :license =>"13949", :team_name =>"Flathead Cycling", :time => "0:40:36")
      race.results << Result.new(:place => "3", :first_name => "David", :last_name => "West", :number =>"201", :license =>"63105", :team_name =>"Echelon Cycling", :time => "0:40:49")
      race.results << Result.new(:place => "DQ", :first_name => "Robert", :last_name => "Ray", :number =>"237", :license =>"68315", :team_name =>"Great Divide")
      race.results << Result.new(:place => "DNS", :first_name => "Chad", :last_name => "Elkin", :number =>"264", :license =>"279240", :team_name =>"Great Falls Bicycle Club")
      races << race

      race = Race.new(:category => Category.new(:name => "Junior Men 10-18"))
      race.results << Result.new(:place => "1", :first_name => "Phil", :last_name => "Rayner", :number =>"335", :team_name =>"Headwinds", :time => "0:38:33")
      race.results << Result.new(:place => "2", :first_name => "Thomas", :last_name => "Greason", :number =>"212", :license =>"46661", :team_name =>"Bozeman Masters Velo", :time => "0:38:36")
      race.results << Result.new(:place => "DNF", :first_name => "Maxwell", :last_name => "Yanof", :number =>"468", :license =>"236853", :team_name =>"Bozeman Masters Velo")
      races << race

      races
    end

    def test_race_notes
      event = SingleDayEvent.create!
      results_file = ResultsFile.new(File.new("#{File.dirname(__FILE__)}/../../fixtures/results/tt.xls"), event)
      results_file.import
      assert_equal('Field Size: 40 riders, 40 Laps, Sunny, cool, 40K', event.races(true).first.notes, 'Race notes')
    end
    
    def test_race_notes_usac
      RacingAssociation.current.usac_results_format = true
      event = SingleDayEvent.create!
      results_file = ResultsFile.new(File.new("#{File.dirname(__FILE__)}/../../fixtures/results/tt_usac.xls"), event)
      results_file.import
      assert_equal('USCF, 2008, 563, 2012-05-11, Stage Race', event.races(true).first.notes, 'Race notes')
    end
  
    def build_result(race, place, first_name = nil, last_name = nil, team_name = nil)
      person = nil
      if first_name != nil && last_name != nil
        person = Person.new
        person.first_name = first_name
        person.last_name = last_name
      end
      team = nil
      if teamName != nil
        team = Team.new
        team.name = team_name
      end
      result = race.results.build(:place => place)
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
      for expected_race in expected_races
        actual_race = event.races[expected_races.index(expected_race)]
        assert_equal(expected_race.name, actual_race.name, "name")
        assert_equal(expected_race.city, actual_race.city, "city")
        assert_equal(expected_race.state, actual_race.state, "state")
        assert_equal(actual_race.results.size, actual_race.results.size, "results size for #{expected_race.name}")
        for expected_result in expected_race.results
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
        if actual_columns[index].field
          assert_equal(field, actual_columns[index].field, "Result column #{index} field")
        end
      end
    end
  end
end
