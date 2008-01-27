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

  def test_recalculate
    series = Cat4WomensRaceSeries.create(:date => Date.new(2004))
    banana_belt_standings = standings(:banana_belt)
    series.events << banana_belt_standings.event
    kings_valley_2004 = standings(:kings_valley_2004)
    series.events << kings_valley_2004.event
    
    category_4_women = categories(:cat_4_women)
    banana_belt_category_4_women = banana_belt_standings.races.create!(:category => category_4_women)
    alice = racers(:alice)
    banana_belt_category_4_women.results.create!(:racer => alice, :place => '7')

    # All finishes count
    molly = racers(:molly)
    banana_belt_category_4_women.results.create!(:racer => molly, :place => '17')

    kv_category_4_women = kings_valley_2004.races.create!(:category => category_4_women)
    kv_category_4_women.results.create!(:racer => molly, :place => '205')
    
    # ... but not DNFs, DQs, etc...
    kv_category_4_women.results.create!(:racer => racers(:matson), :place => 'DQ')
    
    # Non-WSBA results count
    
    # Other categories don't count
    category_3_women = categories(:cat_3_women)
    banana_belt_category_3_women = banana_belt_standings.races.create!(:category => category_3_women)
    banana_belt_category_3_women.results.create!(:racer => alice, :place => '1')

    results_baseline_count = Result.count
    assert_equal(1, Cat4WomensRaceSeries.count, "Cat4WomensRaceSeries standings before recalculate (but after create)")
    Cat4WomensRaceSeries.recalculate(2004)
    bar = Cat4WomensRaceSeries.find(:first, :conditions => ['date = ?', Date.new(2004, 1, 1)])
    assert_not_nil(bar, "2004 Cat4WomensRaceSeries after recalculate")
    assert_equal(1, Cat4WomensRaceSeries.count, "Cat4WomensRaceSeries events after recalculate")
    assert_equal(1, bar.standings.count, "Cat4WomensRaceSeries standings after recalculate")
    assert_equal(results_baseline_count + 2, Result.count, "Total count of results in DB")
    # Should delete old Cat4WomensRaceSeries
    Cat4WomensRaceSeries.recalculate(2004)
    assert_equal(1, Cat4WomensRaceSeries.count, "Cat4WomensRaceSeries events after recalculate")
    bar = Cat4WomensRaceSeries.find(:first, :conditions => ['date = ?', Date.new(2004, 1, 1)])
    assert_not_nil(bar, "2004 Cat4WomensRaceSeries after recalculate")
    assert_equal(1, bar.standings.count, "Cat4WomensRaceSeries standings after recalculate")
    assert_equal(Date.new(2004, 1, 1), bar.date, "2004 Cat4WomensRaceSeries date")
    assert_equal("2004 Cat 4 Womens Race Series", bar.name, "2004 Bar name")
    assert_equal_dates(Date.today, bar.updated_at, "Cat4WomensRaceSeries last updated")
    assert_equal(results_baseline_count + 2, Result.count, "Total count of results in DB")
    
    bar_standings = bar.standings.first
    assert_equal(1, bar_standings.races.size, 'Races')
    
    race = bar_standings.races.first
    assert_equal(category_4_women, race.category, 'Category')
    assert_equal(2, race.results.size, 'Category 4 Women race results')

    race.results.sort!
    assert_equal('1', race.results[0].place, 'Place')
    assert_equal(alice, race.results[0].racer, 'Racer')
    assert_equal(72, race.results[0].points, 'Points')

    assert_equal('2', race.results[1].place, 'Place')
    assert_equal(molly, race.results[1].racer, 'Racer')
    assert_equal(50, race.results[1].points, 'Points')
  end
end