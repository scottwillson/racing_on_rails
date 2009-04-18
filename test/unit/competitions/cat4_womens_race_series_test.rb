require "test_helper"

class Cat4WomensRaceSeriesTest < ActiveSupport::TestCase
  def setup
    @award_cat4_participation_points = ASSOCIATION.award_cat4_participation_points
    ASSOCIATION.award_cat4_participation_points = true
    @cat4_womens_race_series_points = ASSOCIATION.cat4_womens_race_series_points
    ASSOCIATION.cat4_womens_race_series_points = nil
    @cat4_womens_race_series_category = ASSOCIATION.cat4_womens_race_series_category
    ASSOCIATION.cat4_womens_race_series_category = nil
  end
  
  def teardown
    ASSOCIATION.award_cat4_participation_points = @award_cat4_participation_points
    ASSOCIATION.cat4_womens_race_series_points = @cat4_womens_race_series_points
    ASSOCIATION.cat4_womens_race_series_category = @cat4_womens_race_series_category
  end
  
  def test_calculate_no_results
    original_results_count = Result.count
    assert_equal(0, Cat4WomensRaceSeries.count, "Cat4WomensRaceSeries before calculate!")
    Cat4WomensRaceSeries.calculate!(2004)
    bar = Cat4WomensRaceSeries.find(:first, :conditions => ['date = ?', Date.new(2004, 1, 1)])
    assert_not_nil(bar, "2004 Cat4WomensRaceSeries after calculate!")
    assert_equal(1, Cat4WomensRaceSeries.count, "Cat4WomensRaceSeries events after calculate!")
    assert_equal(original_results_count, Result.count, "Total count of results in DB")
    # Should delete old Cat4WomensRaceSeries
    Cat4WomensRaceSeries.calculate!(2004)
    assert_equal(1, Cat4WomensRaceSeries.count, "Cat4WomensRaceSeries events after calculate!")
    bar = Cat4WomensRaceSeries.find(:first, :conditions => ['date = ?', Date.new(2004, 1, 1)])
    assert_not_nil(bar, "2004 Cat4WomensRaceSeries after calculate!")
    assert_equal(Date.new(2004, 1, 1), bar.date, "2004 Cat4WomensRaceSeries date")
    assert_equal("2004 Cat 4 Womens Race Series", bar.name, "2004 Bar name")
    assert_equal_dates(Date.today, bar.updated_at, "Cat4WomensRaceSeries last updated")
    assert_equal(original_results_count, Result.count, "Total count of results in DB")    
  end

  def test_calculate
    series = Cat4WomensRaceSeries.create(:date => Date.new(2004))
    banana_belt = events(:banana_belt_1)
    series.source_events << banana_belt
    kings_valley_2004 = events(:kings_valley_2004)
    series.source_events << kings_valley_2004
    
    women_cat_4 = Category.find_by_name("Women Cat 4")
    banana_belt_women_cat_4 = banana_belt.races.create!(:category => women_cat_4)
    alice = racers(:alice)
    banana_belt_women_cat_4.results.create!(:racer => alice, :place => '7')

    # All finishes count
    molly = racers(:molly)
    banana_belt_women_cat_4.results.create!(:racer => molly, :place => '17')

    kv_women_cat_4 = kings_valley_2004.races.create!(:category => women_cat_4)
    kv_women_cat_4.results.create!(:racer => molly, :place => '205')
    
    # ... but not DNFs, DQs, etc...
    kv_women_cat_4.results.create!(:racer => racers(:matson), :place => 'DQ')
    
    # ... and not results in different years
    wrong_year_event = SingleDayEvent.create!(:name => "Boat Street CT", :date => "2003-12-31")
    race = wrong_year_event.races.create!(:category => women_cat_4)
    race.results.create!(:racer => molly, :place => "1")    

    wrong_year_event = SingleDayEvent.create!(:name => "Boat Street CT", :date => "2005-01-01")
    race = wrong_year_event.races.create!(:category => women_cat_4)
    race.results.create!(:racer => alice, :place => "2")
    
    # WSBA results count for participation points
    other_wsba_event = SingleDayEvent.create!(:name => "Boat Street CT", :date => "2004-06-26")
    race = other_wsba_event.races.create!(:category => women_cat_4)
    race.results.create!(:racer => molly, :place => "18")    

    # Blank results count -- finished, but don't know where
    race.results.create!(:racer => alice, :place => "")
    
    # Non-WSBA results count for participation points
    non_wsba_event = SingleDayEvent.create!(:name => "Classique des Alpes", :date => "2004-09-16", :sanctioned_by => "FCF")
    race = non_wsba_event.races.create!(:category => women_cat_4)
    race.results.create!(:racer => alice, :place => "56")
    
    # Other categories don't count
    category_3_women = categories(:cat_3_women)
    banana_belt_category_3_women = banana_belt.races.create!(:category => category_3_women)
    banana_belt_category_3_women.results.create!(:racer => alice, :place => '1')
    
    # Other competitions don't count!
    RiderRankings.calculate!(2004)

    results_baseline_count = Result.count
    assert_equal(1, Cat4WomensRaceSeries.count, "Cat4WomensRaceSeries before calculate! (but after create)")
    Cat4WomensRaceSeries.calculate!(2004)
    bar = Cat4WomensRaceSeries.find(:first, :conditions => ['date = ?', Date.new(2004, 1, 1)])
    assert_not_nil(bar, "2004 Cat4WomensRaceSeries after calculate!")
    assert_equal(1, Cat4WomensRaceSeries.count, "Cat4WomensRaceSeries events after calculate!")
    assert_equal(results_baseline_count + 2, Result.count, "Total count of results in DB")
    # Should delete old Cat4WomensRaceSeries
    Cat4WomensRaceSeries.calculate!(2004)
    assert_equal(1, Cat4WomensRaceSeries.count, "Cat4WomensRaceSeries events after calculate!")
    bar = Cat4WomensRaceSeries.find(:first, :conditions => ['date = ?', Date.new(2004, 1, 1)])
    assert_not_nil(bar, "2004 Cat4WomensRaceSeries after calculate!")
    assert_equal(Date.new(2004, 1, 1), bar.date, "2004 Cat4WomensRaceSeries date")
    assert_equal("2004 Cat 4 Womens Race Series", bar.name, "2004 Bar name")
    assert_equal_dates(Date.today, bar.updated_at, "Cat4WomensRaceSeries last updated")
    assert_equal(results_baseline_count + 2, Result.count, "Total count of results in DB")
    
    assert_equal(1, bar.races.size, 'Races')
    
    race = bar.races.first
    assert_equal(women_cat_4, race.category, 'Category')
    assert_equal(2, race.results.size, 'Category 4 Women race results')

    race.results.sort!
    assert_equal('1', race.results[0].place, 'Place')
    assert_equal(alice, race.results[0].racer, 'Racer')
    assert_equal(102, race.results[0].points, 'Points')

    assert_equal('2', race.results[1].place, 'Place')
    assert_equal(molly, race.results[1].racer, 'Racer')
    assert_equal(65, race.results[1].points, 'Points')
  end
  
  def test_do_no_taward_cat4_participation_points
    ASSOCIATION.award_cat4_participation_points = false

    series = Cat4WomensRaceSeries.create(:date => Date.new(2004))
    banana_belt = events(:banana_belt_1)
    series.source_events << banana_belt
    kings_valley_2004 = events(:kings_valley_2004)
    series.source_events << kings_valley_2004
    
    women_cat_4 = Category.find_by_name("Women Cat 4")
    banana_belt_women_cat_4 = banana_belt.races.create!(:category => women_cat_4)
    alice = racers(:alice)
    banana_belt_women_cat_4.results.create!(:racer => alice, :place => '7')

    # This finish does not count
    molly = racers(:molly)
    banana_belt_women_cat_4.results.create!(:racer => molly, :place => '17')

    kv_women_cat_4 = kings_valley_2004.races.create!(:category => women_cat_4)
    kv_women_cat_4.results.create!(:racer => molly, :place => '205')
    
    # ... but not DNFs, DQs, etc...
    kv_women_cat_4.results.create!(:racer => racers(:matson), :place => 'DQ')
    
    # ... and not results in different years
    wrong_year_event = SingleDayEvent.create!(:name => "Boat Street CT", :date => "2003-12-31")
    race = wrong_year_event.races.create!(:category => women_cat_4)
    race.results.create!(:racer => molly, :place => "1")    

    wrong_year_event = SingleDayEvent.create!(:name => "Boat Street CT", :date => "2005-01-01")
    race = wrong_year_event.races.create!(:category => women_cat_4)
    race.results.create!(:racer => alice, :place => "2")
    
    # No points for non-series races
    other_wsba_event = SingleDayEvent.create!(:name => "Boat Street CT", :date => "2004-06-26")
    race = other_wsba_event.races.create!(:category => women_cat_4)
    race.results.create!(:racer => molly, :place => "18")    

    # Blank results count do not count
    race.results.create!(:racer => alice, :place => "")
    
    # Non-WSBA results do not count for participation points
    non_wsba_event = SingleDayEvent.create!(:name => "Classique des Alpes", :date => "2004-09-16", :sanctioned_by => "FCF")
    race = non_wsba_event.races.create!(:category => women_cat_4)
    race.results.create!(:racer => alice, :place => "56")
    
    # Other categories don't count
    category_3_women = categories(:cat_3_women)
    banana_belt_category_3_women = banana_belt.races.create!(:category => category_3_women)
    banana_belt_category_3_women.results.create!(:racer => alice, :place => '1')
    
    # Other competitions don't count!
    RiderRankings.calculate!(2004)

    results_baseline_count = Result.count
    assert_equal(1, Cat4WomensRaceSeries.count, "Cat4WomensRaceSeries before calculate! (but after create)")
    Cat4WomensRaceSeries.calculate!(2004)
    bar = Cat4WomensRaceSeries.find(:first, :conditions => ['date = ?', Date.new(2004, 1, 1)])
    assert_not_nil(bar, "2004 Cat4WomensRaceSeries after calculate!")
    assert_equal(1, Cat4WomensRaceSeries.count, "Cat4WomensRaceSeries events after calculate!")
    assert_equal(results_baseline_count + 1, Result.count, "Total count of results in DB")
    # Should delete old Cat4WomensRaceSeries
    Cat4WomensRaceSeries.calculate!(2004)
    assert_equal(1, Cat4WomensRaceSeries.count, "Cat4WomensRaceSeries events after calculate!")
    bar = Cat4WomensRaceSeries.find(:first, :conditions => ['date = ?', Date.new(2004, 1, 1)])
    assert_not_nil(bar, "2004 Cat4WomensRaceSeries after calculate!")
    assert_equal(Date.new(2004, 1, 1), bar.date, "2004 Cat4WomensRaceSeries date")
    assert_equal("2004 Cat 4 Womens Race Series", bar.name, "2004 Bar name")
    assert_equal_dates(Date.today, bar.updated_at, "Cat4WomensRaceSeries last updated")
    assert_equal(results_baseline_count + 1, Result.count, "Total count of results in DB")
    
    assert_equal(1, bar.races.size, 'Races')
    
    race = bar.races.first
    assert_equal(women_cat_4, race.category, 'Category')
    assert_equal(1, race.results.size, 'Category 4 Women race results')

    race.results.sort!
    assert_equal('1', race.results[0].place, 'Place')
    assert_equal(alice, race.results[0].racer, 'Racer')
    assert_equal(72, race.results[0].points, 'Points')
  end
  
  def test_points_for
    series = Cat4WomensRaceSeries.create!
    event = SingleDayEvent.create!
    series.source_events << event
    women_cat_4 = Category.find_by_name("Women Cat 4")
    race = event.races.create!(:category => women_cat_4)

    source_result = race.results.create!(:place => "1")
    points = series.points_for(source_result)
    assert_equal(100, points, "Points for 1st")

    source_result = race.results.create!(:place => "10")
    points = series.points_for(source_result)
    assert_equal(66, points, "Points for 10th")

    source_result = race.results.create!(:place => "15")
    points = series.points_for(source_result)
    assert_equal(56, points, "Points for 15th")

    source_result = race.results.create!(:place => "16")
    points = series.points_for(source_result)
    assert_equal(25, points, "Points for 16th")

    source_result = race.results.create!(:place => "17")
    points = series.points_for(source_result)
    assert_equal(25, points, "Points for 17th")
  end
end