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
end