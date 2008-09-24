require File.dirname(__FILE__) + '/../test_helper'

# TODO Test updated_at and created_at
# TODO Test name cannot be null

class MultiDayEventTest < ActiveSupport::TestCase
  
  def test_update_events_promoter
    pir_july_5 = events(:pir)
    pir_july_12 = events(:pir_2)
    promoter = pir_july_5.promoter

    promoter.name = "Nathan Hobson"
    promoter.phone = "411-9292"
    promoter.email = "sixhobson@hotmail.com"
    promoter.save!
    
    pir_series = events(:pir_series)
    
    pir_july_5.reload
    assert_equal("Tuesday Night PIR", pir_july_5.name, "name")
    assert_equal("Portland", pir_july_5.city, "city")
    assert_equal("OR", pir_july_5.state, "state")
    assert_equal_dates("2005-07-05", pir_july_5.date, "date")
    assert_equal("Road", pir_july_5.discipline, "discipline")
    assert_equal("http://#{STATIC_HOST}/flyers/2005/pir.html", pir_july_5.flyer, "flyer")
    assert_equal(promoter, pir_july_5.promoter, "promoter")
    assert_equal(ASSOCIATION.short_name, pir_july_5.sanctioned_by, "sanctioned_by")
    assert_equal("Nathan Hobson", pir_july_5.promoter.name, "promoter name")
    assert_equal("411-9292", pir_july_5.promoter.phone, "promoter phone")
    assert_equal("sixhobson@hotmail.com", pir_july_5.promoter.email, "promoter email")

    pir_july_12.reload
    assert_equal("Tuesday Night PIR", pir_july_12.name, "name")
    assert_equal("Portland", pir_july_12.city, "city")
    assert_equal("OR", pir_july_12.state, "state")
    assert_equal_dates("2005-07-12", pir_july_12.date, "date")
    assert_equal("Road", pir_july_12.discipline, "discipline")
    assert_equal("http://#{STATIC_HOST}/flyers/2005/pir.html", pir_july_12.flyer, "flyer")
    assert_equal(promoter, pir_july_12.promoter, "promoter")
    assert_equal(ASSOCIATION.short_name, pir_july_12.sanctioned_by, "sanctioned_by")
    assert_equal("Nathan Hobson", pir_july_12.promoter.name, "promoter name")
    assert_equal("411-9292", pir_july_12.promoter.phone, "promoter phone")
    assert_equal("sixhobson@hotmail.com", pir_july_12.promoter.email, "promoter email")
  end

  def test_timestamps
    short_track_series = MultiDayEvent.new(:name => "Short Track MTB")
    short_track_series.save!
    short_track_series.reload
    assert_not_nil(short_track_series.created_at, "initial short_track_series.created_at")
    assert_not_nil(short_track_series.updated_at, "initial short_track_series.updated_at")
    assert(short_track_series.updated_at - short_track_series.created_at < 10, "initial short_track_series.updated_at and created_at")
  end

  def test_start_end_dates
    assert_equal_dates("2005-07-05", events(:pir_series).start_date, "PIR series start date")
    assert_equal_dates("2005-07-12", events(:pir_series).end_date, "PIR series end date")
  end
  
  def test_new
    series = MultiDayEvent.create
    today = Date.today
    assert_equal_dates(today, series.date, "PIR series date")
    assert_equal_dates(today, series.start_date, "PIR series start date")
    assert_equal_dates(today, series.end_date, "PIR series end date")
    
    series.save!
    assert_equal_dates(today, series.date, "PIR series date")
    assert_equal_dates(today, series.start_date, "PIR series start date")
    assert_equal_dates(today, series.end_date, "PIR series end date")
    sql_results = series.connection.select_one("select date from events where id=#{series.id}")
    assert_equal(today.strftime('%Y-%m-%d'), sql_results["date"], "Series date column from DB")
    
    new_series_event = series.events.create(:date => Date.new(2001, 6, 19))
    assert_equal_dates("2001-06-19", series.date, "PIR series date")
    assert_equal_dates("2001-06-19", series.start_date, "PIR series start date")
    assert_equal_dates("2001-06-19", series.end_date, "PIR series end date")
    sql_results = series.connection.select_one("select date from events where id=#{series.id}")
    assert_equal("2001-06-19", sql_results["date"], "Series date column from DB")
    
    series.events.create(:date => Date.new(2001, 6, 23))
    series.save!
    assert_equal_dates("2001-06-19", series.date, "PIR series date")
    assert_equal_dates("2001-06-19", series.start_date, "PIR series start date")
    assert_equal_dates("2001-06-23", series.end_date, "PIR series end date")
    sql_results = series.connection.select_one("select date from events where id=#{series.id}")
    assert_equal("2001-06-19", sql_results["date"], "Series date column from DB")
  end
  
  def test_create_from_events
    single_event = SingleDayEvent.create(:date => Date.new(2007, 6, 19))
    multi_day_event = MultiDayEvent.create_from_events([single_event])
    assert_not_nil(multi_day_event, "MultiDayEvent from one event")
    assert(multi_day_event.instance_of?(MultiDayEvent), "MultiDayEvent class")
    assert_not_nil(single_event.parent, "SingleDayEvent parent")
    assert_equal(1, multi_day_event.events(true).size, "MultiDayEvent events size")
    assert_equal_dates("2007-06-19", multi_day_event.start_date, "MultiDayEvent events start date")
    assert_equal_dates("2007-06-19", multi_day_event.end_date, "MultiDayEvent events end date")

    single_event_1 = SingleDayEvent.create(:date => Date.new(2007, 6, 19))
    single_event_2 = SingleDayEvent.create(:date => Date.new(2007, 6, 20))
    multi_day_event = MultiDayEvent.create_from_events([single_event_1, single_event_2])
    assert_not_nil(multi_day_event, "MultiDayEvent from two events")
    assert(multi_day_event.instance_of?(MultiDayEvent), "MultiDayEvent should be instance of MultiDayEvent class")
    assert_not_nil(single_event_1.parent, "SingleDayEvent parent")
    assert_not_nil(single_event_2.parent, "SingleDayEvent parent")
    assert_equal(2, multi_day_event.events.size, "MultiDayEvent events size")
    assert_equal_dates("2007-06-19", multi_day_event.start_date, "MultiDayEvent events start date")
    assert_equal_dates("2007-06-20", multi_day_event.end_date, "MultiDayEvent events end date")

    single_event_1 = SingleDayEvent.create(:date => Date.new(2007, 6, 16))
    single_event_2 = SingleDayEvent.create(:date => Date.new(2007, 6, 23))
    multi_day_event = MultiDayEvent.create_from_events([single_event_1, single_event_2])
    assert_not_nil(multi_day_event, "Series from two events")
    assert(multi_day_event.instance_of?(Series), "MultiDayEvent should be instance of Series class")
    assert_not_nil(single_event_1.parent, "SingleDayEvent parent")
    assert_not_nil(single_event_2.parent, "SingleDayEvent parent")
    assert_equal(2, multi_day_event.events.size, "MultiDayEvent events size")
    assert_equal_dates("2007-06-16", multi_day_event.start_date, "MultiDayEvent events start date")
    assert_equal_dates("2007-06-23", multi_day_event.end_date, "MultiDayEvent events end date")

    single_event_1 = SingleDayEvent.create(:date => Date.new(2007, 6, 15))
    single_event_2 = SingleDayEvent.create(:date => Date.new(2007, 6, 22))
    multi_day_event = MultiDayEvent.create_from_events([single_event_1, single_event_2])
    assert_not_nil(multi_day_event, "Series from two events")
    assert(multi_day_event.instance_of?(WeeklySeries), "MultiDayEvent should be instance of WeeklySeries class")
    assert_not_nil(single_event_1.parent, "SingleDayEvent parent")
    assert_not_nil(single_event_2.parent, "SingleDayEvent parent")
    assert_equal(2, multi_day_event.events.size, "MultiDayEvent events size")
    assert_equal_dates("2007-06-15", multi_day_event.start_date, "MultiDayEvent events start date")
    assert_equal_dates("2007-06-22", multi_day_event.end_date, "MultiDayEvent events end date")
  end
  
  def test_destroy
    mt_hood = events(:mt_hood)
    mt_hood.destroy
    assert_raises(ActiveRecord::RecordNotFound, "Mt. Hood Stage Race should be deleted") {Event.find(mt_hood.id)}
  end
  
  def test_date_range_s
    mt_hood = events(:mt_hood)
    assert_equal('7/11-12', mt_hood.date_range_s, 'Date range')
    mt_hood.events.last.date = Date.new(2005, 8, 1)
    mt_hood.events.last.save!
    mt_hood.save!
    mt_hood.reload
    assert_equal('7/11-8/1', mt_hood.date_range_s, 'Date range')
  end
  
  def test_propogate_changes
    # parent, children same except for dates
    single_event_1 = SingleDayEvent.new(:date => Date.new(2007, 6, 19))
    single_event_1.name = "Elkhorn Stage Race"
    single_event_1.cancelled = false
    single_event_1.city = "Baker City"
    single_event_1.discipline = "Track"
    single_event_1.flyer = "http://google.com"
    single_event_1.promoter = promoters(:brad_ross)
    single_event_1.sanctioned_by = "FIAC"
    single_event_1.state = "NY"
    single_event_1.prize_list = 3000
    single_event_1.velodrome_id = velodromes(:alpenrose).id
    single_event_1.save!
    
    single_event_2 = SingleDayEvent.new(:date => Date.new(2007, 6, 26))
    single_event_2.name = "Elkhorn Stage Race"
    single_event_2.cancelled = false
    single_event_2.city = "Baker City"
    single_event_2.discipline = "Track"
    single_event_2.flyer = "http://google.com"
    single_event_2.promoter = promoters(:brad_ross)
    single_event_2.sanctioned_by = "FIAC"
    single_event_2.state = "NY"
    single_event_2.prize_list = 3000
    single_event_2.velodrome_id = velodromes(:alpenrose).id
    single_event_2.save!
    
    multi_day_event = MultiDayEvent.create_from_events([single_event_1, single_event_2])
    multi_day_event.save!
    
    # Bypass business logic and test what's really in the database
    results = Event.connection.select_one("select * from events where id=#{single_event_1.id}")
    assert_equal("Elkhorn Stage Race", results["name"], "SingleDayEvent name")
    assert_equal('0', results["cancelled"], "SingleDayEvent cancelled")
    assert_equal("2007-06-19", results["date"], "SingleDayEvent start_date")
    assert_equal("Baker City", results["city"], "SingleDayEvent city")
    assert_equal("Track", results["discipline"], "SingleDayEvent discipline")
    assert_equal("http://google.com", results["flyer"], "SingleDayEvent flyer")
    assert_equal("0", results["flyer_approved"], "SingleDayEvent flyer")
    assert_equal(promoters(:brad_ross).id, results["promoter_id"].to_i, "SingleDayEvent promoter_id")
    assert_equal("FIAC", results["sanctioned_by"], "SingleDayEvent sanctioned_by")
    assert_equal("NY", results["state"], "SingleDayEvent state")
    assert_equal("3000", results["prize_list"], "SingleDayEvent prize_list")
    assert_equal(velodromes(:alpenrose).to_param, results["velodrome_id"], "SingleDayEvent velodrome")
    assert_equal(multi_day_event.id, results["parent_id"].to_i, "SingleDayEvent parent ID")

    results = Event.connection.select_one("select * from events where id=#{single_event_2.id}")
    assert_equal("Elkhorn Stage Race", results["name"], "SingleDayEvent name")
    assert_equal('0', results["cancelled"], "SingleDayEvent cancelled")
    assert_equal("2007-06-26", results["date"], "SingleDayEvent start_date")
    assert_equal("Baker City", results["city"], "SingleDayEvent city")
    assert_equal("Track", results["discipline"], "SingleDayEvent discipline")
    assert_equal("http://google.com", results["flyer"], "SingleDayEvent flyer")
    assert_equal("0", results["flyer_approved"], "SingleDayEvent flyer")
    assert_equal(promoters(:brad_ross).id, results["promoter_id"].to_i, "SingleDayEvent promoter_id")
    assert_equal("FIAC", results["sanctioned_by"], "SingleDayEvent sanctioned_by")
    assert_equal("NY", results["state"], "SingleDayEvent state")
    assert_equal("3000", results["prize_list"], "SingleDayEvent prize_list")
    assert_equal(velodromes(:alpenrose).to_param, results["velodrome_id"], "SingleDayEvent velodrome")
    assert_equal(multi_day_event.id, results["parent_id"].to_i, "SingleDayEvent parent ID")

    results = Event.connection.select_one("select * from events where id=#{multi_day_event.id}")
    assert_equal("Elkhorn Stage Race", results["name"], "MultiDayEvent name")
    assert_equal('0', results["cancelled"], "MultiDayEvent cancelled")
    assert_equal("2007-06-19", results["date"], "MultiDayEvent start_date")
    assert_equal("Baker City", results["city"], "MultiDayEvent city")
    assert_equal("Track", results["discipline"], "MultiDayEvent discipline")
    assert_equal("http://google.com", results["flyer"], "MultiDayEvent flyer")
    assert_equal("0", results["flyer_approved"], "MultiDayEvent flyer")
    assert_equal(promoters(:brad_ross).id, results["promoter_id"].to_i, "MultiDayEvent promoter_id")
    assert_equal("FIAC", results["sanctioned_by"], "MultiDayEvent sanctioned_by")
    assert_equal("NY", results["state"], "MultiDayEvent state")
    assert_equal("3000", results["prize_list"], "MultiDayEvent prize_list")
    assert_equal(velodromes(:alpenrose).to_param, results["velodrome_id"], "MultiDayEvent velodrome")

    # change only name, all children should change
    multi_day_event.name = "FIAC Stage Race Championship"
    multi_day_event.save!

    results = Event.connection.select_one("select * from events where id=#{single_event_1.id}")
    assert_equal("FIAC Stage Race Championship", results["name"], "SingleDayEvent name")
    results = Event.connection.select_one("select * from events where id=#{single_event_2.id}")
    assert_equal("FIAC Stage Race Championship", results["name"], "SingleDayEvent name")
    
    # change all other parent data, all children change
    single_event_1.name = "Elkhorn Stage Race"
    single_event_1.save!
    single_event_2.name = "Elkhorn Stage Race"
    single_event_2.save!
    multi_day_event.reload
    multi_day_event.name = "Elkhorn Stage Race"
    multi_day_event.save!
    multi_day_event.cancelled = true
    multi_day_event.city = "Boise"
    multi_day_event.state = "ID"
    multi_day_event.discipline = "Mountain Bike"
    multi_day_event.flyer = nil
    multi_day_event.flyer_approved = true
    candi_murray = promoters(:candi_murray)
    multi_day_event.promoter_name = candi_murray.name
    multi_day_event.promoter_email = candi_murray.email
    multi_day_event.promoter_phone = candi_murray.phone
    multi_day_event.sanctioned_by = "UCI"
    assert_not_nil(multi_day_event.promoter, "event.promoter")
    multi_day_event.prize_list = 4000
    multi_day_event.velodrome_id = velodromes(:trexlertown).to_param
    multi_day_event.save!

    results = Event.connection.select_one("select * from events where id=#{single_event_1.id}")
    assert_equal("Elkhorn Stage Race", results["name"], "SingleDayEvent name")
    assert_equal('1', results["cancelled"], "SingleDayEvent cancelled")
    assert_equal_dates("2007-06-19", results["date"], "SingleDayEvent start_date")
    assert_equal("Boise", results["city"], "SingleDayEvent city")
    assert_equal("Mountain Bike", results["discipline"], "SingleDayEvent discipline")
    assert_equal(nil, results["flyer"], "SingleDayEvent flyer")
    assert_equal("1", results["flyer_approved"], "SingleDayEvent flyer")
    assert_equal(promoters(:candi_murray).id, results["promoter_id"].to_i, "SingleDayEvent promoter_id")
    assert_equal("UCI", results["sanctioned_by"], "SingleDayEvent sanctioned_by")
    assert_equal("ID", results["state"], "SingleDayEvent state")
    assert_equal("4000", results["prize_list"], "SingleDayEvent prize_list")
    assert_equal(velodromes(:trexlertown).to_param, results["velodrome_id"], "SingleDayEvent velodrome")

    results = Event.connection.select_one("select * from events where id=#{single_event_2.id}")
    assert_equal("Elkhorn Stage Race", results["name"], "SingleDayEvent name")
    assert_equal('1', results["cancelled"], "SingleDayEvent cancelled")
    assert_equal_dates("2007-06-26", results["date"], "SingleDayEvent start_date")
    assert_equal("Boise", results["city"], "SingleDayEvent city")
    assert_equal("Mountain Bike", results["discipline"], "SingleDayEvent discipline")
    assert_equal(nil, results["flyer"], "SingleDayEvent flyer")
    assert_equal("1", results["flyer_approved"], "SingleDayEvent flyer")
    assert_equal(promoters(:candi_murray).id, results["promoter_id"].to_i, "SingleDayEvent promoter_id")
    assert_equal("UCI", results["sanctioned_by"], "SingleDayEvent sanctioned_by")
    assert_equal("ID", results["state"], "SingleDayEvent state")
    assert_equal("4000", results["prize_list"], "SingleDayEvent prize_list")
    assert_equal(velodromes(:trexlertown).to_param, results["velodrome_id"], "SingleDayEvent velodrome")

    results = Event.connection.select_one("select * from events where id=#{multi_day_event.id}")
    assert_equal("Elkhorn Stage Race", results["name"], "MultiDayEvent name")
    assert_equal('1', results["cancelled"], "MultiDayEvent cancelled")
    assert_equal_dates("2007-06-19", results["date"], "MultiDayEvent start_date")
    assert_equal("Boise", results["city"], "MultiDayEvent city")
    assert_equal("Mountain Bike", results["discipline"], "MultiDayEvent discipline")
    assert_equal(nil, results["flyer"], "MultiDayEvent flyer")
    assert_equal("1", results["flyer_approved"], "MultiDayEvent flyer")
    assert_equal(promoters(:candi_murray).id, results["promoter_id"].to_i, "MultiDayEvent promoter_id")
    assert_equal("UCI", results["sanctioned_by"], "MultiDayEvent sanctioned_by")
    assert_equal("ID", results["state"], "MultiDayEvent state")
    assert_equal("4000", results["prize_list"], "MultiDayEvent prize_list")
    assert_equal(velodromes(:trexlertown).to_param, results["velodrome_id"], "MultiDayEvent velodrome")

    # parent, children all different
    # change parent, children do not change
    single_event_1.reload
    single_event_1.cancelled = false
    single_event_1.city = "Paris"
    single_event_1.state = "France"
    single_event_1.discipline = "Cyclocross"
    single_event_1.flyer = "http://www.letour.fr"
    single_event_1.promoter = nil
    single_event_1.sanctioned_by = ASSOCIATION.short_name
    single_event_1.save!

    results = Event.connection.select_one("select * from events where id=#{single_event_1.id}")
    assert_equal('0', results["cancelled"], "SingleDayEvent cancelled")
    
    multi_day_event.reload
    multi_day_event.cancelled = true
    multi_day_event.city = "Cazenovia"
    multi_day_event.state = "CT"
    multi_day_event.discipline = "Road"
    multi_day_event.flyer = "http://www.myseasons.com/"
    multi_day_event.sanctioned_by = "USA Cycling"
    brad_ross = promoters(:brad_ross)
    multi_day_event.promoter_name = brad_ross.name
    multi_day_event.promoter_email = brad_ross.email
    multi_day_event.promoter_phone = brad_ross.phone
    multi_day_event.save!

    results = Event.connection.select_one("select * from events where id=#{single_event_1.id}")
    assert_equal("Elkhorn Stage Race", results["name"], "SingleDayEvent name")
    assert_equal('0', results["cancelled"], "SingleDayEvent cancelled")
    assert_equal_dates("2007-06-19", results["date"], "SingleDayEvent start_date")
    assert_equal("Paris", results["city"], "SingleDayEvent city")
    assert_equal("Cyclocross", results["discipline"], "SingleDayEvent discipline")
    assert_equal("http://www.letour.fr", results["flyer"], "SingleDayEvent flyer")
    assert_nil(results["promoter_id"], "SingleDayEvent promoter_id")
    assert_equal(ASSOCIATION.short_name, results["sanctioned_by"], "SingleDayEvent sanctioned_by")
    assert_equal("France", results["state"], "SingleDayEvent state")

    results = Event.connection.select_one("select * from events where id=#{multi_day_event.id}")
    assert_equal("Elkhorn Stage Race", results["name"], "MultiDayEvent name")
    assert_equal('1', results["cancelled"], "MultiDayEvent cancelled")
    assert_equal_dates("2007-06-19", results["date"], "MultiDayEvent start_date")
    assert_equal("Cazenovia", results["city"], "MultiDayEvent city")
    assert_equal("Road", results["discipline"], "MultiDayEvent discipline")
    assert_equal("http://www.myseasons.com/", results["flyer"], "MultiDayEvent flyer")
    assert_equal(promoters(:brad_ross).id, results["promoter_id"].to_i, "MultiDayEvent promoter_id")
    assert_equal("USA Cycling", results["sanctioned_by"], "MultiDayEvent sanctioned_by")
    assert_equal("CT", results["state"], "MultiDayEvent state")
  end

  def test_full_name
    stage_race = events(:mt_hood)
    assert_equal('Mt. Hood Classic', stage_race.full_name, 'stage_race full_name')
  end
  
  def test_custom_create
    event = MultiDayEvent.create!(:name => 'MultiDayEvent standings', :date => Date.new(2002, 6, 12))
    standings = event.standings.create
    assert_equal_dates(Date.new(2002, 6, 12), event.date, 'event date')
    assert_equal_dates(Date.new(2002, 6, 12), standings.date, 'standings date')
  end
  
  def test_missing_parent
    assert(!events(:series_parent).missing_parent?, 'missing_parent?')
    assert_nil(events(:series_parent).missing_parent, 'missing_parent')
    assert(!events(:mt_hood).missing_parent?, 'missing_parent?')
    assert_nil(events(:mt_hood).missing_parent, 'missing_parent')
  end
  
  def test_guess_type
    assert_equal(MultiDayEvent, MultiDayEvent.guess_type([events(:mt_hood_1), events(:mt_hood_2)]), 'MultiDayEvent')
    assert_equal(Series, MultiDayEvent.guess_type([events(:banana_belt_1), events(:banana_belt_2), events(:banana_belt_3)]), 'Series')
    assert_equal(WeeklySeries, MultiDayEvent.guess_type([events(:pir), events(:pir_2)]), 'WeeklySeries')
  end
  
  def test_events_with_results
    event = MultiDayEvent.create!
    assert_equal(0, event.events_with_results, "events_with_results: no child")

    event.events.create!
    assert_equal(0, event.events_with_results, "events_with_results: child with no results")

    event.events.create!.standings.create!.races.create!(:category => categories(:cat_4_women)).results.create!
    assert_equal(0, event.events_with_results, "cached: events_with_results: 1 children with results")
    assert_equal(1, event.events_with_results(true), "refresh cache: events_with_results: 1 children with results")

    event.events.create!.standings.create!.races.create!(:category => categories(:cat_4_women)).results.create!
    assert_equal(2, event.events_with_results(true), "refresh cache: events_with_results: 2 children with results")
  end
  
  def test_completed
    parent_event = MultiDayEvent.create!
    assert(!parent_event.completed?, "New event should not be completed")
    
    parent_event.events.create!
    parent_event.events.create!
    parent_event.events.create!
    assert(!parent_event.completed?(true), "Event with all children with no results should not be completed")
    
    parent_event.events.first.standings.create!.races.create!(:category => categories(:cat_4_women)).results.create!
    assert(!parent_event.completed?(true), "Event with only one child with results should not be completed")
    
    parent_event.events.each { |event| event.standings.create!.races.create!(:category => categories(:cat_4_women)).results.create! }
    assert(parent_event.completed?(true), "Event with all children with results should be completed")
  end
end