require File.dirname(__FILE__) + '/../test_helper'

class UpcomingEventsTest < ActiveSupport::TestCase

  # Default to next two weeks (spec start date and range)
  # Sub-categorize by weekly series or not (WeeklySeries, Series, MultiDayEvent)
  # Moved/cancelled?
  # Notes?
  # Other non-events?
  # Collapse weekly events that appear on multiple days. E.g., Kids on Track M/W/F
  # How to handle exceptions? (6/6 – 8/29) NO RACING 7/4 and (7/10 – 8/7 & Sun 8/13)
  # Test hour:day boundaries (e.g., today is 4 PM, event date is 1 AM)
  # Remove stage races from weekly section
  
  def test_new
    begin
      show_only_association_sanctioned_races_on_calendar = ASSOCIATION.show_only_association_sanctioned_races_on_calendar
      ASSOCIATION.show_only_association_sanctioned_races_on_calendar = true
      
      # Tuesday
      may_day_rr =      SingleDayEvent.create!(:date => Date.new(2008, 5, 27), :name => 'May Day Road Race', :discipline => 'Road', :flyer_approved => true)
      # Wednesday
      lucky_lab_tt =    SingleDayEvent.create!(:date => Date.new(2008, 5, 28), :name => 'Lucky Lab Road Race', :discipline => 'Time Trial', :flyer_approved => true)
      not_obra =        SingleDayEvent.create!(:date => Date.new(2008, 5, 28), :name => 'USA RR', :discipline => 'Road', :sanctioned_by => 'USA Cycling', :flyer_approved => true)
      # Sunday of next full week
      woodland_rr =     SingleDayEvent.create!(:date => Date.new(2008, 6, 8), :name => 'Woodland Road Race', :discipline => 'Road', :flyer_approved => true)
      tst_rr =          SingleDayEvent.create!(:date => Date.new(2008, 6, 8), :name => 'Tahuya-Seabeck-Tahuya', :discipline => 'Road', :flyer_approved => true)
      # Monday after that
      not_upcoming_rr = SingleDayEvent.create!(:date => Date.new(2008, 6, 9), :name => 'Not Upcoming Road Race', :discipline => 'Road', :flyer_approved => true)
      chain_breaker   = SingleDayEvent.create!(:date => Date.new(2008, 6, 9), :name => 'Chainbreaker', :discipline => 'Mountain Bike', :flyer_approved => true)
      # Monday before all other races (to test ordering)
      saltzman_hc =     SingleDayEvent.create!(:date => Date.new(2008, 5, 26), :name => 'Saltzman Hillclimb', :discipline => 'Road', :flyer_approved => true)
    
      SingleDayEvent.create!(:date => Date.new(2008, 5, 26), :name => 'Cancelled', :discipline => 'Road', :flyer_approved => true, :cancelled => true)
    
      # Weekly Series
      pir = WeeklySeries.create!(
        :date => Date.new(2008, 4, 1), :name => 'Tuesday PIR', :discipline => 'Road', :flyer_approved => true
      )
      Date.new(2008, 4, 1).step(Date.new(2008, 10, 21), 7) {|date|
        individual_pir = pir.events.create(:date => date, :name => 'Tuesday PIR', :discipline => 'Road', :flyer_approved => true)
        assert("PIR valid?", individual_pir.valid?)
        assert("PIR new?", !individual_pir.new_record?)
      }
      pir.reload
      assert("PIR valid?", pir.valid?)
      assert("PIR new?", !pir.new_record?)
    
      # Way, wayback
      upcoming_events = UpcomingEvents.new(Date.new(2008, 1, 1))
      assert_equal([], upcoming_events.events['Road'], 'UpcomingEvents.events[Road]')
      assert_equal([], upcoming_events.weekly_series['Road'], 'UpcomingEvents.weekly_series[Road]')
      assert_equal([], upcoming_events.events['Mountain Bike'], 'UpcomingEvents.events[Mountain Bike]')
    
      # Wayback
      upcoming_events = UpcomingEvents.new(Date.new(2008, 05, 11))
      assert_equal([], upcoming_events.events['Road'], 'UpcomingEvents.events[Road]')
      assert_equal([], upcoming_events.events['Mountain Bike'], 'UpcomingEvents.events[Mountain Bike]')
      assert_equal([pir], upcoming_events.weekly_series['Road'], 'UpcomingEvents.weekly_series[Road]')
    
      # Sunday
      upcoming_events = UpcomingEvents.new(Date.new(2008, 05, 25))
      assert_equal([saltzman_hc, may_day_rr, lucky_lab_tt, woodland_rr, tst_rr], upcoming_events.events['Road'], 'UpcomingEvents.events[Road]')
      assert_equal([], upcoming_events.events['Mountain Bike'], 'UpcomingEvents.events[Mountain Bike]')
    
      # Monday
      upcoming_events = UpcomingEvents.new(Date.new(2008, 05, 26))
      assert_equal_events([saltzman_hc, may_day_rr, lucky_lab_tt, woodland_rr, tst_rr], upcoming_events.events['Road'], 'UpcomingEvents.events[Road]')
      assert_equal([], upcoming_events.events['Mountain Bike'], 'UpcomingEvents.events[Mountain Bike]')
    
      # Tuesday
      upcoming_events = UpcomingEvents.new(Date.new(2008, 05, 27))
      assert_equal([may_day_rr, lucky_lab_tt, woodland_rr, tst_rr], upcoming_events.events['Road'], 'UpcomingEvents.events[Road]')
      assert_equal([], upcoming_events.events['Mountain Bike'], 'UpcomingEvents.events[Mountain Bike]')

      upcoming_events = UpcomingEvents.new(DateTime.new(2008, 05, 27, 1, 0, 0))
      assert_equal_events([may_day_rr, lucky_lab_tt, woodland_rr, tst_rr], upcoming_events.events['Road'], 'UpcomingEvents.events[Road]')
      assert_equal([], upcoming_events.events['Mountain Bike'], 'UpcomingEvents.events[Mountain Bike]')

      upcoming_events = UpcomingEvents.new(DateTime.new(2008, 05, 27, 23, 59, 0))
      assert_equal([may_day_rr, lucky_lab_tt, woodland_rr, tst_rr], upcoming_events.events['Road'], 'UpcomingEvents.events[Road]')
      assert_equal([], upcoming_events.events['Mountain Bike'], 'UpcomingEvents.events[Mountain Bike]')
    
      # Wednesday
      upcoming_events = UpcomingEvents.new(Date.new(2008, 05, 28))
      assert_equal([lucky_lab_tt, woodland_rr, tst_rr], upcoming_events.events['Road'], 'UpcomingEvents.events[Road]')
      assert_equal([], upcoming_events.events['Mountain Bike'], 'UpcomingEvents.events[Mountain Bike]')

      # Next Sunday
      upcoming_events = UpcomingEvents.new(Date.new(2008, 06, 1))
      assert_equal([woodland_rr, tst_rr, not_upcoming_rr], upcoming_events.events['Road'], 'UpcomingEvents.events[Road]')
      assert_equal([chain_breaker], upcoming_events.events['Mountain Bike'], 'UpcomingEvents.events[Mountain Bike]')

      # Next Monday
      upcoming_events = UpcomingEvents.new(Date.new(2008, 06, 2))
      assert_equal([woodland_rr, tst_rr, not_upcoming_rr], upcoming_events.events['Road'], 'UpcomingEvents.events[Road]')
      assert_equal([chain_breaker], upcoming_events.events['Mountain Bike'], 'UpcomingEvents.events[Mountain Bike]')

      # Monday after all events
      upcoming_events = UpcomingEvents.new(Date.new(2008, 06, 10))
      assert_equal([], upcoming_events.events['Road'], 'UpcomingEvents.events[Road]')
      assert_equal([], upcoming_events.events['Mountain Bike'], 'UpcomingEvents.events[Mountain Bike]')
    
      # Big range
      upcoming_events = UpcomingEvents.new(Date.new(2008, 5, 26), 16)
      assert_equal([saltzman_hc, may_day_rr, lucky_lab_tt, woodland_rr, tst_rr, not_upcoming_rr], upcoming_events.events['Road'], 'UpcomingEvents.events[Road]')
    
      # Small range
      upcoming_events = UpcomingEvents.new(DateTime.new(2008, 05, 27), 1)
      assert_equal([may_day_rr, lucky_lab_tt], upcoming_events.events['Road'], 'UpcomingEvents.events[Road]')
    
      # Include ALL events regardless of sanctioned_by
      ASSOCIATION.show_only_association_sanctioned_races_on_calendar = false
      upcoming_events = UpcomingEvents.new(Date.new(2008, 05, 25))
      assert_equal([saltzman_hc, may_day_rr, lucky_lab_tt, not_obra, woodland_rr, tst_rr], upcoming_events.events['Road'], 'UpcomingEvents.events[Road]')
    ensure
      ASSOCIATION.show_only_association_sanctioned_races_on_calendar = show_only_association_sanctioned_races_on_calendar
    end
  end
  
  def test_midweek_multiday_event
    six_day = MultiDayEvent.create!(
      :date => Date.new(2006, 6, 12), :name => 'Alpenrose Six Day', :discipline => 'Track', :flyer_approved => true
    )
    Date.new(2006, 6, 12).step(Date.new(2006, 6, 17), 1) {|date|
      single_day_six_day = SingleDayEvent.create!(:parent => six_day, :date => date, :name => 'Alpenrose Six Day', :discipline => 'Track', :flyer_approved => true)
      assert("Six Day valid?", single_day_six_day.valid?)
      assert("Six Day new?", !single_day_six_day.new_record?)
    }
    six_day.save!
    assert("Six Day valid?", six_day.valid?)
    assert_equal(6, six_day.events.size, 'Six Day events')
    assert_equal_dates(Date.new(2006, 6, 12), six_day.date, 'Six Day date')
    assert_equal_dates(Date.new(2006, 6, 12), six_day.start_date, 'Six Day start date')
    assert_equal_dates(Date.new(2006, 6, 17), six_day.end_date, 'Six Day end date')
    
    # Way, wayback
    upcoming_events = UpcomingEvents.new(Date.new(2006, 1, 1))
    assert_equal([], upcoming_events.events['Road'], 'UpcomingEvents.events[Road]')
    assert_equal([], upcoming_events.weekly_series['Road'], 'UpcomingEvents.weekly_series[Road]')
    assert_equal([], upcoming_events.events['Mountain Bike'], 'UpcomingEvents.events[Mountain Bike]')
    assert_equal([], upcoming_events.events['Track'], 'UpcomingEvents.events[Track]')
    assert_equal([], upcoming_events.weekly_series['Track'], 'UpcomingEvents.weekly_series[Track]')
    
    # Wayback
    upcoming_events = UpcomingEvents.new(Date.new(2006, 5, 28))
    assert_equal([], upcoming_events.events['Road'], 'UpcomingEvents.events[Road]')
    assert_equal([], upcoming_events.weekly_series['Road'], 'UpcomingEvents.weekly_series[Road]')
    assert_equal([], upcoming_events.events['Mountain Bike'], 'UpcomingEvents.events[Mountain Bike]')
    assert_equal([], upcoming_events.events['Track'], 'UpcomingEvents.events[Track]')
    assert_equal([], upcoming_events.weekly_series['Track'], 'UpcomingEvents.weekly_series[Track]')
    
    # Monday
    upcoming_events = UpcomingEvents.new(Date.new(2006, 05, 29))
    assert_equal([], upcoming_events.events['Road'], 'UpcomingEvents.events[Road]')
    assert_equal([], upcoming_events.weekly_series['Road'], 'UpcomingEvents.weekly_series[Road]')
    assert_equal([], upcoming_events.events['Mountain Bike'], 'UpcomingEvents.events[Mountain Bike]')
    assert_equal([], upcoming_events.events['Track'], 'UpcomingEvents.events[Track]')
    assert_equal([], upcoming_events.weekly_series['Track'], 'UpcomingEvents.weekly_series[Track]')
    
    # Tuesday
    upcoming_events = UpcomingEvents.new(Date.new(2006, 05, 30))
    assert_equal([], upcoming_events.events['Track'], 'UpcomingEvents.events[Track]')
    
    upcoming_events = UpcomingEvents.new(Date.new(2006, 06, 2))
    assert_equal([], upcoming_events.events['Track'], 'UpcomingEvents.events[Track]')
    
    upcoming_events = UpcomingEvents.new(Date.new(2006, 6, 3))
    assert_equal_enumerables([six_day], upcoming_events.events['Track'], 'UpcomingEvents.events[Track]')
    
    # Saturday
    upcoming_events = UpcomingEvents.new(Date.new(2006, 6, 16))
    assert_equal([six_day], upcoming_events.events['Track'], 'UpcomingEvents.events[Track]')
    
    # Sunday
    upcoming_events = UpcomingEvents.new(Date.new(2006, 6, 17))
    assert_equal_events([six_day], upcoming_events.events['Track'], 'UpcomingEvents.events[Track]')

    # Next Monday
    upcoming_events = UpcomingEvents.new(Date.new(2006, 6, 18))
    assert_equal([], upcoming_events.events['Track'], 'UpcomingEvents.events[Track]')
  end

  def test_cutoff_date
    upcoming_events = UpcomingEvents.new
    assert_equal_dates(Date.new(2008, 6, 8), upcoming_events.cutoff_date(Date.new(2008, 5, 24), 2), 'Cutoff date')
    assert_equal_dates(Date.new(2008, 6, 8), upcoming_events.cutoff_date(Date.new(2008, 5, 25), 2), 'Cutoff date')
    assert_equal_dates(Date.new(2008, 6, 8), upcoming_events.cutoff_date(Date.new(2008, 5, 26), 2), 'Cutoff date')
    assert_equal_dates(Date.new(2008, 6, 8), upcoming_events.cutoff_date(Date.new(2008, 5, 27), 2), 'Cutoff date')
    assert_equal_dates(Date.new(2008, 6, 8), upcoming_events.cutoff_date(Date.new(2008, 5, 28), 2), 'Cutoff date')
    assert_equal_dates(Date.new(2008, 6, 8), upcoming_events.cutoff_date(Date.new(2008, 5, 29), 2), 'Cutoff date')
    assert_equal_dates(Date.new(2008, 6, 8), upcoming_events.cutoff_date(Date.new(2008, 5, 30), 2), 'Cutoff date')
    assert_equal_dates(Date.new(2008, 6, 15), upcoming_events.cutoff_date(Date.new(2008, 5, 31), 2), 'Cutoff date')
    assert_equal_dates(Date.new(2008, 6, 15), upcoming_events.cutoff_date(Date.new(2008, 6, 1), 2), 'Cutoff date')
    assert_equal_dates(Date.new(2008, 6, 15), upcoming_events.cutoff_date(Date.new(2008, 6, 2), 2), 'Cutoff date')
    assert_equal_dates(Date.new(2009, 1, 11), upcoming_events.cutoff_date(Date.new(2008, 12, 31), 2), 'Cutoff date')
    # bad tests
    assert_equal_dates(Date.new(2008, 6, 1), upcoming_events.cutoff_date(Date.new(2008, 5, 24), 1), 'Cutoff date')
    assert_equal_dates(Date.new(2009, 12, 27), upcoming_events.cutoff_date(Date.new(2008, 12, 31), 52), 'Cutoff date')
  end
  
  def test_weekly_series
    six_day = WeeklySeries.create!(
      :date => Date.new(1999, 6, 8), :name => 'Alpenrose Six Day', :discipline => 'Track', :flyer_approved => true
    )
    Date.new(1999, 6, 8).step(Date.new(1999, 7, 27), 7) {|date|
      single_day_six_day = SingleDayEvent.create!(:parent => six_day, :date => date, :name => 'Alpenrose Six Day', :discipline => 'Track', :flyer_approved => true)
      assert("Six Day valid?", single_day_six_day.valid?)
      assert("Six Day new?", !single_day_six_day.new_record?)
    }
    six_day.save!
    assert("Six Day valid?", six_day.valid?)
    assert_equal(8, six_day.events.size, 'Six Day events')
    assert_equal_dates(Date.new(1999, 6, 8), six_day.date, 'Six Day date')
    assert_equal_dates(Date.new(1999, 6, 8), six_day.start_date, 'Six Day start date')
    assert_equal_dates(Date.new(1999, 7, 27), six_day.end_date, 'Six Day end date')
    
    # Way, wayback
    upcoming_events = UpcomingEvents.new(Date.new(1999, 1, 1))
    assert_equal([], upcoming_events.events['Road'], 'UpcomingEvents.events[Road]')
    assert_equal([], upcoming_events.weekly_series['Road'], 'UpcomingEvents.weekly_series[Road]')
    assert_equal([], upcoming_events.events['Mountain Bike'], 'UpcomingEvents.events[Mountain Bike]')
    assert_equal([], upcoming_events.events['Track'], 'UpcomingEvents.events[Track]')
    assert_equal([], upcoming_events.weekly_series['Track'], 'UpcomingEvents.weekly_series[Track]')
    
    # Wayback
    upcoming_events = UpcomingEvents.new(Date.new(1999, 5, 24))
    assert_equal([], upcoming_events.events['Road'], 'UpcomingEvents.events[Road]')
    assert_equal([], upcoming_events.weekly_series['Road'], 'UpcomingEvents.weekly_series[Road]')
    assert_equal([], upcoming_events.events['Mountain Bike'], 'UpcomingEvents.events[Mountain Bike]')
    assert_equal([], upcoming_events.events['Track'], 'UpcomingEvents.events[Track]')
    assert_equal([], upcoming_events.weekly_series['Track'], 'UpcomingEvents.weekly_series[Track]')
    
    # Monday
    upcoming_events = UpcomingEvents.new(Date.new(1999, 05, 25))
    assert_equal([], upcoming_events.events['Road'], 'UpcomingEvents.events[Road]')
    assert_equal([], upcoming_events.weekly_series['Road'], 'UpcomingEvents.weekly_series[Road]')
    assert_equal([], upcoming_events.events['Mountain Bike'], 'UpcomingEvents.events[Mountain Bike]')
    assert_equal([], upcoming_events.events['Track'], 'UpcomingEvents.events[Track]')
    assert_equal([], upcoming_events.weekly_series['Track'], 'UpcomingEvents.weekly_series[Track]')
    
    # Tuesday
    upcoming_events = UpcomingEvents.new(Date.new(1999, 6, 7))
    assert_equal_enumerables([], upcoming_events.events['Track'], 'UpcomingEvents.events[Track]')
    assert_equal_enumerables([six_day], upcoming_events.weekly_series['Track'], 'UpcomingEvents.events[Track]')
    
    # Saturday
    upcoming_events = UpcomingEvents.new(Date.new(1999, 5, 29))
    assert_equal_enumerables([], upcoming_events.events['Track'], 'UpcomingEvents.events[Track]')
    assert_equal([six_day], upcoming_events.weekly_series['Track'], 'UpcomingEvents.events[Track]')
    
    # Sunday
    upcoming_events = UpcomingEvents.new(Date.new(1999, 5, 30))
    assert_equal([], upcoming_events.events['Track'], 'UpcomingEvents.events[Track]')
    assert_equal_enumerables([six_day], upcoming_events.weekly_series['Track'], 'UpcomingEvents.events[Track]')

    # Afterward
    upcoming_events = UpcomingEvents.new(Date.new(1999, 7, 28))
    assert_equal_enumerables([], upcoming_events.events['Track'], 'UpcomingEvents.events[Track]')
    assert_equal([], upcoming_events.weekly_series['Track'], 'UpcomingEvents.events[Track]')
  end
  
  def test_series
    estacada_tt = Series.create!(
      :date => Date.new(1999, 6, 8), :name => 'Estacada', :discipline => 'Time Trial', :flyer_approved => true
    )
    
    estacada_tt_1 = estacada_tt.events.create(:date => Date.new(1999, 6, 8), :name => 'Estacada', :discipline => 'Time Trial', :flyer_approved => true)
    assert("estacada_tt_1 valid?", estacada_tt_1.valid?)
    
    estacada_tt_2 = estacada_tt.events.create(:date => Date.new(1999, 6, 22), :name => 'Estacada', :discipline => 'Time Trial', :flyer_approved => true)
    assert("estacada_tt_2 valid?", estacada_tt_2.valid?)
    
    estacada_tt_3 = estacada_tt.events.create(:date => Date.new(1999, 6, 24), :name => 'Estacada', :discipline => 'Time Trial', :flyer_approved => true)
    assert("estacada_tt_3 valid?", estacada_tt_3.valid?)
    
    assert_equal(3, estacada_tt.events.size, 'estacada_tt events')
    assert_equal_dates(Date.new(1999, 6, 8), estacada_tt.date, 'estacada_tt date')
    assert_equal_dates(Date.new(1999, 6, 8), estacada_tt.start_date, 'estacada_tt start date')
    assert_equal_dates(Date.new(1999, 6, 24), estacada_tt.end_date, 'estacada_tt end date')

    # Way, wayback
    upcoming_events = UpcomingEvents.new(Date.new(1999, 1, 1))
    assert_equal([], upcoming_events.events['Road'], 'UpcomingEvents.events[Road]')
    assert_equal([], upcoming_events.weekly_series['Road'], 'UpcomingEvents.weekly_series[Road]')
    assert_equal([], upcoming_events.events['Mountain Bike'], 'UpcomingEvents.events[Mountain Bike]')
    assert_equal([], upcoming_events.events['Track'], 'UpcomingEvents.events[Track]')
    assert_equal([], upcoming_events.weekly_series['Track'], 'UpcomingEvents.weekly_series[Track]')

    upcoming_events = UpcomingEvents.new(Date.new(1999, 6, 7))
    assert_equal_enumerables([estacada_tt_1], upcoming_events.events['Road'], 'UpcomingEvents.events[Road]')
    assert_equal_enumerables([], upcoming_events.weekly_series['Road'], 'UpcomingEvents.events[Road]')

    upcoming_events = UpcomingEvents.new(Date.new(1999, 6, 20))
    assert_equal_enumerables([estacada_tt_2, estacada_tt_3], upcoming_events.events['Road'], 'UpcomingEvents.events[Road]')
    assert_equal_enumerables([], upcoming_events.weekly_series['Road'], 'UpcomingEvents.events[Road]')
  end
  
  def test_downhill_events
    super_d = SingleDayEvent.create!(:date => Date.new(2008, 5, 27), :name => 'Super D', :discipline => 'Downhill', :flyer_approved => true)

    upcoming_events = UpcomingEvents.new(Date.new(2008, 05, 26))
    assert_equal_events([], upcoming_events.events['Road'], 'UpcomingEvents.events[Road]')
    assert_equal_events([super_d], upcoming_events.events['Mountain Bike'], 'UpcomingEvents.events[Mountain Bike]')
  end
  
  def test_empty
    upcoming_events = UpcomingEvents.new(Date.new(1990, 6, 7))
    assert(upcoming_events.empty?)

    upcoming_events = UpcomingEvents.new
    assert(!upcoming_events.empty?)
  end
end