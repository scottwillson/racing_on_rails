require File.expand_path("../../../test_helper", __FILE__)

# :stopdoc:
class UpcomingTest < ActiveSupport::TestCase
  def test_different_dates
    FactoryGirl.create(:discipline, :name => "Mountain Bike")
    FactoryGirl.create(:discipline, :name => "Road")
    FactoryGirl.create(:discipline, :name => "Time Trial")
    FactoryGirl.create(:discipline, :name => "Track")

    RacingAssociation.current.show_only_association_sanctioned_races_on_calendar = true
    
    # Tuesday
    may_day_rr =      SingleDayEvent.create!(:date => Date.new(2007, 5, 22), :name => 'May Day Road Race')
    WeeklySeries.create_for_every!("Tuesday",
      :start_date => Date.new(2007, 4), :end_date => Date.new(2007, 7), :name => 'Brian Abers Training', :practice => true
    )
    # Wednesday
    lucky_lab_tt =    SingleDayEvent.create!(:date => Date.new(2007, 5, 23), :name => 'Lucky Lab Road Race')
    not_obra =        SingleDayEvent.create!(:date => Date.new(2007, 5, 23), :name => 'USA RR', :sanctioned_by => 'USA Cycling')

    # Sunday of next full week
    woodland_rr =     SingleDayEvent.create!(:date => Date.new(2007, 6, 3), :name => 'Woodland Road Race')
    tst_rr =          SingleDayEvent.create!(:date => Date.new(2007, 6, 3), :name => 'Tahuya-Seabeck-Tahuya')
    # Monday after that
    not_upcoming_rr = SingleDayEvent.create!(:date => Date.new(2007, 6, 4), :name => 'Not Upcoming Road Race')
    # Monday before all other races (to test ordering)
    saltzman_hc =     SingleDayEvent.create!(:date => Date.new(2007, 5, 21), :name => 'Saltzman Hillclimb')
  
    SingleDayEvent.create!(:date => Date.new(2007, 5, 21), :name => 'Cancelled', :cancelled => true)
  
    # Weekly Series
    pir = WeeklySeries.create!(:date => Date.new(2007, 4, 3), :name => 'Tuesday PIR')
    Date.new(2007, 4, 3).step(Date.new(2007, 10, 23), 7) do |date|
      pir.children.create! :date => date, :name => "Tue PIR #{date}"
    end
    pirs = pir.children.sort_by(&:date)
  
    # Way, wayback
    Timecop.freeze(Time.zone.local(2005)) do
      assert Event.upcoming.empty?, "No events in 2005"
    end
  
    # Wayback
    Timecop.freeze(Time.zone.local(2007, 3, 20)) do
      assert_equal_events [ pirs.first ], Event.upcoming
    end
  
    # Sunday
    Timecop.freeze(Time.zone.local(2007, 5, 20)) do
      assert_equal_events(
        [ saltzman_hc, may_day_rr, lucky_lab_tt, woodland_rr, tst_rr ] + pirs[7, 2],
        Event.upcoming
      )
    end

    # Monday after all events
    Timecop.freeze(Time.zone.local(2007, 10, 24)) do
      assert_equal_events([], Event.upcoming)
    end
  
    # Big range
    Timecop.freeze(Time.zone.local(2007, 5, 21)) do
      assert_equal_events([saltzman_hc, may_day_rr, lucky_lab_tt, woodland_rr, tst_rr, not_upcoming_rr] + pirs[7, 16], Event.upcoming(16))
    end
  
    # Small range
    Timecop.freeze(Time.zone.local(2007, 5, 22)) do
      assert_equal_events([may_day_rr, lucky_lab_tt] + pirs[7, 2], Event.upcoming(1))
    end
  
    # Include ALL events regardless of sanctioned_by
    RacingAssociation.current.show_only_association_sanctioned_races_on_calendar = false
    Timecop.freeze(Time.zone.local(2007, 5, 20)) do
      assert_equal_events([saltzman_hc, may_day_rr, lucky_lab_tt, not_obra, woodland_rr, tst_rr] + pirs[7, 2], Event.upcoming(2))
    end
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

    Timecop.freeze(Time.zone.local(2006, 5, 28)) do
      assert_equal_events [], Event.upcoming
    end

    Timecop.freeze(Time.zone.local(2006, 6, 3)) do
      assert_equal_events [six_day], Event.upcoming
    end
    
    Timecop.freeze(Time.zone.local(2006, 6, 16)) do
      assert_equal_events [six_day], Event.upcoming
    end

    Timecop.freeze(Time.zone.local(2006, 6, 17)) do
      assert_equal_events [six_day], Event.upcoming
    end

    Timecop.freeze(Time.zone.local(2006, 6, 18)) do
      assert_equal_events [], Event.upcoming
    end
  end
  
  def test_weekly_series
    FactoryGirl.create(:discipline, :name => "Road")

    series = WeeklySeries.create!(
      :date => Date.new(1999, 6, 8), :name => 'PIR'
    )

    Date.new(1999, 6, 8).step(Date.new(1999, 7, 27), 7) {|date|
      SingleDayEvent.create!(:parent => series, :date => date, :name => "PIR #{date}")
    }

    series.reload
    assert_equal(8, series.children(true).count, 'Series events')
    assert_equal_dates(Date.new(1999, 6, 8), series.date, 'Series date')
    assert_equal_dates(Date.new(1999, 6, 8), series.start_date, 'Series start date')
    assert_equal_dates(Date.new(1999, 7, 27), series.end_date, 'Series end date')
    
    # Before
    Timecop.freeze(Time.zone.local(1999, 5, 24)) do
      assert_equal_events [], Event.upcoming
    end
    
    # Monday
    Timecop.freeze(Time.zone.local(1999, 5, 25)) do
      assert_equal_events [series.children[0]], Event.upcoming
    end
    
    # Tuesday
    Timecop.freeze(Time.zone.local(1999, 6, 7)) do
      assert_equal_events series.children[0, 2], Event.upcoming
    end
    
    # End
    Timecop.freeze(Time.zone.local(1999, 7, 27)) do
      assert_equal_events series.children[7, 1], Event.upcoming
    end

    # Afterward
    Timecop.freeze(Time.zone.local(1999, 7, 28)) do
      assert_equal_events [], Event.upcoming
    end
  end
  
  def test_series
    FactoryGirl.create(:discipline, :name => "Road")

    estacada_tt = Series.create!(
      :date => Date.new(1999, 6, 8), :name => 'Estacada'
    )
    
    estacada_tt_1 = estacada_tt.children.create!(:date => Date.new(1999, 6, 8), :name => 'Estacada 1')
    estacada_tt_2 = estacada_tt.children.create!(:date => Date.new(1999, 6, 22), :name => 'Estacada 2')
    estacada_tt_3 = estacada_tt.children.create!(:date => Date.new(1999, 6, 24), :name => 'Estacada 3')
    
    assert_equal(3, estacada_tt.children(true).size, 'estacada_tt events')
    assert_equal_dates(Date.new(1999, 6, 8), estacada_tt.date, 'estacada_tt date')
    assert_equal_dates(Date.new(1999, 6, 8), estacada_tt.start_date, 'estacada_tt start date')
    assert_equal_dates(Date.new(1999, 6, 24), estacada_tt.end_date, 'estacada_tt end date')

    Timecop.freeze(Time.zone.local(1999, 1, 1)) do
      assert_equal_events [], Event.upcoming
    end

    Timecop.freeze(Time.zone.local(1999, 6, 7)) do
      assert_equal_events [estacada_tt_1], Event.upcoming
    end

    Timecop.freeze(Time.zone.local(1999, 6, 20)) do
      assert_equal_events [estacada_tt_2, estacada_tt_3], Event.upcoming
    end
  end
end
