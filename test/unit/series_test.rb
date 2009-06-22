require "test_helper"

class SeriesTest < ActiveSupport::TestCase  
  def test_new
    series = Series.new
    series.save!
  end
  
  def test_friendly_class_name
    event = Series.new
    assert_equal("Series", event.friendly_class_name, "friendly_class_name")
  end

  def test_missing_children
    assert(!events(:banana_belt_series).missing_children?, "banana_belt_series should have no missing children")
    assert(events(:banana_belt_series).missing_children.empty?, "banana_belt_series should have no missing children")
  end
  
  def test_has_results
    assert(!Series.new.has_results?, "New Series should not have results")
    
    event = Series.create!
    race = event.races.create!(:category => categories(:senior_men))
    event.children.create!
    assert(!event.has_results?, "Series with race, but no results should not have results")
    
    race.results.create!(:place => 200, :person => people(:matson))
    assert(event.has_results?(true), "Series with one with result should have results")
    assert(event.has_results_including_children?(true), "Series with result should have results if children are included")
  end
  
  def test_has_results_in_child_event
    event = Series.create!
    child_event = event.children.create!
    race = child_event.races.create!(:category => categories(:senior_men))
    
    race.results.create!(:place => 200, :person => people(:matson))
    assert(!event.has_results?(true), "Series with one result in child Event should not have results")
    assert(event.has_results_including_children?(true), "Series with one result in child Event should have results if children are included")
  end
end