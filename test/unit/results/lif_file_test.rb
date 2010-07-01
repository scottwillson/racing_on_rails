require File.expand_path("../../../test_helper", __FILE__)
require "tempfile"
require "spreadsheet"

class LifFileTest < ActiveSupport::TestCase
  def test_import
    event = SingleDayEvent.create!(:date => Date.today + 3)
    results_file = Results::LifFile.new(File.expand_path("../../../fixtures/results/OutputFile.lif",  __FILE__), event)
    results_file.import
    
    event.reload
    
    assert_equal 1, event.races.count, "Races"
    race = event.races.first
    assert_equal "M3", race.category_name, "Race category"
    assert_equal 12, race.results.size
    
    result = race.results.first
    assert_equal "1", result.place, "place"
    assert_equal "Killin", result.last_name, "last_name"
    assert_equal "Sam", result.first_name, "first_name"
    assert_equal "Purdue", result.team_name, "team"
    assert_equal 3259.718, result.time, "time"
    assert_equal 0.0, result.time_gap_to_leader, "time_gap_to_leader"
    
    result = race.results[1]
    assert_equal "2", result.place, "place"
    assert_equal "Zsivoczky", result.last_name, "last_name"
    assert_equal "Attila", result.first_name, "first_name"
    assert_equal "Kansas State", result.team_name, "team"
    assert_equal 3300, result.time, "time"
    assert_equal 41.282, result.time_gap_to_leader, "time_gap_to_leader"
    
    assert_same_elements [ "place", "number", "category_name", "last_name", "first_name", "team_name", "time", "license", "time_gap_to_leader" ],
                         race.result_columns,
                         "result_columns"
  end
end
