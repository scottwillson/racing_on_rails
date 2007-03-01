require File.dirname(__FILE__) + '/../test_helper'

class SingleDayEventTest < Test::Unit::TestCase
  
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
  
  def test_find_all_by_year
    begin
      show_only_association_sanctioned_races_on_calendar = ASSOCIATION.show_only_association_sanctioned_races_on_calendar
      ASSOCIATION.show_only_association_sanctioned_races_on_calendar = true
      events = SingleDayEvent.find_all_by_year(2004)
      assert_equal(4, events.size, "test_find_all_by_year for 2004 events only found: #{events.join(', ')}")

      ASSOCIATION.show_only_association_sanctioned_races_on_calendar = false
      events = SingleDayEvent.find_all_by_year(2004)
      assert_equal(5, events.size, "test_find_all_by_year for 2004 events only found: #{events.join(', ')}")
    ensure
      ASSOCIATION.show_only_association_sanctioned_races_on_calendar = show_only_association_sanctioned_races_on_calendar
    end
  end

  def test_new
    event = SingleDayEvent.new
    assert_equal(0, event.standings.size, "New event should have no standings")
  end

  def test_create
    event = SingleDayEvent.create
    assert_equal('Needed', event.first_aid_provider, "New event first aid provider")

    event = SingleDayEvent.create(:name => 'Copperopolis')
    assert_equal('Needed', event.first_aid_provider, "New event first aid provider")
  end
end