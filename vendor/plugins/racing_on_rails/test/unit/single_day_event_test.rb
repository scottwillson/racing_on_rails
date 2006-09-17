require File.dirname(__FILE__) + '/../test_helper'

class SingleDayEventTest < Test::Unit::TestCase
  
  fixtures :promoters, :events, :aliases_disciplines, :disciplines, :users

  def test_find_all_by_year_month
    events = SingleDayEvent.find_all_by_year_month(1980, 1)
    assert_equal(0, events.size, "find_all_by_year_month(1980, 1)")

    events = SingleDayEvent.find_all_by_year_month(2005, 6)
    assert_equal(0, events.size, "find_all_by_year_month(2005, 6)")
    
    events = SingleDayEvent.find_all_by_year_month(2003, 12)
    assert_equal(1, events.size, "find_all_by_year_month(2003, 12)")
    
    events = SingleDayEvent.find_all_by_year_month(2004, 1)
    assert_equal(4, events.size, "find_all_by_year_month(2004, 1)")
    
    events = SingleDayEvent.find_all_by_year_month(2005, 7)
    assert_equal(5, events.size, "find_all_by_year_month(2005, 7)")
  end
end