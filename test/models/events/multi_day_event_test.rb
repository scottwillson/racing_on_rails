# frozen_string_literal: true

require File.expand_path("../../test_helper", __dir__)

# :stopdoc:
class MultiDayEventTest < ActiveSupport::TestCase
  test "start end dates" do
    series = Series.create!
    series.children.create! date: Date.new(2005, 7, 5)
    series.children.create! date: Date.new(2005, 7, 12)

    assert_equal_dates("2005-07-05", series.start_date, "PIR series start date")
    assert_equal_dates("2005-07-12", series.end_date, "PIR series end date")

    series.children.create!(date: "2005-06-25")
    assert_equal_dates("2005-06-25", series.start_date, "PIR series start date")
    assert_equal_dates("2005-07-12", series.end_date, "PIR series end date")
    assert_equal_dates("2005-06-25", series.reload.start_date, "PIR series start date")
    assert_equal_dates("2005-07-12", series.reload.end_date, "PIR series end date")

    event = SingleDayEvent.create!(date: "2005-07-19")
    event.parent = series
    event.save!
    series.children.reload
    assert_equal_dates("2005-06-25", series.start_date, "PIR series start date")
    assert_equal_dates("2005-07-19", series.end_date, "PIR series end date")

    series.children.create!(date: "2005-07-26")
    series.children.create!(date: "2005-08-04")

    series.children.min_by(&:date).update! postponed: true
    series.children.sort_by(&:date)[1].update! canceled: true

    series.reload.children.reload
    assert_equal_dates("2005-07-12", series.start_date, "PIR series start date")
    assert_equal_dates("2005-08-04", series.end_date, "PIR series end date")
  end

  test "new" do
    series = MultiDayEvent.create!
    assert_equal_dates(Time.zone.today, series.date, "PIR series date")
    assert_equal_dates(Time.zone.today, series.start_date, "PIR series start date")
    assert_equal_dates(Time.zone.today, series.end_date, "PIR series end date")

    series.save!
    assert_equal_dates(Time.zone.today, series.date, "PIR series date")
    assert_equal_dates(Time.zone.today, series.start_date, "PIR series start date")
    assert_equal_dates(Time.zone.today, series.end_date, "PIR series end date")
    sql_results = Series.connection.select_one("select date from events where id=#{series.id}")
    assert_equal_dates(Time.zone.today, sql_results["date"], "Series date column from DB")

    series.children.create!(date: Date.new(2001, 6, 19))
    assert_equal_dates("2001-06-19", series.date, "PIR series date")
    assert_equal_dates("2001-06-19", series.start_date, "PIR series start date")
    assert_equal_dates("2001-06-19", series.end_date, "PIR series end date")
    sql_results = Series.connection.select_one("select date from events where id=#{series.id}")
    assert_equal_dates("2001-06-19", sql_results["date"], "Series date column from DB")

    series.children.create!(date: Date.new(2001, 6, 23))
    series.save!
    assert_equal_dates("2001-06-19", series.date, "PIR series date")
    assert_equal_dates("2001-06-19", series.start_date, "PIR series start date")
    assert_equal_dates("2001-06-23", series.end_date, "PIR series end date")
    sql_results = Series.connection.select_one("select date from events where id=#{series.id}")
    assert_equal_dates("2001-06-19", sql_results["date"], "Series date column from DB")
  end

  test "create from children" do
    single_event = SingleDayEvent.create!(date: Date.new(2007, 6, 19))
    multi_day_event = MultiDayEvent.create_from_children([single_event])
    assert_not_nil(multi_day_event, "MultiDayEvent from one event")
    assert(multi_day_event.instance_of?(MultiDayEvent), "MultiDayEvent class")
    assert_not_nil(single_event.parent, "SingleDayEvent parent")
    assert_equal(1, multi_day_event.children.count, "MultiDayEvent events size")
    single_event.reload
    assert_equal(multi_day_event, single_event.parent, "SingleDayEvent parent")
    assert_equal_dates("2007-06-19", multi_day_event.start_date, "MultiDayEvent events start date")
    assert_equal_dates("2007-06-19", multi_day_event.end_date, "MultiDayEvent events end date")

    single_event_1 = SingleDayEvent.create!(date: Date.new(2007, 6, 19))
    single_event_2 = SingleDayEvent.create!(date: Date.new(2007, 6, 20))
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

    single_event_1 = SingleDayEvent.create(date: Date.new(2007, 6, 16))
    single_event_2 = SingleDayEvent.create(date: Date.new(2007, 6, 23))
    multi_day_event = MultiDayEvent.create_from_children([single_event_1, single_event_2])
    assert_not_nil(multi_day_event, "Series from two events")
    assert(multi_day_event.instance_of?(Series), "MultiDayEvent should be instance of Series class")
    assert_not_nil(single_event_1.parent, "SingleDayEvent parent")
    assert_not_nil(single_event_2.parent, "SingleDayEvent parent")
    assert_equal(2, multi_day_event.children.size, "MultiDayEvent events size")
    assert_equal_dates("2007-06-16", multi_day_event.start_date, "MultiDayEvent events start date")
    assert_equal_dates("2007-06-23", multi_day_event.end_date, "MultiDayEvent events end date")

    single_event_1 = SingleDayEvent.create(date: Date.new(2007, 6, 15))
    single_event_2 = SingleDayEvent.create(date: Date.new(2007, 6, 22))
    multi_day_event = MultiDayEvent.create_from_children([single_event_1, single_event_2])
    assert_not_nil(multi_day_event, "Series from two events")
    assert(multi_day_event.instance_of?(WeeklySeries), "MultiDayEvent should be instance of WeeklySeries class")
    assert_not_nil(single_event_1.parent, "SingleDayEvent parent")
    assert_not_nil(single_event_2.parent, "SingleDayEvent parent")
    assert_equal(2, multi_day_event.children.size, "MultiDayEvent events size")
    assert_equal_dates("2007-06-15", multi_day_event.start_date, "MultiDayEvent events start date")
    assert_equal_dates("2007-06-22", multi_day_event.end_date, "MultiDayEvent events end date")
  end

  test "create for every!" do
    event = MultiDayEvent.create_for_every!("Monday",
                                            start_date: Date.new(2009, 4), end_date: Date.new(2009, 9), time: "5:30 PM till dusk")
    Date.new(2009, 4, 6).step(Date.new(2009, 8, 31), 7) do |date|
      assert(event.children.reload.any? { |child| child.date == date }, "Should have child event for #{date} in #{event.children.map(&:date).join(', ')}")
    end
    assert_equal(22, event.children.count, "Should create child events")
    assert_equal(22, event.children.size, "Should create child events")

    event = MultiDayEvent.create_for_every!("Sunday", start_date: Date.new(2009, 5), end_date: Date.new(2009, 10))
    assert_equal(22, event.children.reload.size, "Should create child events")
    Date.new(2009, 5, 3).step(Date.new(2009, 9, 30), 7) do |date|
      assert(event.children.any? { |child| child.date == date }, "Should have child event for #{date} in #{event.children.map(&:date).join(', ')}")
    end

    event = MultiDayEvent.create_for_every!("Tuesday", start_date: Date.new(2009, 5), end_date: Date.new(2009, 10))
    assert_equal(22, event.children.reload.size, "Should create child events")
    Date.new(2009, 5, 5).step(Date.new(2009, 10, 1), 7) do |date|
      assert(event.children.any? { |child| child.date == date }, "Should have child event for #{date} in #{event.children.map(&:date).join(', ')}")
    end
  end

  test "create children on multiple days of week" do
    event = MultiDayEvent.create_for_every!(%w[Saturday Sunday], start_date: Date.new(2009), end_date: Date.new(2009, 12, 31))
    assert_equal(104, event.children.reload.size, "Should create child events")

    Date.new(2009, 1, 3).step(Date.new(2009, 12, 26), 7) do |date|
      assert(event.children.any? { |child| child.date == date }, "Should have child event for #{date} in #{event.children.map(&:date).join(', ')}")
    end

    Date.new(2009, 1, 4).step(Date.new(2009, 12, 27), 7) do |date|
      assert(event.children.any? { |child| child.date == date }, "Should have child event for #{date} in #{event.children.map(&:date).join(', ')}")
    end
  end

  test "destroy" do
    mt_hood = FactoryBot.create(:stage_race)
    mt_hood.destroy
    assert_not(Event.exists?(mt_hood.id), "Mt. Hood Stage Race should be deleted")
  end

  test "date range s" do
    mt_hood = MultiDayEvent.create!
    mt_hood.children.create!(date: Date.new(2005, 7, 11))
    mt_hood.children.create!(date: Date.new(2005, 7, 12))
    assert_equal("7/11-12", mt_hood.date_range_s, "Date range")
    last_day = mt_hood.children.last
    last_day.date = Date.new(2005, 8, 1)
    last_day.save!
    mt_hood = Event.find(mt_hood.id)
    assert_equal("7/11-8/1", mt_hood.date_range_s, "Date range")
  end

  test "date range s long" do
    mt_hood = FactoryBot.create(:stage_race)
    assert_equal("7/11/2005-7/13/2005", mt_hood.date_range_s(:long), "date_range_s(long)")
    last_day = mt_hood.children.last
    last_day.date = Date.new(2005, 8, 1)
    last_day.save!
    mt_hood = Event.find(mt_hood.id)
    assert_equal("7/11/2005-8/1/2005", mt_hood.date_range_s(:long), "date_range_s(long)")

    kings_valley = FactoryBot.create(:event, date: Date.new(2003, 12, 31))
    assert_equal("12/31/2003", kings_valley.date_range_s(:long), "date_range_s(long)")
  end

  test "propogate changes" do
    # parent, children same except for dates
    single_event_1 = SingleDayEvent.new(date: Date.new(2007, 6, 19))
    single_event_1.name = "Elkhorn Stage Race"
    single_event_1.canceled = false
    single_event_1.city = "Baker City"
    single_event_1.discipline = "Track"
    single_event_1.email = "info@elkhornclassic.com"
    single_event_1.flyer = "http://google.com"
    single_event_1.phone = "718 671-1999"
    promoter = FactoryBot.create(:person)
    single_event_1.promoter = promoter
    single_event_1.sanctioned_by = "FIAC"
    single_event_1.state = "NY"
    single_event_1.prize_list = 3000
    gentle_lovers = FactoryBot.create(:team)
    single_event_1.team_id = gentle_lovers.id
    alpenrose = FactoryBot.create(:velodrome)
    single_event_1.velodrome_id = alpenrose.id
    single_event_1.save!

    single_event_2 = SingleDayEvent.new(date: Date.new(2007, 6, 26))
    single_event_2.name = "Elkhorn Stage Race"
    single_event_2.canceled = false
    single_event_2.city = "Baker City"
    single_event_2.discipline = "Track"
    single_event_2.email = "info@elkhornclassic.com"
    single_event_2.flyer = "http://google.com"
    single_event_2.promoter = promoter
    single_event_2.phone = "718 671-1999"
    single_event_2.sanctioned_by = "FIAC"
    single_event_2.state = "NY"
    single_event_2.prize_list = 3000
    single_event_2.team_id = gentle_lovers.id
    single_event_2.velodrome_id = alpenrose.id
    single_event_2.save!

    multi_day_event = MultiDayEvent.create_from_children([single_event_1, single_event_2])
    multi_day_event.save!

    # Bypass business logic and test what's really in the database
    results = Event.connection.select_one("select * from events where id=#{single_event_1.id}")
    assert_equal("Elkhorn Stage Race", results["name"], "SingleDayEvent name")
    assert_equal(0, results["canceled"], "SingleDayEvent canceled")
    assert_equal_dates("2007-06-19", results["date"], "SingleDayEvent start_date")
    assert_equal("Baker City", results["city"], "SingleDayEvent city")
    assert_equal("Track", results["discipline"], "SingleDayEvent discipline")
    assert_equal("info@elkhornclassic.com", results["email"], "SingleDayEvent email")
    assert_equal("http://google.com", results["flyer"], "SingleDayEvent flyer")
    assert_equal(0, results["flyer_approved"], "SingleDayEvent flyer")
    assert_equal("718 671-1999", results["phone"], "SingleDayEvent phone")
    assert_equal(promoter.id, results["promoter_id"].to_i, "SingleDayEvent promoter_id")
    assert_equal("FIAC", results["sanctioned_by"], "SingleDayEvent sanctioned_by")
    assert_equal("NY", results["state"], "SingleDayEvent state")
    assert_equal("3000", results["prize_list"], "SingleDayEvent prize_list")
    assert_equal(gentle_lovers.id, results["team_id"], "SingleDayEvent team")
    assert_equal(alpenrose.id, results["velodrome_id"], "SingleDayEvent velodrome")
    assert_equal(multi_day_event.id, results["parent_id"].to_i, "SingleDayEvent parent ID")
    assert_equal 0, results["beginner_friendly"], "parent beginner_friendly"

    results = Event.connection.select_one("select * from events where id=#{single_event_2.id}")
    assert_equal("Elkhorn Stage Race", results["name"], "SingleDayEvent name")
    assert_equal(0, results["canceled"], "SingleDayEvent canceled")
    assert_equal_dates("2007-06-26", results["date"], "SingleDayEvent start_date")
    assert_equal("Baker City", results["city"], "SingleDayEvent city")
    assert_equal("Track", results["discipline"], "SingleDayEvent discipline")
    assert_equal("info@elkhornclassic.com", results["email"], "SingleDayEvent email")
    assert_equal("http://google.com", results["flyer"], "SingleDayEvent flyer")
    assert_equal(0, results["flyer_approved"], "SingleDayEvent flyer")
    assert_equal("718 671-1999", results["phone"], "SingleDayEvent phone")
    assert_equal(promoter.id, results["promoter_id"].to_i, "SingleDayEvent promoter_id")
    assert_equal("FIAC", results["sanctioned_by"], "SingleDayEvent sanctioned_by")
    assert_equal("NY", results["state"], "SingleDayEvent state")
    assert_equal("3000", results["prize_list"], "SingleDayEvent prize_list")
    assert_equal(gentle_lovers.id, results["team_id"], "SingleDayEvent team")
    assert_equal(alpenrose.id, results["velodrome_id"], "SingleDayEvent velodrome")
    assert_equal(multi_day_event.id, results["parent_id"].to_i, "SingleDayEvent parent ID")
    assert_equal 0, results["beginner_friendly"], "event beginner_friendly"

    results = Event.connection.select_one("select * from events where id=#{multi_day_event.id}")
    assert_equal("Elkhorn Stage Race", results["name"], "MultiDayEvent name")
    assert_equal(0, results["canceled"], "MultiDayEvent canceled")
    assert_equal_dates("2007-06-19", results["date"], "MultiDayEvent start_date")
    assert_equal("Baker City", results["city"], "MultiDayEvent city")
    assert_equal("Track", results["discipline"], "MultiDayEvent discipline")
    assert_equal("info@elkhornclassic.com", results["email"], "MultiDayEvent email")
    assert_equal("http://google.com", results["flyer"], "MultiDayEvent flyer")
    assert_equal(0, results["flyer_approved"], "MultiDayEvent flyer")
    assert_equal("718 671-1999", results["phone"], "MultiDayEvent phone")
    assert_equal(promoter.id, results["promoter_id"].to_i, "MultiDayEvent promoter_id")
    assert_equal("FIAC", results["sanctioned_by"], "MultiDayEvent sanctioned_by")
    assert_equal("NY", results["state"], "MultiDayEvent state")
    assert_equal("3000", results["prize_list"], "MultiDayEvent prize_list")
    assert_equal(gentle_lovers.id, results["team_id"], "MultiDayEvent team")
    assert_equal(alpenrose.id, results["velodrome_id"], "MultiDayEvent velodrome")

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
    multi_day_event.canceled = true
    multi_day_event.city = "Boise"
    multi_day_event.state = "ID"
    multi_day_event.discipline = "Mountain Bike"
    multi_day_event.email = "scott.willson@gmail.com"
    multi_day_event.flyer = nil
    multi_day_event.flyer_approved = true
    candi_murray = FactoryBot.create(:person)
    multi_day_event.promoter = candi_murray
    multi_day_event.phone = "911"
    multi_day_event.sanctioned_by = "UCI"
    assert_not_nil(multi_day_event.promoter, "event.promoter")
    multi_day_event.prize_list = 4000
    vanilla = FactoryBot.create(:team)
    multi_day_event.team_id = vanilla.to_param
    trexlertown = FactoryBot.create(:velodrome)
    multi_day_event.velodrome_id = trexlertown.to_param
    multi_day_event.beginner_friendly = true
    multi_day_event.save!

    results = Event.connection.select_one("select * from events where id=#{single_event_1.id}")
    assert_equal("Elkhorn Stage Race", results["name"], "SingleDayEvent name")
    assert_equal(1, results["canceled"], "SingleDayEvent canceled")
    assert_equal_dates("2007-06-19", results["date"], "SingleDayEvent start_date")
    assert_equal("Boise", results["city"], "SingleDayEvent city")
    assert_equal("Mountain Bike", results["discipline"], "SingleDayEvent discipline")
    assert_equal("scott.willson@gmail.com", results["email"], "SingleDayEvent email")
    assert_nil(results["flyer"], "SingleDayEvent flyer")
    assert_equal(1, results["flyer_approved"], "SingleDayEvent flyer")
    assert_equal(candi_murray.id, results["promoter_id"].to_i, "SingleDayEvent promoter_id")
    assert_equal("911", results["phone"], "SingleDayEvent phone")
    assert_equal("UCI", results["sanctioned_by"], "SingleDayEvent sanctioned_by")
    assert_equal("ID", results["state"], "SingleDayEvent state")
    assert_equal("4000", results["prize_list"], "SingleDayEvent prize_list")
    assert_equal(vanilla.id, results["team_id"], "SingleDayEvent team")
    assert_equal(trexlertown.id, results["velodrome_id"], "SingleDayEvent velodrome")
    assert_equal 1, results["beginner_friendly"], "SingleDayEvent beginner_friendly"

    results = Event.connection.select_one("select * from events where id=#{single_event_2.id}")
    assert_equal("Elkhorn Stage Race", results["name"], "SingleDayEvent name")
    assert_equal(1, results["canceled"], "SingleDayEvent canceled")
    assert_equal_dates("2007-06-26", results["date"], "SingleDayEvent start_date")
    assert_equal("Boise", results["city"], "SingleDayEvent city")
    assert_equal("Mountain Bike", results["discipline"], "SingleDayEvent discipline")
    assert_nil(results["flyer"], "SingleDayEvent flyer")
    assert_equal(1, results["flyer_approved"], "SingleDayEvent flyer")
    assert_equal(candi_murray.id, results["promoter_id"].to_i, "SingleDayEvent promoter_id")
    assert_equal("UCI", results["sanctioned_by"], "SingleDayEvent sanctioned_by")
    assert_equal("ID", results["state"], "SingleDayEvent state")
    assert_equal("4000", results["prize_list"], "SingleDayEvent prize_list")
    assert_equal(trexlertown.id, results["velodrome_id"], "SingleDayEvent velodrome")
    assert_equal 1, results["beginner_friendly"], "SingleDayEvent beginner_friendly"

    results = Event.connection.select_one("select * from events where id=#{multi_day_event.id}")
    assert_equal("Elkhorn Stage Race", results["name"], "MultiDayEvent name")
    assert_equal(1, results["canceled"], "MultiDayEvent canceled")
    assert_equal_dates("2007-06-19", results["date"], "MultiDayEvent start_date")
    assert_equal("Boise", results["city"], "MultiDayEvent city")
    assert_equal("Mountain Bike", results["discipline"], "MultiDayEvent discipline")
    assert_nil(results["flyer"], "MultiDayEvent flyer")
    assert_equal(1, results["flyer_approved"], "MultiDayEvent flyer")
    assert_equal(candi_murray.id, results["promoter_id"].to_i, "MultiDayEvent promoter_id")
    assert_equal("UCI", results["sanctioned_by"], "MultiDayEvent sanctioned_by")
    assert_equal("ID", results["state"], "MultiDayEvent state")
    assert_equal("4000", results["prize_list"], "MultiDayEvent prize_list")
    assert_equal(trexlertown.id, results["velodrome_id"], "MultiDayEvent velodrome")
    assert_equal 1, results["beginner_friendly"], "parent beginner_friendly"

    # parent, children all different
    # change parent, children do not change
    single_event_1.reload
    single_event_1.canceled = false
    single_event_1.city = "Paris"
    single_event_1.state = "France"
    single_event_1.discipline = "Cyclocross"
    single_event_1.flyer = "http://www.letour.fr"
    single_event_1.promoter = nil
    single_event_1.sanctioned_by = RacingAssociation.current.short_name
    single_event_1.save!

    results = Event.connection.select_one("select * from events where id=#{single_event_1.id}")
    assert_equal(0, results["canceled"], "SingleDayEvent canceled")

    multi_day_event.reload
    multi_day_event.canceled = true
    multi_day_event.city = "Cazenovia"
    multi_day_event.state = "CT"
    multi_day_event.discipline = "Road"
    multi_day_event.flyer = "http://www.myseasons.com/"
    multi_day_event.sanctioned_by = "UCI"
    brad_ross = FactoryBot.create(:person)
    multi_day_event.promoter = brad_ross
    multi_day_event.save!

    results = Event.connection.select_one("select * from events where id=#{single_event_1.id}")
    assert_equal("Elkhorn Stage Race", results["name"], "SingleDayEvent name")
    assert_equal(0, results["canceled"], "SingleDayEvent canceled")
    assert_equal_dates("2007-06-19", results["date"], "SingleDayEvent start_date")
    assert_equal("Paris", results["city"], "SingleDayEvent city")
    assert_equal("Cyclocross", results["discipline"], "SingleDayEvent discipline")
    assert_equal("http://www.letour.fr", results["flyer"], "SingleDayEvent flyer")
    assert_nil(results["promoter_id"], "SingleDayEvent promoter_id")
    assert_equal(RacingAssociation.current.short_name, results["sanctioned_by"], "SingleDayEvent sanctioned_by")
    assert_equal("France", results["state"], "SingleDayEvent state")

    results = Event.connection.select_one("select * from events where id=#{multi_day_event.id}")
    assert_equal("Elkhorn Stage Race", results["name"], "MultiDayEvent name")
    assert_equal(1, results["canceled"], "MultiDayEvent canceled")
    assert_equal_dates("2007-06-19", results["date"], "MultiDayEvent start_date")
    assert_equal("Cazenovia", results["city"], "MultiDayEvent city")
    assert_equal("Road", results["discipline"], "MultiDayEvent discipline")
    assert_equal("http://www.myseasons.com/", results["flyer"], "MultiDayEvent flyer")
    assert_equal(brad_ross.id, results["promoter_id"].to_i, "MultiDayEvent promoter_id")
    assert_equal("UCI", results["sanctioned_by"], "MultiDayEvent sanctioned_by")
    assert_equal("CT", results["state"], "MultiDayEvent state")
  end

  test "update children should consider blank as nil" do
    parent = MultiDayEvent.create!
    child = parent.children.create!
    assert_nil(parent.flyer, "parent flyer")
    assert_nil(child.flyer, "child flyer")

    parent.flyer = "http://example.com/flyers/1"
    parent.save!
    child.reload
    assert_equal("http://example.com/flyers/1", parent.flyer, "parent flyer")
    assert_equal("http://example.com/flyers/1", child.flyer, "child flyer")

    parent = MultiDayEvent.create!(flyer: "")
    child = parent.children.create!
    child.flyer = nil
    child.save!
    assert_equal("", parent.flyer, "parent flyer")
    assert_nil(child.flyer, "child flyer")

    parent.flyer = "http://example.com/flyers/1"
    parent.save!
    child.reload
    assert_equal("http://example.com/flyers/1", parent.flyer, "parent flyer")
    assert_equal("http://example.com/flyers/1", child.flyer, "child flyer")

    parent = MultiDayEvent.create!
    child = parent.children.create!(flyer: "")
    assert_nil(parent.flyer, "parent flyer")
    assert_nil(child.flyer, "child flyer")

    parent.flyer = "http://example.com/flyers/1"
    parent.save!
    child.reload
    assert_equal("http://example.com/flyers/1", parent.flyer, "parent flyer")
    assert_equal("http://example.com/flyers/1", child.flyer, "child flyer")

    parent = MultiDayEvent.create!(flyer: "")
    child = parent.children.create!(flyer: "")
    assert_equal("", parent.flyer, "parent flyer")
    assert_equal("", child.flyer, "child flyer")

    parent.flyer = "http://example.com/flyers/1"
    parent.save!
    child.reload
    assert_equal("http://example.com/flyers/1", parent.flyer, "parent flyer")
    assert_equal("http://example.com/flyers/1", child.flyer, "child flyer")
  end

  test "full name" do
    stage_race = FactoryBot.create(:stage_race, name: "Mt. Hood Classic")
    assert_equal("Mt. Hood Classic", stage_race.name, "stage_race full_name")
  end

  test "custom create" do
    event = MultiDayEvent.create!(name: "MultiDayEvent", date: Date.new(2002, 6, 12))
    child = event.children.create
    assert_equal_dates(Date.new(2002, 6, 12), event.date, "event date")
    assert_equal_dates(Date.new(2002, 6, 12), child.date, "child event date")
  end

  test "create defaults" do
    parent = MultiDayEvent.create!(flyer_approved: true)
    child = parent.children.create!(flyer_approved: true)
    assert_equal(true, child.flyer_approved?, "parent true, child true, default false")

    parent = MultiDayEvent.create!(flyer_approved: false)
    child = parent.children.create!(flyer_approved: false)
    assert_equal(false, child.flyer_approved?, "parent true, child true, default false")

    parent = MultiDayEvent.create!
    child = parent.children.create!(flyer_approved: true)
    assert_equal(true, child.flyer_approved?, "parent true, child true, default false")

    parent = MultiDayEvent.create!
    child = parent.children.create!(flyer_approved: false)
    assert_equal(false, child.flyer_approved?, "parent true, child true, default false")

    parent = MultiDayEvent.create!(flyer_approved: true)
    child = parent.children.create!
    assert_equal(true, child.flyer_approved?, "parent true, child true, default false")

    parent = MultiDayEvent.create!(flyer_approved: false)
    child = parent.children.create!
    assert_equal(false, child.flyer_approved?, "parent true, child true, default false")

    parent = MultiDayEvent.create!(flyer_approved: false)
    child = parent.children.create!
    assert_equal(false, child.flyer_approved?, "parent true, child true, default false")

    parent = MultiDayEvent.create!(city: nil)
    child = parent.children.create!
    assert_nil(child.city, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!(city: nil)
    child = parent.children.create!(city: nil)
    assert_nil(child.city, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!
    child = parent.children.create!(city: nil)
    assert_nil(child.city, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!
    child = parent.children.create!(city: "city")
    assert_equal("city", child.city, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!
    child = parent.children.create!
    assert_nil(child.city, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!(city: "")
    child = parent.children.create!
    assert_equal("", child.city, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!(city: "")
    child = parent.children.create!(city: "")
    assert_equal("", child.city, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!(city: "")
    child = parent.children.create!(city: nil)
    assert_equal("", child.city, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!(city: "")
    child = parent.children.create!(city: "city")
    assert_equal("city", child.city, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!(city: "city")
    child = parent.children.create!
    assert_equal("city", child.city, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!(city: "city")
    child = parent.children.create!(city: "")
    assert_equal("city", child.city, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!(city: "city")
    child = parent.children.create!(city: nil)
    assert_equal("city", child.city, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!(city: "parent city")
    child = parent.children.create!(city: "city")
    assert_equal("city", child.city, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!(state: nil)
    parent.state = ""
    parent.save!
    assert_equal("", parent.reload.state, "Should be able to set state not blank")
    child = parent.children.create!
    assert_equal("", child.state, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!(state: "")
    child = parent.children.create!(state: "")
    assert_equal("", child.state, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!
    child = parent.children.create!(state: nil)
    assert_equal(RacingAssociation.current.state, child.state, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!
    child = parent.children.create!(state: "NY")
    assert_equal("NY", child.state, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!
    child = parent.children.create!
    assert_equal(RacingAssociation.current.state, child.state, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!(state: "")
    child = parent.children.create!
    assert_equal("", child.state, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!(state: "")
    child = parent.children.create!(state: "")
    assert_equal("", child.state, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!(state: "")
    child = parent.children.create!(state: nil)
    assert_equal("", child.state, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!(state: "")
    child = parent.children.create!(state: "NY")
    assert_equal("NY", child.state, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!(state: "NY")
    child = parent.children.create!
    assert_equal("NY", child.state, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!(state: "NY")
    child = parent.children.create!(state: "")
    assert_equal("NY", child.state, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!(state: "NY")
    child = parent.children.create!(state: nil)
    assert_equal("NY", child.state, "child should inherit parent values unless specified")

    parent = MultiDayEvent.create!(state: "VA")
    child = parent.children.create!(state: "NY")
    assert_equal("NY", child.state, "child should inherit parent values unless specified")
  end

  test "missing parent" do
    series_parent = Series.create!
    assert_not(series_parent.missing_parent?, "missing_parent?")
    assert_nil(series_parent.missing_parent, "missing_parent")

    stage_race = FactoryBot.create(:stage_race)
    assert_not(stage_race.missing_parent?, "missing_parent?")
    assert_nil(stage_race.missing_parent, "missing_parent")
  end

  test "guess type" do
    mt_hood_1 = FactoryBot.build(:event, date: Date.new(2007, 7, 11))
    mt_hood_2 = FactoryBot.build(:event, date: Date.new(2007, 7, 12))
    assert_equal(MultiDayEvent, MultiDayEvent.guess_type([mt_hood_1, mt_hood_2]), "MultiDayEvent")

    banana_belt_1 = FactoryBot.build(:event, date: Date.new(2004, 1, 4))
    banana_belt_2 = FactoryBot.build(:event, date: Date.new(2004, 1, 11))
    banana_belt_3 = FactoryBot.build(:event, date: Date.new(2004, 1, 18))
    assert_equal(Series, MultiDayEvent.guess_type([banana_belt_1, banana_belt_2, banana_belt_3]), "Series")

    pir = FactoryBot.build(:event, date: Date.new(2005, 7, 5))
    pir_2 = FactoryBot.build(:event, date: Date.new(2005, 7, 12))
    assert_equal(WeeklySeries, MultiDayEvent.guess_type([pir, pir_2]), "WeeklySeries")
  end

  test "completed" do
    parent_event = MultiDayEvent.create!
    assert_not(parent_event.completed?, "New event should not be completed")

    parent_event.children.create!
    parent_event.children.create!
    parent_event.children.create!

    parent_event = Event.find(parent_event.id)
    assert_not(parent_event.completed?, "Event with all children with no results should not be completed")

    cat_4_women = FactoryBot.create(:category)
    parent_event.children.first.races.create!(category: cat_4_women).results.create!
    parent_event = Event.find(parent_event.id)
    assert_not(parent_event.completed?, "Event with only one child with results should not be completed")

    parent_event.children.each { |event| event.races.create!(category: cat_4_women).results.create! }
    parent_event = Event.find(parent_event.id)
    assert(parent_event.completed?, "Event with all children with results should be completed")
  end

  test "child event dates" do
    parent_event = MultiDayEvent.create!(date: Date.new(2007, 9, 19))
    assert_equal(Date.new(2007, 9, 19), parent_event.date, "Parent MultiDayEvent date after create")

    single_day_event = parent_event.children.create!
    assert_equal(Date.new(2007, 9, 19), single_day_event.date, "New SingleDayEvent child date shold match parent")

    event = single_day_event.children.create!
    assert_equal(Date.new(2007, 9, 19), event.date, "New Event child date shold match parent")
  end

  test "propagate races" do
    series = FactoryBot.create(:series)
    banana_belt_1 = series.children.create!
    banana_belt_2 = series.children.create!
    banana_belt_3 = series.children.create!

    sr_p_1_2 = FactoryBot.create(:category)
    senior_women = FactoryBot.create(:category)
    series.races.create!(category: sr_p_1_2)
    series.races.create!(category: senior_women)
    banana_belt_1.races.create!(category: sr_p_1_2)

    series.propagate_races

    assert_equal 2, banana_belt_1.races.size, "banana_belt_1 races"
    assert banana_belt_1.races.any? { |r| r.category == sr_p_1_2 }, "banana_belt_1 race category"
    assert banana_belt_1.races.any? { |r| r.category == senior_women }, "banana_belt_1 race category"

    assert_equal 2, banana_belt_2.races.reload.size, "banana_belt_2 races"
    assert banana_belt_2.races.any? { |r| r.category == sr_p_1_2 }, "banana_belt_2 race category"
    assert banana_belt_2.races.any? { |r| r.category == senior_women }, "banana_belt_2 race category"

    assert_equal 2, banana_belt_3.races.reload.size, "banana_belt_3 races"
    assert banana_belt_3.races.any? { |r| r.category == sr_p_1_2 }, "banana_belt_3 race category"
    assert banana_belt_3.races.any? { |r| r.category == senior_women }, "banana_belt_3 race category"
  end
end
