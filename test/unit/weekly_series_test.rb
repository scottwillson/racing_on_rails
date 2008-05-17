require File.dirname(__FILE__) + '/../test_helper'

class WeeklySeriesTest < ActiveSupport::TestCase
  
  def test_new
    pir = WeeklySeries.create!(
      :date => Date.new(2008, 4, 1), :name => 'Tuesday PIR', :discipline => 'Road', :flyer_approved => true
    )
    assert(pir.valid?, "PIR valid?")
    assert(!pir.new_record?, "PIR new?")
    assert_equal(0, pir.events.size, 'PIR events')

    Date.new(2008, 4, 1).step(Date.new(2008, 10, 21), 7) {|date|
      individual_pir = pir.events.create(:date => date, :name => 'Tuesday PIR', :discipline => 'Road', :flyer_approved => true)
      assert(individual_pir.valid?, "PIR valid?")
      assert(!individual_pir.new_record?, "PIR new?")
      assert_equal(pir, individual_pir.parent, "PIR parent")
      assert_equal(date, individual_pir.date, 'New single day of PIR date')
    }
    pir.reload
    
    assert_equal(30, pir.events.size, 'PIR events')
    date = WeeklySeries.connection.select_value("select date from events where id = #{pir.id}")
    assert_equal('2008-04-01', date, 'PIR data in database')
    
    assert_equal(Date.new(2008, 4, 1), pir.start_date, 'PIR start date')
    assert_equal(Date.new(2008, 4, 1), pir.date, 'PIR date')
    assert_equal(Date.new(2008, 10, 21), pir.end_date, 'PIR end date')
  end
  
  def test_days_of_week
    weekly_series = WeeklySeries.new
    weekly_series.days_of_week << Date.new(2006, 7, 3)
    assert_same_elements([Date.new(2006, 7, 3)], weekly_series.days_of_week, 'Days of week')
    assert_equal('Mon', weekly_series.days_of_week_s, 'Days of week as String')

    weekly_series.days_of_week << Date.new(2006, 7, 4)
    assert_same_elements([Date.new(2006, 7, 3), Date.new(2006, 7, 4)], weekly_series.days_of_week, 'Days of week')
    assert_equal('M/Tu', weekly_series.days_of_week_s, 'Days of week as String')

    weekly_series.days_of_week << Date.new(2006, 7, 10)
    assert_same_elements([Date.new(2006, 7, 3), Date.new(2006, 7, 4), Date.new(2006, 7, 10)], weekly_series.days_of_week, 'Days of week')
    assert_equal('M/Tu', weekly_series.days_of_week_s, 'Days of week as String')

    weekly_series.days_of_week << Date.new(2006, 7, 7)
    weekly_series.days_of_week << Date.new(2006, 7, 6)
    assert_same_elements([Date.new(2006, 7, 3), Date.new(2006, 7, 4), Date.new(2006, 7, 10), Date.new(2006, 7, 6), Date.new(2006, 7, 7)], weekly_series.days_of_week, 'Days of week')
    assert_equal('M/Tu/Th/F', weekly_series.days_of_week_s, 'Days of week as String')
  end
  
  def test_friendly_class_name
    event = WeeklySeries.new
    assert_equal("Weekly Series", event.friendly_class_name, "friendly_class_name")
  end
  
  def test_missing_children
    assert(!events(:pir_series).missing_children?, "PIR should have no missing children")
    assert(events(:pir_series).missing_children.empty?, "PIR should have no missing children")
  end
  
  def test_flyer_settings_propogate_to_children
    pir = WeeklySeries.create!(:date => Date.new(2008, 4, 1), :name => 'So OR Champs')
    assert_nil(pir.flyer, "flyer should default to blank")
    assert(!pir.flyer_approved?, "flyer should default to not approved")

    new_child = pir.events.create!
    new_child.reload
    assert_nil(new_child.flyer, "child event flyer should same as parent")
    assert(!new_child.flyer_approved?, "child event flyer approval should same as parent")
    
    pir.flyer = "http://www.flyers.com"
    pir.flyer_approved = true
    pir.save!
    pir.reload
    assert_equal("http://www.flyers.com", pir.flyer, "parent flyer")
    assert(pir.flyer_approved?, "parent flyer approval")
    # This is now existing child, actually ....
    new_child.reload
    assert_equal("http://www.flyers.com", new_child.flyer, "child event flyer should same as parent")
    assert(new_child.flyer_approved?, "child event flyer approval should same as parent")

    new_child = pir.events.create!
    new_child.reload
    assert_equal("http://www.flyers.com", new_child.flyer, "child event flyer should same as parent")
    assert(new_child.flyer_approved?, "child event flyer approval should same as parent")
  end
end