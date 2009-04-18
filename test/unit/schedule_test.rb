require "test_helper"

# TODO Handle multiple emails per promoters
# TODO Recognize Series and WeeklySeries

class ScheduleTest < ActiveSupport::TestCase
  def setup
    # Remove existing promoters that may conflict
    Promoter.delete_all
  end
  
  def test_create
    piece_of_cake = SingleDayEvent.new({
      :name => "Piece of Cake Road Event",
      :city => "Shedds",
      :date => Date.new(2007, 3, 17,
      :id => 4456)
    })
    
    kings_valley = SingleDayEvent.new({
      :name => "Kings Valley Road Event",
      :city => "Kings Valley",
      :date => Date.new(2007, 3, 6,
      :id => 4456)
    })
    
    state_crit = SingleDayEvent.new({
      :name => "State Championship Criterium",
      :city => "gresham",
      :date => Date.new(2007, 3, 17,
      :id => 4456)
    })
    
    events = [piece_of_cake, kings_valley, state_crit]
    
    schedule = Schedule::Schedule.new(2007, events)
    assert_equal(12, schedule.months.size, "Number of months")
    jan = schedule.months[0]
    assert_equal("January", jan.name)
    assert_equal(5, jan.weeks.size, 'January 2007 weeks')
    march = schedule.months[2]
    assert_equal("March", march.name)
    
    assert_equal(5, march.weeks.size, "March number of weeks")
    first_week_of_march = march.weeks[0]
    day = first_week_of_march.days[0]
    assert(day.other_month?, "#{day} of #{first_week_of_march} is previous month")
    assert_equal(25, day.day_of_month, "1st day of 1st week of March 2007")
    assert_equal(0, day.events.size, "1st day of 1st week of March 2007 events")
    
    third_week_of_march = march.weeks[2]
    day = third_week_of_march.days[6]
    assert(!day.other_month?, "#{day} of #{third_week_of_march}, #{day.month} is not other month")
    assert_equal(17, day.day_of_month, "Last day of 3rd week of March 2007")
    # Existing event
    assert_equal(2, day.events.size, "Last day of 3rd week of March 2007 events")
    event = day.events[0]
    assert_equal(piece_of_cake, event, "Last day of 3rd week of March 2007 event")
  end
  
  def test_import_excel
    event_before = SingleDayEvent.create(:name => 'Before Schedule Start', :date => Date.new(2006, 1, 19))
    event_on = SingleDayEvent.create(:name => 'On Schedule Start', :date => Date.new(2006, 1, 20))
    event_after = SingleDayEvent.create(:name => 'After Schedule Start', :date => Date.new(2006, 1, 21))
    
    before_import_after_schedule_start_date = Event.count(:conditions => "date >= '2006-01-20'")
    assert_equal(6, before_import_after_schedule_start_date, "events after 2006 count before import")
    before_import_all = Event.count
    assert_equal(22, before_import_all, "All events count before import")
    
    filename = File.expand_path(File.dirname(__FILE__) + "/../fixtures/schedule.xls")
    Schedule::Schedule.import(filename)
        
    expected = {
      "12 Mile Endurance DH"           => 1,
      "12/24 Hr MTN"                   => 1,
      "Banana Belt Road Race Series"   => 3,
      "Beaverton Grand Prix"           => 1,
      "Cascade Cream Puff MTB"         => 1,
      "CCX Race"                       => 1,
      "Cherry Pie Road Race"           => 1,
      "Collegiate Track Nationals"     => 5,
      "Columbia Plateau Stage Race"    => 3,
      "CoMotion Criterium"             => 1,
      "CoMotion Tandem Stage Race"     => 5,
      "Crawfish Criterium"             => 1,
      "Criterium Championships"        => 1,
      "Cross Crusade"                  => 8,
      "Fast Twitch Fridays"            => 16,
      "Healthnet Criterium"            => 1,
      "High Desert Omnium"             => 3,
      "Hood River CCX"                 => 1,
      "Jack Frost Time Trial"          => 1,
      "LA World Cup"                   => 3,
      "Track Development Class"        => 16,
      "Vancouver Courthouse Criterium" => 1,
      "Veloshop CCX"                   => 1
    }
    assert_equal(76, expected.inject(0) { |sum, e| sum + e.last }, "New events")
    
    after_import_after_schedule_start_date = Event.count(:conditions => "date >= '2006-01-20'")
    assert_equal(77, after_import_after_schedule_start_date, "2006 events count after import")
    after_import_all = Event.count
    assert_equal(93, after_import_all, "All events count after import")
    
    assert(SingleDayEvent.exists?(event_before.id), 'Event before schedule start')
    assert(!SingleDayEvent.exists?(event_on.id), 'Event on schedule start')
    assert(!SingleDayEvent.exists?(event_after.id), 'Event after schedule start')

    cream_puff = nil
    fast_twitch_fridays = []
    la_world_cup = nil
    road_nationals = nil
    for event in Event.find(:all, :conditions => 'date >= 2005-01-01')
      assert_not_nil(event.date, "#{event.name} date")
      if event.name == "Cascade Cream Puff MTB"
        cream_puff = event
      elsif event.name == "Jack Frost Time Trial"
        jack_frost = event
      elsif event.name =~ /^LA World Cup/
        la_world_cup = event
      elsif event.name =~ /^Collegiate Track Nationals/
        road_nationals = event
      end
    end
    
    fast_twitch_series = WeeklySeries.find_by_name("Fast Twitch Fridays")
    assert(fast_twitch_series.instance_of?(WeeklySeries), "Fast Twitch Fridays should be WeeklySeries")
    assert_not_nil(fast_twitch_series, "Should have imported Fast Twitch Fridays series")
    assert_equal(15, fast_twitch_series.children.size, "Number of Fast Twitch Fridays events")
    assert_equal_dates("2006-05-12", fast_twitch_series.start_date, "Fast Twitch start date")
    assert_equal_dates("2006-08-25", fast_twitch_series.end_date, "Fast Twitch end date")
    assert_equal(fast_twitch_series.start_date, fast_twitch_series.date, "Fast Twitch start date and date")
    sql_results = fast_twitch_series.connection.select_one("select date from events where id=#{fast_twitch_series.id}")
    assert_equal("2006-05-12", sql_results["date"], "Fast Twitch start date and date column from DB")

    assert_not_nil(cream_puff, "Should have imported Cream Puff")
    assert(cream_puff.instance_of?(SingleDayEvent), "Cream Puff should be SingleDayEvent")
    assert_equal(0, cream_puff.date.wday, "Cream Puff day of week")
    assert_equal("Oakridge", cream_puff.city, "Cream Puff city")
    assert_equal(ASSOCIATION.state, cream_puff.state, "Cream Puff state")
    assert_equal("Mountain Bike", cream_puff.discipline, "Cream Puff discipline")
    assert_equal_dates(Date.today, cream_puff.updated_at, "Cream Puff updated_at")
    assert_equal_dates("2006-06-25", cream_puff.date, "Cream Puff date")
    assert(cream_puff.instance_of?(SingleDayEvent), "Cream Puff class")
    assert_not_nil(cream_puff.promoter, "Cream Puff promoter")
    assert_equal("Don Person", cream_puff.promoter.name, "Cream Puff promoter name")
    assert_equal("541-935-4996", cream_puff.promoter.phone, "Cream Puff promoter phone")
    assert_equal("don@mtbtires.com", cream_puff.promoter.email, "Cream Puff promoter email")
    assert_equal(ASSOCIATION.short_name, cream_puff.sanctioned_by, "Cream Puff sanctioned_by")
    
    for event in fast_twitch_series.children
      assert_not_nil(event, "Should have imported Fast Twitch Fridays")
      assert_equal("Portland", event.city, "Fast Twitch Fridays city")
      assert_equal(ASSOCIATION.state, event.state, "Fast Twitch Fridays state")
      assert_equal("Track", event.discipline, "Fast Twitch Fridays discipline")
      assert_equal_dates(Date.today, event.updated_at, "Fast Twitch Fridays lastUpdated")
      assert_equal(5, event.date.wday, "Fast Twitch Fridays day of week")
      assert(event.instance_of?(SingleDayEvent), "Fast Twitch Fridays Puff class")
      assert_equal(event.promoter, fast_twitch_series.promoter, "Fast Twitch Fridays promoter")
      assert_equal("Jen Featheringill", event.promoter.name, "Fast Twitch Fridays promoter name")
      assert_equal("503-227-4439", event.promoter.phone, "Fast Twitch Fridays promoter name")
      assert_equal("bike-central@bike-central.com", event.promoter.email, "Fast Twitch Fridays promoter name")
      assert_equal(ASSOCIATION.short_name, event.sanctioned_by, "Fast Twitch sanctioned_by")
      assert_equal(fast_twitch_series, event.parent, "Fast Twitch Fridays parent")
    end
    assert_equal(1, Promoter.count(:conditions => "name = 'Jen Featheringill'"), "Jen Featheringill should only be listed once in promoters")
    
    assert_not_nil(jack_frost, "Should have imported Jack Frost")
    assert_equal("Vancouver", jack_frost.city, "Jack Frost city")
    assert_equal("WA", jack_frost.state, "Jack Frost state")

    assert_equal("UCI", la_world_cup.sanctioned_by, "LA World Cup sanctioned_by")
    assert_equal("USA Cycling", road_nationals.sanctioned_by, "Collegiate Nats sanctioned_by")

    assert_not_nil(la_world_cup.parent, "LA World Cup parent event")
    assert(la_world_cup.parent.instance_of?(MultiDayEvent), "LA World Cup should be MultiDayEvent")
    assert(!la_world_cup.parent.instance_of?(Series), "Fast LA World Cup should not be Series")
    assert(!la_world_cup.parent.instance_of?(WeeklySeries), "LA World Cup should not be WeeklySeries")

    banana_belt_series = Series.find_by_name("Banana Belt Series")
    assert(banana_belt_series.instance_of?(Series), "Banana Belt Series should be Series")
    assert(!banana_belt_series.instance_of?(MultiDayEvent), "Fast Banana Belt Series should not be MultiDayEvent")
    assert(!banana_belt_series.instance_of?(WeeklySeries), "Banana Belt Series should not be WeeklySeries")
    
    event = Event.find_by_name("12 Mile Endurance DH")
    promoter = event.promoter
    assert_not_nil(promoter, "Promoter should not be nil")
    assert_equal("Tita Soriano", promoter.name, "promoter name")
    assert_equal("541-840-6580", promoter.phone, "promoter phone")
    assert_equal("tita@3amevents.net", promoter.email, "promoter email")
    
    event = Event.find_by_name("12/24 Hr MTN")
    promoter = event.promoter
    assert_not_nil(promoter, "Promoter should not be nil")
    assert_equal("Randy Dreiling", promoter.name, "promoter name")
    assert_equal("541-968-5397", promoter.phone, "promoter phone")
    assert_equal("raggy23@yahoo.com", promoter.email, "promoter email")
    
    event = Event.find_by_name("Banana Belt Road Race Series")
    promoter = event.promoter
    assert_not_nil(promoter, "Promoter should not be nil")
    assert_equal("Jeff Mitchem", promoter.name, "promoter name")
    assert_equal("503-233-3636", promoter.phone, "promoter phone")
    assert_equal("JMitchem@ffadesign.com", promoter.email, "promoter email")
    
    event = Event.find_by_name("Beaverton Grand Prix")
    promoter = event.promoter
    assert_not_nil(promoter, "Promoter should not be nil")
    assert_equal("Dave Levy", promoter.name, "promoter name")
    assert_equal("503-621-9670", promoter.phone, "promoter phone")
    assert_equal("titaniumdave@msn.com", promoter.email, "promoter email")
    
    event = Event.find_by_name("Cascade Cream Puff MTB")
    promoter = event.promoter
    assert_not_nil(promoter, "Promoter should not be nil")
    assert_equal("Don Person", promoter.name, "promoter name")
    assert_equal("541-935-4996", promoter.phone, "promoter phone")
    assert_equal("don@mtbtires.com", promoter.email, "promoter email")
    
    event = Event.find_by_name("CCX Race")
    promoter = event.promoter
    assert_not_nil(promoter, "Promoter should not be nil")
    assert_equal("Kris Schamp", promoter.name, "promoter name")
    assert_equal("503-446-9007", promoter.phone, "promoter phone")
    assert_equal("kris@portlandracing.com", promoter.email, "promoter email")
    
    event = Event.find_by_name("Cherry Pie Road Race")
    promoter = event.promoter
    assert_not_nil(promoter, "Promoter should not be nil")
    assert_equal("Norman Babcock", promoter.name, "promoter name")
    assert_equal("541 520-3717", promoter.phone, "promoter phone")
    assert_equal("2dogracing@comcast.net", promoter.email, "promoter email")
    
    event = Event.find_by_name("Collegiate Track Nationals")
    promoter = event.promoter
    assert_nil(promoter, "Promoter should be nil")
    
    event = Event.find_by_name("Columbia Plateau Stage Race")
    promoter = event.promoter
    assert_not_nil(promoter, "Promoter should not be nil")
    assert_equal("Mark Schwyhart", promoter.name, "promoter name")
    assert_equal("503-231-0236", promoter.phone, "promoter phone")
    assert_equal("columbiaplateau@comcast.net", promoter.email, "promoter email")
    
    event = Event.find_by_name("CoMotion Criterium")
    promoter = event.promoter
    assert_not_nil(promoter, "Promoter should not be nil")
    assert_equal("Sal Collura", promoter.name, "promoter name")
    assert_equal("541-747-3336", promoter.phone, "promoter phone")
    assert_equal("salcollura@hotmail.com", promoter.email, "promoter email")
    
    event = Event.find_by_name("CoMotion Tandem Stage Race")
    promoter = event.promoter
    assert_not_nil(promoter, "Promoter should not be nil")
    assert_equal("Sal Collura", promoter.name, "promoter name")
    assert_equal("541-747-3336", promoter.phone, "promoter phone")
    assert_equal("salcollura@hotmail.com", promoter.email, "promoter email")
    
    event = Event.find_by_name("Crawfish Criterium")
    promoter = event.promoter
    assert_not_nil(promoter, "Promoter should not be nil")
    assert_equal("Shari Matyus", promoter.name, "promoter name")
    assert_equal("503-223-4984", promoter.phone, "promoter phone")
    assert_equal("sharim@premier-press.com", promoter.email, "promoter email")
    
    event = Event.find_by_name("Criterium Championships")
    promoter = event.promoter
    assert_not_nil(promoter, "Promoter should not be nil")
    assert_equal("Jay Martineau", promoter.name, "promoter name")
    assert_equal("360-281-0085", promoter.phone, "promoter phone")
    assert_equal("jaymartineau@covad.net_", promoter.email, "promoter email")
    
    event = Event.find_by_name("Cross Crusade")
    promoter = event.promoter
    assert_not_nil(promoter, "Promoter should not be nil")
    assert_equal("Brad Ross", promoter.name, "promoter name")
    assert_equal("bradross@prodigy.net", promoter.email, "promoter email")
    
    event = Event.find_by_name("Fast Twitch Fridays")
    promoter = event.promoter
    assert_not_nil(promoter, "Promoter should not be nil")
    assert_equal("Jen Featheringill", promoter.name, "promoter name")
    assert_equal("503-227-4439", promoter.phone, "promoter phone")
    assert_equal("bike-central@bike-central.com", promoter.email, "promoter email")
    
    event = Event.find_by_name("Healthnet Criterium")
    promoter = event.promoter
    assert_not_nil(promoter, "Promoter should not be nil")
    assert_equal("Porter Childs", promoter.name, "promoter name")
    assert_equal("(503) 222-5868", promoter.phone, "promoter phone")
    assert_equal("Porter@ORbike.com", promoter.email, "promoter email")
    
    event = Event.find_by_name("High Desert Omnium")
    promoter = event.promoter
    assert_not_nil(promoter, "Promoter should not be nil")
    assert_equal("Tim Plummer", promoter.name, "promoter name")
    assert_equal("541-330-8758", promoter.phone, "promoter phone")
    assert_equal("tplummer@bendcycling.org", promoter.email, "promoter email")
    
    event = Event.find_by_name("Hood River CCX")
    promoter = event.promoter
    assert_not_nil(promoter, "Promoter should not be nil")
    assert_equal("Jeff Lorenzon", promoter.name, "promoter name")
    assert_equal("541-490-6837", promoter.phone, "promoter phone")
    assert_equal("obra369@yahoo.com", promoter.email, "promoter email")
    
    event = Event.find_by_name("Jack Frost Time Trial")
    promoter = event.promoter
    assert_not_nil(promoter, "Promoter should not be nil")
    assert_equal("Phil Sanders", promoter.name, "promoter name")
    assert_equal("503-649-4632", promoter.phone, "promoter phone")
    assert_equal("philipsanders2@comcast.net", promoter.email, "promoter email")
    
    event = Event.find_by_name("LA World Cup")
    promoter = event.promoter
    assert_nil(promoter, "Promoter should not nil")
    
    event = Event.find_by_name("Track Development Class")
    promoter = event.promoter
    assert_not_nil(promoter, "Promoter should not be nil")
    assert_equal("Bill Cass", promoter.name, "promoter name")
    assert_equal("503-246-6480", promoter.phone, "promoter phone")
    assert_equal("Bill.Cass@nike.com", promoter.email, "promoter email")
    
    event = Event.find_by_name("Vancouver Courthouse Criterium")
    promoter = event.promoter
    assert_not_nil(promoter, "Promoter should not be nil")
    assert_equal("Carl Anton", promoter.name, "promoter name")
    assert_equal("360-695-7088", promoter.phone, "promoter phone")
    assert_equal("canton@innventures.com", promoter.email, "promoter email")
    
    event = Event.find_by_name("Veloshop CCX")
    promoter = event.promoter
    assert_not_nil(promoter, "Promoter should not be nil")
    assert_equal("Molly Cameron", promoter.name, "promoter name")
    assert_equal("503.335.VELO", promoter.phone, "promoter phone")
    assert_equal("Molly Cameron [molly@veloshop.org]", promoter.email, "promoter email")
  end
end