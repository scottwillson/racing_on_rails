require File.expand_path("../../../test_helper", __FILE__)

# :stopdoc:
class UpcomingEventsTest < ActiveSupport::TestCase
  # Moved/cancelled?
  # Notes?
  # Other non-events?
  # Collapse weekly events that appear on multiple days. E.g., Kids on Track M/W/F
  # How to handle exceptions? (6/6 – 8/29) NO RACING 7/4 and (7/10 – 8/7 & Sun 8/13)
  # Test hour:day boundaries (e.g., today is 4 PM, event date is 1 AM)
  # Remove stage races from weekly section
  
  def test_new
    FactoryGirl.create(:discipline, :name => "Track")
    upcoming_events = UpcomingEvents::Base.new(Time.zone.today, 2, nil)
    assert_equal(nil, upcoming_events.discipline, "default discipline")
    assert_equal(2, upcoming_events.weeks, "default weeks")
    
    date = 1.year.ago
    upcoming_events = UpcomingEvents::Base.new(date, 4, "Track")
    assert_equal("Track", upcoming_events.discipline, "discipline")
    assert_equal(4, upcoming_events.weeks, "weeks")
  end

  def test_different_dates
    FactoryGirl.create(:discipline, :name => "Mountain Bike")
    FactoryGirl.create(:discipline, :name => "Road")
    FactoryGirl.create(:discipline, :name => "Time Trial")
    FactoryGirl.create(:discipline, :name => "Track")

    RacingAssociation.current.show_only_association_sanctioned_races_on_calendar = true
    
    # Tuesday
    may_day_rr =      SingleDayEvent.create!(:date => Date.new(2007, 5, 22), :name => 'May Day Road Race', :discipline => 'Road', :flyer_approved => true)
    practice_sessions = WeeklySeries.create!(
      :start_date => Date.new(2007, 4), :end_date => Date.new(2007, 7), :name => 'Brian Abers Training', :discipline => 'Track', 
      :practice => true, :flyer_approved => true, :every => "Tuesday"
    )
    # Wednesday
    lucky_lab_tt =    SingleDayEvent.create!(:date => Date.new(2007, 5, 23), :name => 'Lucky Lab Road Race', :discipline => 'Time Trial', :flyer_approved => true)
    not_obra =        SingleDayEvent.create!(:date => Date.new(2007, 5, 23), :name => 'USA RR', :discipline => 'Road', :sanctioned_by => 'USA Cycling', :flyer_approved => true)
    track_class = WeeklySeries.create!(
      :start_date => Date.new(2007, 4), :end_date => Date.new(2007, 7), :name => 'Track Class', :discipline => 'Track', 
      :instructional => true, :flyer_approved => true, :every => "Wednesday"
    )
    # Sunday of next full week
    woodland_rr =     SingleDayEvent.create!(:date => Date.new(2007, 6, 3), :name => 'Woodland Road Race', :discipline => 'Road', :flyer_approved => true, :flyer => "http://obra.org/woodland")
    tst_rr =          SingleDayEvent.create!(:date => Date.new(2007, 6, 3), :name => 'Tahuya-Seabeck-Tahuya', :discipline => 'Road', :flyer_approved => true)
    # Monday after that
    not_upcoming_rr = SingleDayEvent.create!(:date => Date.new(2007, 6, 4), :name => 'Not Upcoming Road Race', :discipline => 'Road', :flyer_approved => true)
    chain_breaker   = SingleDayEvent.create!(:date => Date.new(2007, 6, 4), :name => 'Chainbreaker', :discipline => 'Mountain Bike', :flyer_approved => true)
    # Monday before all other races (to test ordering)
    saltzman_hc =     SingleDayEvent.create!(:date => Date.new(2007, 5, 21), :name => 'Saltzman Hillclimb', :discipline => 'Road', :flyer_approved => true)
  
    SingleDayEvent.create!(:date => Date.new(2007, 5, 21), :name => 'Cancelled', :discipline => 'Road', :flyer_approved => true, :cancelled => true)
  
    # Weekly Series
    pir = WeeklySeries.create!(
      :date => Date.new(2007, 4, 3), :name => 'Tuesday PIR', :discipline => 'Road', :flyer_approved => true, :flyer => "http://obra.org/pir"
    )
    Date.new(2007, 4, 3).step(Date.new(2007, 10, 23), 7) {|date|
      individual_pir = pir.children.create!(:date => date, :name => 'Tuesday PIR', :discipline => 'Road', :flyer_approved => true)
      assert(individual_pir.valid?, "PIR valid?")
      assert(!individual_pir.new_record?, "PIR new?")
    }
    pir.reload
    assert(pir.valid?, "PIR valid?")
    assert(!pir.new_record?, "PIR new?")
  
    # Way, wayback
    upcoming_events = UpcomingEvents.find_all(:date => Date.new(2005, 1, 1))
    assert_equal(nil, upcoming_events['Road'], 'UpcomingEvents.events[Road]')
    assert_equal(nil, upcoming_events['Mountain Bike'], 'UpcomingEvents.events[Mountain Bike]')
  
    # Wayback
    upcoming_events = UpcomingEvents.find_all(:date => Date.new(2007, 05, 6))
    assert_equal([], upcoming_events['Road'].upcoming_events, 'UpcomingEvents.events[Road]')
    assert_equal(nil, upcoming_events['Mountain Bike'], 'UpcomingEvents.events[Mountain Bike]')
    assert_equal_events([pir], upcoming_events['Road'].upcoming_weekly_series, 'UpcomingEvents.upcoming_weekly_series[Road]')
    assert_equal("http://obra.org/pir", upcoming_events['Road'].upcoming_weekly_series.first.flyer, "PIR flyer")
  
    # Sunday
    upcoming_events = UpcomingEvents.find_all(:date => Date.new(2007, 05, 20))
    assert_same_elements([saltzman_hc, may_day_rr, lucky_lab_tt, woodland_rr, tst_rr], upcoming_events['Road'].upcoming_events, 'UpcomingEvents.events[Road]')
    assert_equal(nil, upcoming_events['Mountain Bike'], 'UpcomingEvents.events[Mountain Bike]')
    assert_equal(nil, upcoming_events['Track'], 'UpcomingEvents.events[Track]')
  
    # Monday
    upcoming_events = UpcomingEvents.find_all(:date => Date.new(2007, 05, 21))
    assert_equal_events([saltzman_hc, may_day_rr, lucky_lab_tt, woodland_rr, tst_rr], upcoming_events['Road'].upcoming_events, 'UpcomingEvents.events[Road]')
    assert_equal(nil, upcoming_events['Mountain Bike'], 'UpcomingEvents.events[Mountain Bike]')
    assert_equal(nil, upcoming_events['Track'], 'UpcomingEvents.events[Track]')
  
    # Tuesday
    upcoming_events = UpcomingEvents.find_all(:date => Date.new(2007, 05, 22))
    assert_equal_events([may_day_rr, lucky_lab_tt, woodland_rr, tst_rr], upcoming_events['Road'].upcoming_events, 'UpcomingEvents.events[Road]')
    assert_equal(nil, upcoming_events['Mountain Bike'], 'UpcomingEvents.events[Mountain Bike]')
    assert_equal(nil, upcoming_events['Track'], 'UpcomingEvents.events[Track]')

    upcoming_events = UpcomingEvents.find_all(:date => DateTime.new(2007, 05, 22, 1, 0, 0))
    assert_equal_events([may_day_rr, lucky_lab_tt, woodland_rr, tst_rr], upcoming_events['Road'].upcoming_events, 'UpcomingEvents.events[Road]')
    assert_equal(nil, upcoming_events['Mountain Bike'], 'UpcomingEvents.events[Mountain Bike]')
    assert_equal(nil, upcoming_events['Track'], 'UpcomingEvents.events[Track]')

    upcoming_events = UpcomingEvents.find_all(:date => DateTime.new(2007, 05, 22, 23, 59, 0))
    assert_equal_events([may_day_rr, lucky_lab_tt, woodland_rr, tst_rr], upcoming_events['Road'].upcoming_events, 'UpcomingEvents.events[Road]')
    assert_equal(nil, upcoming_events['Mountain Bike'], 'UpcomingEvents.events[Mountain Bike]')
    assert_equal(nil, upcoming_events['Track'], 'UpcomingEvents.events[Track]')
  
    # Wednesday
    upcoming_events = UpcomingEvents.find_all(:date => Date.new(2007, 05, 23))
    assert_equal_events([lucky_lab_tt, woodland_rr, tst_rr], upcoming_events['Road'].upcoming_events, 'UpcomingEvents.events[Road]')
    event = upcoming_events['Road'].upcoming_events.first
    assert !event.beginner_friendly?, "beginner_friendly"
    event = upcoming_events['Road'].upcoming_events.last
    assert !event.beginner_friendly?, "beginner_friendly"
    assert_equal(nil, upcoming_events['Mountain Bike'], 'UpcomingEvents.events[Mountain Bike]')
    assert_equal(nil, upcoming_events['Track'], 'UpcomingEvents.events[Track]')

    # Next Sunday
    upcoming_events = UpcomingEvents.find_all(:date => Date.new(2007, 5, 29))
    assert_equal_events([woodland_rr, tst_rr, not_upcoming_rr], upcoming_events['Road'].upcoming_events, 'UpcomingEvents.events[Road]')
    assert_equal_events([chain_breaker], upcoming_events['Mountain Bike'].upcoming_events, 'UpcomingEvents.events[Mountain Bike]')
    event = upcoming_events['Road'].upcoming_events.detect { |e| e.name == "Woodland Road Race" }
    assert_equal("http://obra.org/woodland", event.flyer, "Woodland RR flyer")

    # Next Sunday -- Mountain Bike only
    upcoming_events = UpcomingEvents.find_all(:date => Date.new(2007, 5, 29), :weeks => 2, :discipline => "Mountain Bike")
    assert_equal(nil, upcoming_events['Road'], 'UpcomingEvents.events[Road]')
    assert_equal_events([chain_breaker], upcoming_events['Mountain Bike'].upcoming_events, 'UpcomingEvents.events[Mountain Bike]')

    # Next Monday
    upcoming_events = UpcomingEvents.find_all(:date => Date.new(2007, 05, 30))
    assert_equal_events([woodland_rr, tst_rr, not_upcoming_rr], upcoming_events['Road'].upcoming_events, 'UpcomingEvents.events[Road]')
    assert_equal_events([chain_breaker], upcoming_events['Mountain Bike'].upcoming_events, 'UpcomingEvents.events[Mountain Bike]')

    # Monday after all events
    upcoming_events = UpcomingEvents.find_all(:date => Date.new(2007, 06, 5))
    assert_equal_events([], upcoming_events['Road'].upcoming_events, 'UpcomingEvents.events[Road]')
    assert_equal(nil, upcoming_events['Mountain Bike'], 'UpcomingEvents.events[Mountain Bike]')
  
    # Big range
    upcoming_events = UpcomingEvents.find_all(:date => Date.new(2007, 5, 21), :weeks => 16)
    assert_equal_events([saltzman_hc, may_day_rr, lucky_lab_tt, woodland_rr, tst_rr, not_upcoming_rr], upcoming_events['Road'].upcoming_events, 'UpcomingEvents.events[Road]')
  
    # Small range
    upcoming_events = UpcomingEvents.find_all(:date => DateTime.new(2007, 05, 22), :weeks => 1)
    assert_equal_events([may_day_rr, lucky_lab_tt], upcoming_events['Road'].upcoming_events, 'UpcomingEvents.events[Road]')
  
    # Include ALL events regardless of sanctioned_by
    RacingAssociation.current.show_only_association_sanctioned_races_on_calendar = false
    upcoming_events = UpcomingEvents.find_all(:date => Date.new(2007, 05, 20))
    assert_equal_events([saltzman_hc, may_day_rr, lucky_lab_tt, not_obra, woodland_rr, tst_rr], upcoming_events['Road'].upcoming_events, 'UpcomingEvents.events[Road]')
    
    assert(upcoming_events['Road'].upcoming_events.all? { |e| e.flyer_approved? }, "All events should have approved flyers")
  end
  
  def test_midweek_multiday_event
    FactoryGirl.create(:discipline, :name => "Mountain Bike")
    FactoryGirl.create(:discipline, :name => "Road")
    FactoryGirl.create(:discipline, :name => "Track")

    six_day = MultiDayEvent.create!(
      :date => Date.new(2006, 6, 12), :name => 'Alpenrose Six Day', :discipline => 'Track', :flyer_approved => true
    )
    Date.new(2006, 6, 12).step(Date.new(2006, 6, 17), 1) {|date|
      single_day_six_day = SingleDayEvent.create!(:parent => six_day, :date => date, :name => 'Alpenrose Six Day', :discipline => 'Track', :flyer_approved => true)
      assert(single_day_six_day.valid?, "Six Day valid?")
      assert(!single_day_six_day.new_record?, "Six Day new?")
    }
    six_day.save!
    assert(six_day.valid?, "Six Day valid?")
    assert_equal(6, six_day.children(true).count, 'Six Day events')
    assert_equal_dates(Date.new(2006, 6, 12), six_day.date, 'Six Day date')
    assert_equal_dates(Date.new(2006, 6, 12), six_day.start_date, 'Six Day start date')
    assert_equal_dates(Date.new(2006, 6, 17), six_day.end_date, 'Six Day end date')
    
    # Way, wayback
    upcoming_events = UpcomingEvents.find_all(:date => Date.new(2006, 1, 1))
    assert_equal(nil, upcoming_events['Road'], 'UpcomingEvents.events[Road]')
    assert_equal(nil, upcoming_events['Mountain Bike'], 'UpcomingEvents.events[Mountain Bike]')
    assert_equal(nil, upcoming_events['Track'], 'UpcomingEvents.events[Track]')
    
    # Wayback
    upcoming_events = UpcomingEvents.find_all(:date => Date.new(2006, 5, 28))
    assert_equal(nil, upcoming_events['Road'], 'UpcomingEvents.events[Road]')
    assert_equal(nil, upcoming_events['Mountain Bike'], 'UpcomingEvents.events[Mountain Bike]')
    assert_equal(nil, upcoming_events['Track'], 'UpcomingEvents.events[Track]')
    
    # Monday
    upcoming_events = UpcomingEvents.find_all(:date => Date.new(2006, 05, 29))
    assert_equal(nil, upcoming_events['Road'], 'UpcomingEvents.events[Road]')
    assert_equal(nil, upcoming_events['Mountain Bike'], 'UpcomingEvents.events[Mountain Bike]')
    assert_equal(nil, upcoming_events['Track'], 'UpcomingEvents.events[Track]')
    
    # Tuesday
    upcoming_events = UpcomingEvents.find_all(:date => Date.new(2006, 05, 30))
    assert_equal(nil, upcoming_events['Track'], 'UpcomingEvents.events[Track]')
    
    upcoming_events = UpcomingEvents.find_all(:date => Date.new(2006, 06, 2))
    assert_equal(nil, upcoming_events['Track'], 'UpcomingEvents.events[Track]')
    
    upcoming_events = UpcomingEvents.find_all(:date => Date.new(2006, 6, 3))
    assert_equal_enumerables([six_day], upcoming_events["Track"].upcoming_events, 'UpcomingEvents.events[Track]')
    assert(upcoming_events['Track'].upcoming_events.all? { |e| e.flyer_approved? }, "All events should have approved flyers")
    
    # Saturday
    upcoming_events = UpcomingEvents.find_all(:date => Date.new(2006, 6, 16))
    assert_equal([six_day], upcoming_events["Track"].upcoming_events, 'UpcomingEvents.events[Track]')
    
    # Sunday
    upcoming_events = UpcomingEvents.find_all(:date => Date.new(2006, 6, 17))
    assert_equal_events([six_day], upcoming_events["Track"].upcoming_events, 'UpcomingEvents.events[Track]')

    # Next Monday
    upcoming_events = UpcomingEvents.find_all(:date => Date.new(2006, 6, 18))
    assert_equal(nil, upcoming_events['Track'], 'UpcomingEvents.events[Track]')
  end

  def test_cutoff_date
    upcoming_events = UpcomingEvents::Base.new(Date.new(2008, 5, 24), 2, nil)
    assert_equal_dates(Date.new(2008, 6, 8), upcoming_events.cutoff_date, 'Cutoff date')

    upcoming_events = UpcomingEvents::Base.new(Date.new(2008, 5, 25), 2, nil)
    assert_equal_dates(Date.new(2008, 6, 8), upcoming_events.cutoff_date, 'Cutoff date')

    upcoming_events = UpcomingEvents::Base.new(Date.new(2008, 5, 26), 2, nil)
    assert_equal_dates(Date.new(2008, 6, 8), upcoming_events.cutoff_date, 'Cutoff date')

    upcoming_events = UpcomingEvents::Base.new(Date.new(2008, 5, 27), 2, nil)
    assert_equal_dates(Date.new(2008, 6, 8), upcoming_events.cutoff_date, 'Cutoff date')

    upcoming_events = UpcomingEvents::Base.new(Date.new(2008, 5, 28), 2, nil)
    assert_equal_dates(Date.new(2008, 6, 8), upcoming_events.cutoff_date, 'Cutoff date')

    upcoming_events = UpcomingEvents::Base.new(Date.new(2008, 5, 29), 2, nil)
    assert_equal_dates(Date.new(2008, 6, 8), upcoming_events.cutoff_date, 'Cutoff date')

    upcoming_events = UpcomingEvents::Base.new(Date.new(2008, 5, 30), 2, nil)
    assert_equal_dates(Date.new(2008, 6, 8), upcoming_events.cutoff_date, 'Cutoff date')

    upcoming_events = UpcomingEvents::Base.new(Date.new(2008, 5, 31), 2, nil)
    assert_equal_dates(Date.new(2008, 6, 15), upcoming_events.cutoff_date, 'Cutoff date')

    upcoming_events = UpcomingEvents::Base.new(Date.new(2008, 6, 1), 2, nil)
    assert_equal_dates(Date.new(2008, 6, 15), upcoming_events.cutoff_date, 'Cutoff date')

    upcoming_events = UpcomingEvents::Base.new(Date.new(2008, 6, 2), 2, nil)
    assert_equal_dates(Date.new(2008, 6, 15), upcoming_events.cutoff_date, 'Cutoff date')

    upcoming_events = UpcomingEvents::Base.new(Date.new(2008, 6, 1), 2, nil)
    assert_equal_dates(Date.new(2008, 6, 15), upcoming_events.cutoff_date, 'Cutoff date')

    upcoming_events = UpcomingEvents::Base.new(Date.new(2008, 12, 31), 2, nil)
    assert_equal_dates(Date.new(2009, 1, 11), upcoming_events.cutoff_date, 'Cutoff date')

    upcoming_events = UpcomingEvents::Base.new(Date.new(2008, 5, 24), 1, nil)
    assert_equal_dates(Date.new(2008, 6, 1), upcoming_events.cutoff_date, 'Cutoff date')

    upcoming_events = UpcomingEvents::Base.new(Date.new(2008, 12, 31), 52, nil)
    assert_equal_dates(Date.new(2009, 12, 27), upcoming_events.cutoff_date, 'Cutoff date')
  end
  
  def test_dates
    upcoming_events = UpcomingEvents::Base.new(Date.new(2008, 5, 24), 2, nil)
    assert_equal_dates(Date.new(2008, 5, 24), upcoming_events.dates.begin, "Dates.begin")
    assert_equal_dates(Date.new(2008, 6, 8), upcoming_events.dates.end, "Dates.end")

    upcoming_events = UpcomingEvents::Base.new(Date.new(2008, 12, 31), 2, nil)
    assert_equal_dates(Date.new(2008, 12, 31), upcoming_events.dates.begin, "Dates.begin")
    assert_equal_dates(Date.new(2009, 1, 11), upcoming_events.dates.end, "Dates.end")
  end
  
  def test_weekly_series
    FactoryGirl.create(:discipline, :name => "Mountain Bike")
    FactoryGirl.create(:discipline, :name => "Road")
    FactoryGirl.create(:discipline, :name => "Track")

    six_day = WeeklySeries.create!(
      :date => Date.new(1999, 6, 8), :name => 'Alpenrose Six Day', :discipline => 'Track', :flyer_approved => true
    )
    Date.new(1999, 6, 8).step(Date.new(1999, 7, 27), 7) {|date|
      single_day_six_day = SingleDayEvent.create!(:parent => six_day, :date => date, :name => 'Alpenrose Six Day', :discipline => 'Track', :flyer_approved => true)
      assert(single_day_six_day.valid?, "Six Day valid?")
      assert(!single_day_six_day.new_record?, "Six Day new?")
    }
    six_day.save!
    assert(six_day.valid?, "Six Day valid?")
    assert_equal(8, six_day.children(true).count, 'Six Day events')
    assert_equal_dates(Date.new(1999, 6, 8), six_day.date, 'Six Day date')
    assert_equal_dates(Date.new(1999, 6, 8), six_day.start_date, 'Six Day start date')
    assert_equal_dates(Date.new(1999, 7, 27), six_day.end_date, 'Six Day end date')
    
    # Way, wayback
    upcoming_events = UpcomingEvents.find_all(:date => Date.new(1999, 1, 1))
    assert_equal(nil, upcoming_events['Road'], 'UpcomingEvents.events[Road]')
    assert_equal(nil, upcoming_events['Mountain Bike'], 'UpcomingEvents.events[Mountain Bike]')
    assert_equal(nil, upcoming_events['Track'], 'UpcomingEvents.events[Track]')
    
    # Wayback
    upcoming_events = UpcomingEvents.find_all(:date => Date.new(1999, 5, 24))
    assert_equal(nil, upcoming_events['Road'], 'UpcomingEvents.events[Road]')
    assert_equal(nil, upcoming_events['Mountain Bike'], 'UpcomingEvents.events[Mountain Bike]')
    assert_equal(nil, upcoming_events['Track'], 'UpcomingEvents.events[Track]')
    
    # Monday
    upcoming_events = UpcomingEvents.find_all(:date => Date.new(1999, 05, 25))
    assert_equal(nil, upcoming_events['Road'], 'UpcomingEvents.events[Road]')
    assert_equal(nil, upcoming_events['Mountain Bike'], 'UpcomingEvents.events[Mountain Bike]')
    assert_equal(nil, upcoming_events['Track'], 'UpcomingEvents.events[Track]')
    
    # Tuesday
    upcoming_events = UpcomingEvents.find_all(:date => Date.new(1999, 6, 7))
    assert_equal_enumerables([], upcoming_events["Track"].upcoming_events, 'UpcomingEvents.events[Track]')
    assert_equal_enumerables([six_day], upcoming_events["Track"].upcoming_weekly_series, 'UpcomingEvents.events[Track]')
    assert(upcoming_events['Track'].upcoming_weekly_series.all? { |e| e.flyer_approved? }, "All events should have approved flyers")
    
    # Saturday
    upcoming_events = UpcomingEvents.find_all(:date => Date.new(1999, 5, 29))
    assert_equal_enumerables([], upcoming_events["Track"].upcoming_events, 'UpcomingEvents.events[Track]')
    assert_equal([six_day], upcoming_events["Track"].upcoming_weekly_series, 'UpcomingEvents.events[Track]')
    
    # Sunday
    upcoming_events = UpcomingEvents.find_all(:date => Date.new(1999, 5, 30))
    assert_equal([], upcoming_events["Track"].upcoming_events, 'UpcomingEvents.events[Track]')
    assert_equal_enumerables([six_day], upcoming_events["Track"].upcoming_weekly_series, 'UpcomingEvents.events[Track]')

    # Afterward
    upcoming_events = UpcomingEvents.find_all(:date => Date.new(1999, 7, 28))
    assert_equal(nil, upcoming_events['Track'], 'UpcomingEvents.events[Track]')
  end
  
  def test_series
    FactoryGirl.create(:discipline, :name => "Mountain Bike")
    FactoryGirl.create(:discipline, :name => "Road")
    FactoryGirl.create(:discipline, :name => "Time Trial")

    estacada_tt = Series.create!(
      :date => Date.new(1999, 6, 8), :name => 'Estacada', :discipline => 'Time Trial', :flyer_approved => true
    )
    
    estacada_tt_1 = estacada_tt.children.create!(:date => Date.new(1999, 6, 8), :name => 'Estacada', :discipline => 'Time Trial', :flyer_approved => true)
    assert(estacada_tt_1.valid?, "estacada_tt_1 valid?")
    
    estacada_tt_2 = estacada_tt.children.create!(:date => Date.new(1999, 6, 22), :name => 'Estacada', :discipline => 'Time Trial', :flyer_approved => true)
    assert(estacada_tt_2.valid?, "estacada_tt_2 valid?")
    
    estacada_tt_3 = estacada_tt.children.create!(:date => Date.new(1999, 6, 24), :name => 'Estacada', :discipline => 'Time Trial', :flyer_approved => true)
    assert(estacada_tt_3.valid?, "estacada_tt_3 valid?")
    
    assert_equal(3, estacada_tt.children(true).size, 'estacada_tt events')
    assert_equal_dates(Date.new(1999, 6, 8), estacada_tt.date, 'estacada_tt date')
    assert_equal_dates(Date.new(1999, 6, 8), estacada_tt.start_date, 'estacada_tt start date')
    assert_equal_dates(Date.new(1999, 6, 24), estacada_tt.end_date, 'estacada_tt end date')

    # Way, wayback
    upcoming_events = UpcomingEvents.find_all(:date => Date.new(1999, 1, 1))
    assert_equal(nil, upcoming_events['Road'], 'UpcomingEvents.events[Road]')
    assert_equal(nil, upcoming_events['Mountain Bike'], 'UpcomingEvents.events[Mountain Bike]')
    assert_equal(nil, upcoming_events['Track'], 'UpcomingEvents.events[Track]')

    upcoming_events = UpcomingEvents.find_all(:date => Date.new(1999, 6, 7))
    assert_equal_enumerables([estacada_tt_1], upcoming_events["Road"].upcoming_events, 'UpcomingEvents.events[Road]')
    assert(upcoming_events['Road'].upcoming_events.all? { |e| e.flyer_approved? }, "All events should have approved flyers")
    assert_equal_enumerables([], upcoming_events['Road'].upcoming_weekly_series, 'UpcomingEvents.events[Road]')

    upcoming_events = UpcomingEvents.find_all(:date => Date.new(1999, 6, 20))
    assert_equal_enumerables([estacada_tt_2, estacada_tt_3], upcoming_events["Road"].upcoming_events, 'UpcomingEvents.events[Road]')
    assert_equal_enumerables([], upcoming_events['Road'].upcoming_weekly_series, 'UpcomingEvents.events[Road]')
  end
  
  def test_downhill_events
    FactoryGirl.create(:discipline, :name => "Mountain Bike")    
    FactoryGirl.create(:discipline, :name => "Short Track")    
    FactoryGirl.create(:discipline, :name => "Downhill")    
    FactoryGirl.create(:discipline, :name => "Road")
    FactoryGirl.create(:discipline, :name => "Track")

    super_d = SingleDayEvent.create!(
      :date => Date.new(2007, 5, 27), 
      :name => 'Super D', 
      :discipline => 'Downhill', 
      :flyer_approved => true,
      :beginner_friendly => true
    )

    short_track = SingleDayEvent.create!(
      :date => Date.new(2007, 5, 27), 
      :name => 'Short Track', 
      :discipline => 'Short Track', 
      :flyer_approved => true,
      :beginner_friendly => true
    )

    upcoming_events = UpcomingEvents.find_all(:date => Date.new(2007, 05, 26))
    assert_nil(upcoming_events['Road'], 'UpcomingEvents.events[Road]')
    assert_equal_events([super_d, short_track], upcoming_events['Mountain Bike'].upcoming_events, 'UpcomingEvents.events[Mountain Bike]')
    event = upcoming_events['Mountain Bike'].upcoming_events.first
    assert event.beginner_friendly?, "beginner_friendly"
  end
  
  def test_disciplines
    FactoryGirl.create(:discipline, :name => "Downhill")
    FactoryGirl.create(:discipline, :name => "Mountain Bike")
    FactoryGirl.create(:discipline, :name => "Road")
    FactoryGirl.create(:discipline, :name => "Track")
    
    FactoryGirl.create(:event)

    upcoming_events = UpcomingEvents.find_all(:date => Date.new(1990, 6, 7))
    assert(upcoming_events.disciplines.empty?, "Disciplines")
    
    upcoming_events = UpcomingEvents.find_all
    assert_equal([Discipline[:road]], upcoming_events.disciplines, "Disciplines")    
    
    SingleDayEvent.create!(:discipline => "Downhill", :date => Time.zone.today.advance(:days => 1))
    upcoming_events = UpcomingEvents.find_all
    assert_equal([Discipline[:road], Discipline[:mountain_bike]], upcoming_events.disciplines, "Disciplines")    
    
    SingleDayEvent.create!(:discipline => "Track", :date => Time.zone.today.advance(:days => 4))
    upcoming_events = UpcomingEvents.find_all(:discipline => "track")
    assert_equal([Discipline[:track]], upcoming_events.disciplines, "Disciplines")    
  end
  
  def test_empty
    FactoryGirl.create(:discipline, :name => "Road")
    FactoryGirl.create(:event)

    upcoming_events = UpcomingEvents.find_all(:date => Date.new(1990, 6, 7))
    assert upcoming_events.empty?, "No events in 1990"

    upcoming_events = UpcomingEvents.find_all
    assert !upcoming_events.empty?, "Events this year"
  end
end
