require File.dirname(__FILE__) + '/../test_helper'

class Cat4WomensRaceSeriesTest < ActiveSupport::TestCase
  
  def test_recalculate_no_results
    results_baseline_count = Result.count
    assert_equal(0, Cat4WomensRaceSeries.count, "Cat4WomensRaceSeries standings before recalculate")
    assert_equal(11, Result.count, "Total count of results in DB before Cat4WomensRaceSeries recalculate")
    Cat4WomensRaceSeries.recalculate(2004)
    bar = Cat4WomensRaceSeries.find(:first, :conditions => ['date = ?', Date.new(2004, 1, 1)])
    assert_not_nil(bar, "2004 Cat4WomensRaceSeries after recalculate")
    assert_equal(1, Cat4WomensRaceSeries.count, "Cat4WomensRaceSeries events after recalculate")
    assert_equal(1, bar.standings.count, "Cat4WomensRaceSeries standings after recalculate")
    assert_equal(11, Result.count, "Total count of results in DB")
    # Should delete old Cat4WomensRaceSeries
    Cat4WomensRaceSeries.recalculate(2004)
    assert_equal(1, Cat4WomensRaceSeries.count, "Cat4WomensRaceSeries events after recalculate")
    bar = Cat4WomensRaceSeries.find(:first, :conditions => ['date = ?', Date.new(2004, 1, 1)])
    assert_not_nil(bar, "2004 Cat4WomensRaceSeries after recalculate")
    assert_equal(1, bar.standings.count, "Cat4WomensRaceSeries standings after recalculate")
    assert_equal(Date.new(2004, 1, 1), bar.date, "2004 Cat4WomensRaceSeries date")
    assert_equal("2004 Cat 4 Womens Race Series", bar.name, "2004 Bar name")
    assert_equal_dates(Date.today, bar.updated_at, "Cat4WomensRaceSeries last updated")
    assert_equal(11, Result.count, "Total count of results in DB")    
  end
end