require File.dirname(__FILE__) + '/../test_helper'

class WeeklySeriesTest < Test::Unit::TestCase

  def test_new
    WeeklySeries.new.save!
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
  
end