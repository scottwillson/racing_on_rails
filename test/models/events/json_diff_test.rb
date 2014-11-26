require "test_helper"

module Events
  # :stopdoc:
  class JsonDiffTest < ActiveSupport::TestCase
    test "as_json" do
      event = SingleDayEvent.new(name: "July Road Race", id: 1)
      expected = { 
        "discipline" => "Road",
        "name" => "July Road Race",
        "parent_id" => nil,
        "type" => "SingleDayEvent",
        "sorted_races" => []
      }
      
      diff = HashDiff.best_diff(expected, event.as_json(nil))
      assert diff.empty?, diff
    end
    
    test "identical events should have same JSON" do
      event = SingleDayEvent.new(name: "July Road Race")
      event_2 = SingleDayEvent.new(name: "July Road Race")
      diff = HashDiff.best_diff(event.as_json(nil), event_2.as_json(nil))
      assert diff.empty?, diff
    end
    
    test "different events should have different JSON" do
      event = SingleDayEvent.new(name: "July Road Race")
      event_2 = SingleDayEvent.new(name: "July Criterium")
      diff = HashDiff.best_diff(event.as_json(nil), event_2.as_json(nil))
      assert_equal 1, diff.size, "Should have two differences"
      assert_equal "name", diff[0][1], "name should be different in #{diff}"
    end
    
    test "as_json should include races" do
      event = SingleDayEvent.new
      event.races << Race.new
      assert event.as_json(nil)["sorted_races"], "races"
    end
    
    test "different races should have different JSON" do
      event = SingleDayEvent.new(name: "July Road Race")
      event.races << Race.new(category_name: "Junior Men")
      event.races << Race.new(category_name: "Senior Men")
      
      event_2 = SingleDayEvent.new(name: "July Road Race")
      event_2.races << Race.new(category_name: "Junior Women")
      event_2.races << Race.new(category_name: "Senior Men")

      diff = HashDiff.best_diff(event.as_json(nil), event_2.as_json(nil))

      assert_equal 2, diff.size, "Should have differences"

      assert_equal "sorted_races[0]", diff[0][1], "should find different race"
      assert_equal "sorted_races[0]", diff[1][1], "should find different race"

      assert diff.detect { |difference| difference[2]["name"] == "Junior Men" }, "Category name should be different in #{diff}"
      assert diff.detect { |difference| difference[2]["name"] == "Junior Women" }, "Category name should be different in #{diff}"
    end
    
    test "different results should have different JSON" do
      event = SingleDayEvent.new(name: "July Road Race", date: Date.new(2012, 7, 1))
      race = Race.new(category_name: "Junior Men")
      event.races << race
      race.results << Result.new(place: "1", person_id: 1)
      
      event_2 = SingleDayEvent.new(name: "July Road Race", date: Date.new(2012, 7, 1))
      race = Race.new(category_name: "Junior Men")
      event_2.races << race
      race.results << Result.new(place: "1", person_id: 99)

      diff = HashDiff.best_diff(event.as_json(nil), event_2.as_json(nil))
      assert_equal 1, diff.size, "Should have differences in #{diff}"
    end
  end
end
