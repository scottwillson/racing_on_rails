require File.dirname(__FILE__) + '/../test_helper'

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
    standings = event.standings.create!
    race = standings.races.create!(:category => categories(:senior_men))
    event.events.create!
    assert(!event.has_results?, "Series with race, but no results should not have results")
    
    race.results.create!(:place => 200, :racer => racers(:matson))
    assert(event.has_results?, "Series with one result should not have results")
  end
  
  def test_has_results_in_child_event
    event = Series.create!
    child_event = event.events.create!
    standings = child_event.standings.create!
    race = standings.races.create!(:category => categories(:senior_men))
    
    race.results.create!(:place => 200, :racer => racers(:matson))
    assert(event.has_results?, "Series with one result in child Event should not have results")
  end
end