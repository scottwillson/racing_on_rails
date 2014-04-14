require File.expand_path("../../../test_helper", __FILE__)

# :stopdoc:
class WeeklySeriesTest < ActiveSupport::TestCase
  def test_new
    pir = WeeklySeries.create!(
      date: Date.new(2008, 4, 1), name: 'Tuesday PIR', discipline: 'Road', flyer_approved: true
    )
    assert(pir.valid?, "PIR valid?")
    assert(!pir.new_record?, "PIR new?")
    assert_equal(0, pir.children.size, 'PIR events')
    assert_equal(1, pir.bar_points, "Weekly Series BAR points")
    category = FactoryGirl.create(:category)
    race = pir.races.create!(category: category)
    assert_equal(1, race.bar_points, "Weekly Series race BAR points")

    Date.new(2008, 4, 1).step(Date.new(2008, 10, 21), 7) { |date|
      individual_pir = pir.children.create!(date: date, name: 'Tuesday PIR', discipline: 'Road', flyer_approved: true)
      assert(individual_pir.valid?, "PIR valid?")
      assert(!individual_pir.new_record?, "PIR new?")
      assert_equal(pir, individual_pir.parent, "PIR parent")
      assert_equal(date, individual_pir.date, 'New single day of PIR date')
      assert_equal(0, individual_pir.bar_points, "Weekly Series BAR points")
      race = individual_pir.races.create!(category: category)
      assert_equal(0, race.bar_points, "Weekly Series race BAR points")
    }
    pir.reload

    assert_equal(30, pir.children.size, 'PIR events')
    date = WeeklySeries.connection.select_value("select date from events where id = #{pir.id}")
    assert_equal_dates('2008-04-01', date, 'PIR data in database')

    assert_equal(Date.new(2008, 4, 1), pir.start_date, 'PIR start date')
    assert_equal(Date.new(2008, 4, 1), pir.date, 'PIR date')
    assert_equal(Date.new(2008, 10, 21), pir.end_date, 'PIR end date')
  end

  def test_days_of_week_as_string
    weekly_series = WeeklySeries.create!
    weekly_series.children.create!(date: Date.new(2006, 7, 3))
    dates = Date.new(2006, 7, 1)..Date.new(2006, 7, 15)
    assert_equal('Mon', weekly_series.days_of_week_as_string(dates, true), 'Days of week as String')

    weekly_series.children.create!(date: Date.new(2006, 7, 4))
    assert_equal('M/Tu', weekly_series.days_of_week_as_string(dates, true), 'Days of week as String')

    weekly_series.children.create!(date: Date.new(2006, 7, 10))
    assert_equal('M/Tu', weekly_series.days_of_week_as_string(dates, true), 'Days of week as String')

    weekly_series.children.create!(date: Date.new(2006, 7, 7))
    weekly_series.children.create!(date: Date.new(2006, 7, 6))
    assert_equal('M/Tu/Th/F', weekly_series.days_of_week_as_string(dates, true), 'Days of week as String')

    dates = Date.new(2006, 1, 1)..Date.new(2006, 6, 15)
    assert_equal('', weekly_series.days_of_week_as_string(dates, true), 'Days of week as String')

    dates = Date.new(2006, 8, 1)..Date.new(2006, 8, 15)
    assert_equal('', weekly_series.days_of_week_as_string(dates, true), 'Days of week as String')

    dates = Date.new(2006, 7, 1)..Date.new(2006, 7, 5)
    assert_equal('M/Tu', weekly_series.days_of_week_as_string(dates, true), 'Days of week as String')
    assert_equal('M/Tu', weekly_series.days_of_week_as_string(dates, false), 'Days of week as String')
    assert_equal('M/Tu', weekly_series.days_of_week_as_string(dates), 'Days of week as String')
  end

  def test_earliest_day_of_week
    weekly_series = WeeklySeries.create!
    weekly_series.children.create!(date: Date.new(2006, 7, 3))
    dates = Date.new(2006, 7, 1)..Date.new(2006, 7, 15)
    assert_equal(1, weekly_series.earliest_day_of_week(dates, true), 'earliest_day_of_week')

    weekly_series.children.create!(date: Date.new(2006, 7, 5))
    dates = Date.new(2006, 7, 4)..Date.new(2006, 7, 15)
    assert_equal(3, weekly_series.earliest_day_of_week(dates, true), 'earliest_day_of_week')

    weekly_series.children.create!(date: Date.new(2006, 7, 10))
    weekly_series.children.create!(date: Date.new(2006, 7, 11))
    weekly_series.children.create!(date: Date.new(2006, 7, 12))
    dates = Date.new(2006, 7, 1)..Date.new(2006, 7, 15)
    assert_equal(1, weekly_series.earliest_day_of_week(dates, true), 'earliest_day_of_week')
    dates = Date.new(2006, 7, 4)..Date.new(2006, 7, 9)
    assert_equal(3, weekly_series.earliest_day_of_week(dates, true), 'earliest_day_of_week')

    assert_equal(-1, weekly_series.earliest_day_of_week(Date.new(2006, 7, 1)..Date.new(2006, 7, 2), true), 'earliest_day_of_week')
  end

  def test_day_of_week
    weekly_series = WeeklySeries.create!
    weekly_series.children.create!(date: Date.new(2006, 7, 3))
    Date.new(2006, 7, 1)..Date.new(2006, 7, 15)
    assert_equal(1, weekly_series.day_of_week, 'day_of_week')

    weekly_series.children.create!(date: Date.new(2006, 7, 10))
    weekly_series.children.create!(date: Date.new(2006, 7, 11))
    weekly_series.children.create!(date: Date.new(2006, 7, 12))
    assert_equal(1, weekly_series.day_of_week, 'day_of_week')

    weekly_series = WeeklySeries.create!(date: Date.new(2006, 7, 4))
    assert_equal(2, weekly_series.day_of_week, "day_of_week with no children")
  end

  def test_flyer_settings_propogate_to_children
    so_or_champs = WeeklySeries.create!(date: Date.new(2008, 4, 1), name: 'So OR Champs')
    assert_nil(so_or_champs.flyer, "flyer should default to blank")
    assert(!so_or_champs.flyer_approved?, "flyer should default to not approved")

    child = so_or_champs.children.create!
    child.reload
    assert_nil(child.flyer, "child event flyer should same as parent")
    assert(!child.flyer_approved?, "child event flyer approval should same as parent")

    so_or_champs.flyer = "http://www.flyers.com"
    so_or_champs.flyer_approved = true
    so_or_champs.save!
    so_or_champs.reload
    assert_equal("http://www.flyers.com", so_or_champs.flyer, "parent flyer")
    assert(so_or_champs.flyer_approved?, "parent flyer approval")

    child.reload
    assert_equal("http://www.flyers.com", child.flyer, "child event flyer should same as parent")
    assert(child.flyer_approved?, "child event flyer approval should same as parent")

    new_child = so_or_champs.children.create!
    assert_equal("http://www.flyers.com", new_child.flyer, "child event flyer should same as parent")
    assert(new_child.flyer_approved?, "child event flyer approval should same as parent")
    new_child.reload
    assert_equal("http://www.flyers.com", new_child.flyer, "child event flyer should same as parent")
    assert(new_child.flyer_approved?, "child event flyer approval should same as parent")
  end
end
