require "test_helper"

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
    series = MultiDayEvent.create!
    beginning_of_year = Time.new.beginning_of_year
    assert_equal_dates(beginning_of_year, series.date, "PIR series date")
    assert_equal_dates(beginning_of_year, series.start_date, "PIR series start date")
    assert_equal_dates(beginning_of_year, series.end_date, "PIR series end date")
    
    series.save!
    assert_equal_dates(beginning_of_year, series.date, "PIR series date")
    assert_equal_dates(beginning_of_year, series.start_date, "PIR series start date")
    assert_equal_dates(beginning_of_year, series.end_date, "PIR series end date")
    sql_results = series.connection.select_one("select date from events where id=#{series.id}")
    assert_equal(beginning_of_year.strftime('%Y-%m-%d'), sql_results["date"], "Series date column from DB")
    
    new_series_event = series.children.create(:date => Date.new(2001, 6, 19))
    assert_equal_dates("2001-06-19", series.date, "PIR series date")
    assert_equal_dates("2001-06-19", series.start_date, "PIR series start date")
    assert_equal_dates("2001-06-19", series.end_date, "PIR series end date")
    sql_results = series.connection.select_one("select date from events where id=#{series.id}")
    assert_equal("2001-06-19", sql_results["date"], "Series date column from DB")
    
    series.children.create(:date => Date.new(2001, 6, 23))
    series.save!
    assert_equal_dates("2001-06-19", series.date, "PIR series date")
    assert_equal_dates("2001-06-19", series.start_date, "PIR series start date")
    assert_equal_dates("2001-06-23", series.end_date, "PIR series end date")
    sql_results = series.connection.select_one("select date from events where id=#{series.id}")
    assert_equal("2001-06-19", sql_results["date"], "Series date column from DB")
  end
  
  def test_create_from_children
    single_event = SingleDayEvent.create!(:date => Date.new(2007, 6, 19))
    multi_day_event = MultiDayEvent.create_from_children([single_event])
    assert_not_nil(multi_day_event, "MultiDayEvent from one event")
    assert(multi_day_event.instance_of?(MultiDayEvent), "MultiDayEvent class")
    assert_not_nil(single_event.parent, "SingleDayEvent parent")
    assert_equal(1, multi_day_event.children.count, "MultiDayEvent events size")
    single_event.reload
    assert_equal(multi_day_event, single_event.parent, "SingleDayEvent parent")
    assert_equal_dates("2007-06-19", multi_day_event.start_date, "MultiDayEvent events start date")
    assert_equal_dates("2007-06-19", multi_day_event.end_date, "MultiDayEvent events end date")

    single_event_1 = SingleDayEvent.create!(:date => Date.new(2007, 6, 19))
    single_event_2 = SingleDayEvent.create!(:date => Date.new(2007, 6, 20))
    multi_day_event = MultiDayEvent.create_from_children([single_event_1, single_event_2])
    assert_not_nil(multi_day_event, "MultiDayEvent from two events")
    assert(multi_day_event.instance_of?(MultiDayEvent), "MultiDayEvent should be instance of MultiDayEvent class")
    single_event_1.reload
    assert_equal(multi_day_event, single_event_1.parent, "SingleDayEvent parent")
    single_event_2.reload
    assert_equal(multi_day_event, single_event_2.parent, "SingleDayEvent parent")
    assert_equal(2, multi_day_event.children.size, "MultiDayEvent events size")
    assert_equal_dates("2007-06-19", multi_day_event.start_date, "MultiDayEvent events start date")
    assert_equal_dates("2007-06-20", multi_day_event.end_date, "MultiDayEvent events end date")

    single_event_1 = SingleDayEvent.create(:date => Date.new(2007, 6, 16))
    single_event_2 = SingleDayEvent.create(:date => Date.new(2007, 6, 23))
    multi_day_event = MultiDayEvent.create_from_children([single_event_1, single_event_2])
    assert_not_nil(multi_day_event, "Series from two events")
    assert(multi_day_event.instance_of?(Series), "MultiDayEvent should be instance of Series class")
    assert_not_nil(single_event_1.parent, "SingleDayEvent parent")
    assert_not_nil(single_event_2.parent, "SingleDayEvent parent")
    assert_equal(2, multi_day_event.children.size, "MultiDayEvent events size")
    assert_equal_dates("2007-06-16", multi_day_event.start_date, "MultiDayEvent events start date")
    assert_equal_dates("2007-06-23", multi_day_event.end_date, "MultiDayEvent events end date")

    single_event_1 = SingleDayEvent.create(:date => Date.new(2007, 6, 15))
    single_event_2 = SingleDayEvent.create(:date => Date.new(2007, 6, 22))
    multi_day_event = MultiDayEvent.create_from_children([single_event_1, single_event_2])
    assert_not_nil(multi_day_event, "Series from two events")
    assert(multi_day_event.instance_of?(WeeklySeries), "MultiDayEvent should be instance of WeeklySeries class")
    assert_not_nil(single_event_1.parent, "SingleDayEvent parent")
    assert_not_nil(single_event_2.parent, "SingleDayEvent parent")
    assert_equal(2, multi_day_event.children.size, "MultiDayEvent events size")
    assert_equal_dates("2007-06-15", multi_day_event.start_date, "MultiDayEvent events start date")
    assert_equal_dates("2007-06-22", multi_day_event.end_date, "MultiDayEvent events end date")
  end
  
  def test_create_children
    event = MultiDayEvent.create!(:start_date => Date.new(2009, 4), :end_date => Date.new(2009, 9), :every => "Monday", :time => "5:30 PM till dusk")
    assert_equal(22, event.children.size, "Should create child events")
    Date.new(2009, 4, 6).step(Date.new(2009, 8, 31), 7) do |date|
      assert(event.children.any? { |child| child.date == date }, "Should have child event for #{date} in #{event.children.map { |e| e.date }.join(', ')}")
    end

    event = MultiDayEvent.create!(:start_date => Date.new(2009, 5), :end_date => Date.new(2009, 10), :every => "Sunday")
    assert_equal(22, event.children.size, "Should create child events")
    Date.new(2009, 5, 3).step(Date.new(2009, 9, 30), 7) do |date|
      assert(event.children.any? { |child| child.date == date }, "Should have child event for #{date} in #{event.children.map { |e| e.date }.join(', ')}")
    end

    event = MultiDayEvent.create!(:start_date => Date.new(2009, 5), :end_date => Date.new(2009, 10), :every => "Tuesday")
    assert_equal(22, event.children.size, "Should create child events")
    Date.new(2009, 5, 5).step(Date.new(2009, 10, 1), 7) do |date|
      assert(event.children.any? { |child| child.date == date }, "Should have child event for #{date} in #{event.children.map { |e| e.date }.join(', ')}")
    end
  end
  
  def test_create_children_on_multiple_days_of_week
    event = MultiDayEvent.create!(:start_date => Date.new(2009), :end_date => Date.new(2009, 12, 31), :every => ["Saturday", "Sunday"])
    assert_equal(104, event.children.size, "Should create child events")

    Date.new(2009, 1, 3).step(Date.new(2009, 12, 26), 7) do |date|
      assert(event.children.any? { |child| child.date == date }, "Should have child event for #{date} in #{event.children.map { |e| e.date }.join(', ')}")
    end

    Date.new(2009, 1, 4).step(Date.new(2009, 12, 27), 7) do |date|
      assert(event.children.any? { |child| child.date == date }, "Should have child event for #{date} in #{event.children.map { |e| e.date }.join(', ')}")
    end
  end
  
  def test_destroy
    mt_hood = events(:mt_hood)
    mt_hood.destroy
    assert(!Event.exists?(mt_hood.id), "Mt. Hood Stage Race should be deleted")
  end
  
  def test_date_range_s
    mt_hood = events(:mt_hood)
    assert_equal('7/11-12', mt_hood.date_range_s, 'Date range')
    mt_hood.children.last.date = Date.new(2005, 8, 1)
    mt_hood.children.last.save!
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
    
    multi_day_event = MultiDayEvent.create_from_children([single_event_1, single_event_2])
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
  
  def test_update_children_should_consider_blank_as_nil
    parent = MultiDayEvent.create!
    child = parent.children.create!
    assert_equal(nil, parent.flyer, "parent flyer")
    assert_equal(nil, child.flyer, "child flyer")
    
    parent.flyer = "http://example.com/flyers/1"
    parent.save!
    child.reload
    assert_equal("http://example.com/flyers/1", parent.flyer, "parent flyer")
    assert_equal("http://example.com/flyers/1", child.flyer, "child flyer")

    parent = MultiDayEvent.create!(:flyer => "")
    child = parent.children.create!
    child.flyer = nil
    child.save!
    assert_equal("", parent.flyer, "parent flyer")
    assert_equal(nil, child.flyer, "child flyer")

    parent.flyer = "http://example.com/flyers/1"
    parent.save!
    child.reload
    assert_equal("http://example.com/flyers/1", parent.flyer, "parent flyer")
    assert_equal("http://example.com/flyers/1", child.flyer, "child flyer")

    parent = MultiDayEvent.create!
    child = parent.children.create!(:flyer => "")
    assert_equal(nil, parent.flyer, "parent flyer")
    assert_equal(nil, child.flyer, "child flyer")

    parent.flyer = "http://example.com/flyers/1"
    parent.save!
    child.reload
    assert_equal("http://example.com/flyers/1", parent.flyer, "parent flyer")
    assert_equal("http://example.com/flyers/1", child.flyer, "child flyer")

    parent = MultiDayEvent.create!(:flyer => "")
    child = parent.children.create!(:flyer => "")
    assert_equal("", parent.flyer, "parent flyer")
    assert_equal("", child.flyer, "child flyer")

    parent.flyer = "http://example.com/flyers/1"
    parent.save!
    child.reload
    assert_equal("http://example.com/flyers/1", parent.flyer, "parent flyer")
    assert_equal("http://example.com/flyers/1", child.flyer, "child flyer")
  end

  def test_full_name
    stage_race = events(:mt_hood)
    assert_equal('Mt. Hood Classic', stage_race.full_name, 'stage_race full_name')
  end
  
  def test_custom_create
    event = MultiDayEvent.create!(:name => 'MultiDayEvent', :date => Date.new(2002, 6, 12))
    child = event.children.create
    assert_equal_dates(Date.new(2002, 6, 12), event.date, 'event date')
    assert_equal_dates(Date.new(2002, 6, 12), child.date, 'child event date')
  end
  
  def test_create_defaults
    parent = MultiDayEvent.create!(:flyer_approved => true)
    child = parent.children.create!(:flyer_approved => true)
    assert_equal(true, child.flyer_approved?, "parent true, child true, default false")

    parent = MultiDayEvent.create!(:flyer_approved => false)
    child = parent.children.create!(:flyer_approved => false)
    assert_equal(false, child.flyer_approved?, "parent true, child true, default false")

    parent = MultiDayEvent.create!
    child = parent.children.create!(:flyer_approved => true)
    assert_equal(true, child.flyer_approved?, "parent true, child true, default false")

    parent = MultiDayEvent.create!
    child = parent.children.create!(:flyer_approved => false)
    assert_equal(false, child.flyer_approved?, "parent true, child true, default false")

    parent = MultiDayEvent.create!(:flyer_approved => true)
    child = parent.children.create!
    assert_equal(true, child.flyer_approved?, "parent true, child true, default false")

    parent = MultiDayEvent.create!(:flyer_approved => false)
    child = parent.children.create!
    assert_equal(false, child.flyer_approved?, "parent true, child true, default false")

    parent = MultiDayEvent.create!(:flyer_approved => false)
    child = parent.children.create!
    assert_equal(false, child.flyer_approved?, "parent true, child true, default false")

    parent = MultiDayEvent.create!(:city => nil)
    child = parent.children.create!
    assert_equal(nil, child.city, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!(:city => nil)
    child = parent.children.create!(:city => nil)
    assert_equal(nil, child.city, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!
    child = parent.children.create!(:city => nil)
    assert_equal(nil, child.city, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!
    child = parent.children.create!(:city => "city")
    assert_equal("city", child.city, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!
    child = parent.children.create!
    assert_equal(nil, child.city, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!(:city => "")
    child = parent.children.create!
    assert_equal("", child.city, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!(:city => "")
    child = parent.children.create!(:city => "")
    assert_equal("", child.city, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!(:city => "")
    child = parent.children.create!(:city => nil)
    assert_equal("", child.city, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!(:city => "")
    child = parent.children.create!(:city => "city")
    assert_equal("city", child.city, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!(:city => "city")
    child = parent.children.create!
    assert_equal("city", child.city, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!(:city => "city")
    child = parent.children.create!(:city => "")
    assert_equal("city", child.city, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!(:city => "city")
    child = parent.children.create!(:city => nil)
    assert_equal("city", child.city, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!(:city => "parent city")
    child = parent.children.create!(:city => "city")
    assert_equal("city", child.city, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!(:state => nil)
    parent.state = ""
    parent.save!
    assert_equal("", parent.reload.state, "Should be able to set state not blank")
    child = parent.children.create!
    assert_equal("", child.state, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!(:state => "")
    child = parent.children.create!(:state => "")
    assert_equal("", child.state, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!
    child = parent.children.create!(:state => nil)
    assert_equal(ASSOCIATION.state, child.state, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!
    child = parent.children.create!(:state => "NY")
    assert_equal("NY", child.state, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!
    child = parent.children.create!
    assert_equal(ASSOCIATION.state, child.state, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!(:state => "")
    child = parent.children.create!
    assert_equal("", child.state, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!(:state => "")
    child = parent.children.create!(:state => "")
    assert_equal("", child.state, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!(:state => "")
    child = parent.children.create!(:state => nil)
    assert_equal("", child.state, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!(:state => "")
    child = parent.children.create!(:state => "NY")
    assert_equal("NY", child.state, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!(:state => "NY")
    child = parent.children.create!
    assert_equal("NY", child.state, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!(:state => "NY")
    child = parent.children.create!(:state => "")
    assert_equal("NY", child.state, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!(:state => "NY")
    child = parent.children.create!(:state => nil)
    assert_equal("NY", child.state, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!(:state => "VA")
    child = parent.children.create!(:state => "NY")
    assert_equal("NY", child.state, "child should inherit parent values unless specified")
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
  
  def children_with_results
    event = MultiDayEvent.create!
    assert_equal(0, event.children_with_results.size, "events_with_results: no child")

    event.children.create!
    assert_equal(0, event.children_with_results.size, "events_with_results: child with no results")
    assert_equal(0, event.children_and_child_competitions_with_results.size, "children_and_child_competitions_with_results: child with no results")

    event.children.create!.races.create!(:category => categories(:cat_4_women)).results.create!
    assert_equal(1, event.children_with_results.size, "cached: events_with_results: 1 children with results")
    assert_equal(1, event.children_with_results(true).size, "refresh cache: events_with_results: 1 children with results")
    assert_equal(1, event.children_and_child_competitions_with_results(true).size, "refresh cache: children_and_child_competitions_with_results: 1 children with results")

    event.children.create!.races.create!(:category => categories(:cat_4_women)).results.create!
    assert_equal(2, event.children_with_results(true).size, "refresh cache: events_with_results: 2 children with results")
    assert_equal(2, event.children_and_child_competitions_with_results(true).size, "refresh cache: children_and_child_competitions_with_results: 2 children with results")
    
    overall = event.create_overall
    overall.races.create!(:category => categories(:cat_4_women)).results.create!
    assert_equal(2, event.children_with_results(true).size, "refresh cache: events_with_results: 2 children with results + overall")
    assert_equal(3, event.children_and_child_competitions_with_results(true).size, "refresh cache: children_and_child_competitions_with_results: 2 children with results + overall")
  end
  
  def test_completed
    parent_event = MultiDayEvent.create!
    assert(!parent_event.completed?, "New event should not be completed")
    
    parent_event.children.create!
    parent_event.children.create!
    parent_event.children.create!
    assert(!parent_event.completed?(true), "Event with all children with no results should not be completed")
    
    parent_event.children.first.races.create!(:category => categories(:cat_4_women)).results.create!
    assert(!parent_event.completed?(true), "Event with only one child with results should not be completed")
    
    parent_event.children.each { |event| event.races.create!(:category => categories(:cat_4_women)).results.create! }
    assert(parent_event.completed?(true), "Event with all children with results should be completed")
  end
  
  def test_child_event_dates
    parent_event = MultiDayEvent.create!(:date => Date.new(2007, 9, 19))
    assert_equal(Date.new(2007, 9, 19), parent_event.date, "Parent MultiDayEvent date after create")
    
    single_day_event = parent_event.children.create!
    assert_equal(Date.new(2007, 9, 19), single_day_event.date, "New SingleDayEvent child date shold match parent")
    
    event = single_day_event.children.create!
    assert_equal(Date.new(2007, 9, 19), event.date, "New Event child date shold match parent")
  end
end
