require File.expand_path("../../../../test_helper", __FILE__)

# :stopdoc:
class Cat4WomensRaceSeriesTest < ActiveSupport::TestCase
  def test_calculate_omnium
    series = Cat4WomensRaceSeries.create!(:date => Date.new(2005))
    omnium = MultiDayEvent.create!(:date => Date.new(2005))
    series.source_events << omnium
    
    road_race = omnium.children.create!(:date => Date.new(2005))
    women_cat_4 = Category.find_or_create_by_name("Category 4 Women")
    person = FactoryGirl.create(:person)
    omnium.races.create!(:category => women_cat_4).results.create!(:place => 1, :person => person)
    road_race.races.create!(:category => women_cat_4).results.create!(:place => 1, :person => person)
    
    Cat4WomensRaceSeries.calculate!(2005)
    result = series.races.first.results.first
    assert_equal 115, result.points, "Should have points for omnium only"
    assert_equal 2, result.scores.size, "Should have one score"
  end
  
  def test_calculate_omnium_no_participation_points
    RacingAssociation.current.award_cat4_participation_points = false
    series = Cat4WomensRaceSeries.create!(:date => Date.new(2005))
    omnium = MultiDayEvent.create!(:date => Date.new(2005))
    series.source_events << omnium
    
    road_race = omnium.children.create!(:date => Date.new(2005))
    women_cat_4 = Category.find_or_create_by_name("Category 4 Women")
    person = FactoryGirl.create(:person)
    omnium.races.create!(:category => women_cat_4).results.create!(:place => 1, :person => person)
    road_race.races.create!(:category => women_cat_4).results.create!(:place => 1, :person => person)
    
    Cat4WomensRaceSeries.calculate!(2005)
    result = series.races.first.results.first
    assert_equal 100, result.points, "Should have points for omnium only"
    assert_equal 1, result.scores.size, "Should have one score"
  end

  def test_calculate
    setup_scenario

    assert_difference "Result.count", 2 do
      Cat4WomensRaceSeries.calculate!(2004)
    end
    assert_equal(1, Cat4WomensRaceSeries.count, "Cat4WomensRaceSeries events after calculate!")
    bar = Cat4WomensRaceSeries.find_for_year(2004)
    assert_not_nil(bar, "2004 Cat4WomensRaceSeries after calculate!")
    assert_equal_dates(Date.new(2004, 1, 1), bar.date, "2004 Cat4WomensRaceSeries date")
    assert_equal_dates(Date.new(2004, 12, 31), bar.end_date, "2004 Cat4WomensRaceSeries date")
    assert_equal("2004 Cat 4 Womens Race Series", bar.name, "2004 Bar name")
    assert_equal_dates(Time.zone.now, bar.updated_at, "Cat4WomensRaceSeries last updated")

    assert_equal(1, bar.races.size, 'Races')
    race = bar.races.first
    assert_equal(@category_4_women, race.category, 'Category')
    assert_equal(2, race.results.size, 'Category 4 Women race results')

    race.results.sort!
    assert_equal('1', race.results[0].place, 'Place')
    assert_equal(@alice, race.results[0].person, 'Person')
    assert_equal(117, race.results[0].points, 'Points')

    assert_equal('2', race.results[1].place, 'Place')
    assert_equal(@molly, race.results[1].person, 'Person')
    assert_equal(65, race.results[1].points, 'Points')
  end
  
  def test_do_not_award_cat4_participation_points
    RacingAssociation.current.award_cat4_participation_points = false
    setup_scenario

    assert_difference "Result.count", 1 do
      Cat4WomensRaceSeries.calculate!(2004)
    end
    assert_equal(1, Cat4WomensRaceSeries.count, "Cat4WomensRaceSeries events after calculate!")
    bar = Cat4WomensRaceSeries.first(:conditions => ['date = ?', Date.new(2004, 1, 1)])
    assert_not_nil(bar, "2004 Cat4WomensRaceSeries after calculate!")
    assert_equal(Date.new(2004, 1, 1), bar.date, "2004 Cat4WomensRaceSeries date")
    assert_equal("2004 Cat 4 Womens Race Series", bar.name, "2004 Bar name")
    assert_equal_dates(Time.zone.today, bar.updated_at, "Cat4WomensRaceSeries last updated")
    
    assert_equal(1, bar.races.size, 'Races')
    
    race = bar.races.first
    assert_equal(@category_4_women, race.category, 'Category')
    assert_equal(1, race.results.size, 'Category 4 Women race results')

    race.results.sort!
    assert_equal('1', race.results[0].place, 'Place')
    assert_equal(@alice, race.results[0].person, 'Person')
    assert_equal(72, race.results[0].points, 'Points')
  end
  
  def test_more_than_one_cat_4_race
    series = Cat4WomensRaceSeries.create(:date => Date.new(2004))
    event = SingleDayEvent.create(:date => Date.new(2004))
    women_cat_4 = Category.find_or_create_by_name("Category 4 Women")
    race_1 = event.races.create!(:category => women_cat_4)
    molly = FactoryGirl.create(:person)
    race_1.results.create!(:place => "2", :person => molly)
    race_2 = event.races.create!(:category => women_cat_4)
    alice = FactoryGirl.create(:person)
    race_2.results.create!(:place => "5", :person => alice)
    series.source_events << event

    Cat4WomensRaceSeries.calculate!(2004)
    series.reload    
    assert_equal(1, series.races.size, 'Races')
    
    race = series.races.first
    assert_equal(2, race.results.size, 'Category 4 Women race results')
    race.results.sort!
    assert_equal('1', race.results[0].place, 'Place')
    assert_equal(molly, race.results[0].person, 'Person')
    assert_equal(95, race.results[0].points, 'Points')
    assert_equal('2', race.results[1].place, 'Place')
    assert_equal(alice, race.results[1].person, 'Person')
    assert_equal(80, race.results[1].points, 'Points')
  end
  
  def test_custom_category_name
    racing_association = RacingAssociation.current
    category_4_women = Category.find_or_create_by_name(:name => "Women Cat 4")
    racing_association.cat4_womens_race_series_category = category_4_women
    racing_association.save!
    
    series = Cat4WomensRaceSeries.create(:date => Date.new(2004))
    event = SingleDayEvent.create(:date => Date.new(2004))
    race_1 = event.races.create!(:category => category_4_women)
    molly = FactoryGirl.create(:person)
    race_1.results.create!(:place => "2", :person => molly)
    race_2 = event.races.create!(:category => category_4_women)
    alice = FactoryGirl.create(:person)
    race_2.results.create!(:place => "5", :person => alice)
    series.source_events << event

    Cat4WomensRaceSeries.calculate!(2004)
    series.reload    
    assert_equal(1, series.races.size, 'Races')
    
    race = series.races.first
    assert_equal(2, race.results.size, 'Category 4 Women race results')
    race.results.sort!
    assert_equal('1', race.results[0].place, 'Place')
    assert_equal(molly, race.results[0].person, 'Person')
    assert_equal(95, race.results[0].points, 'Points')
    assert_equal('2', race.results[1].place, 'Place')
    assert_equal(alice, race.results[1].person, 'Person')
    assert_equal(80, race.results[1].points, 'Points')
  end
  
  def test_child_events
    series = Cat4WomensRaceSeries.create!(:date => Date.new(2004))
    event = SingleDayEvent.create!(:discipline => "Time Trial", :date => Date.new(2004))
    series.source_events << event
    
    # Non Cat 4 Women race in parent event
    FactoryGirl.create(:result, :place => "1")
    
    fourteen_mile = event.children.create!
    assert_equal 1, fourteen_mile.bar_points, "Children should recieve BAR points"
    assert_equal Date.new(2004), fourteen_mile.date, "Children should share parent date"
    women_cat_4 = Category.find_by_name("Category 4 Women")
    race = fourteen_mile.races.create!(:category => women_cat_4)
    alice = FactoryGirl.create(:person)
    race.results.create!(:place => 3, :time => 3000, :person => alice)
    seven_mile = event.children.create!
    race = seven_mile.races.create!(:category => women_cat_4)
    molly = FactoryGirl.create(:person)
    race.results.create!(:place => 1, :time => 1500, :person => molly)
    assert series.source_events.include?(event), "Event should be in series"
    
    Cat4WomensRaceSeries.calculate!(2004)

    series.reload
    race = series.races.first
    assert_equal(2, race.results.size, 'Category 4 Women race results')
    race.results.sort!
    assert_equal('1', race.results[0].place, 'Place')
    assert_equal(molly, race.results[0].person, 'Person')
    assert_equal(100, race.results[0].points, 'Points')
    assert_equal('2', race.results[1].place, 'Place')
    assert_equal(alice, race.results[1].person, 'Person')
    assert_equal(90, race.results[1].points, 'Points')
  end
  
  def setup_scenario
    @category_4_women = Category.find_or_create_by_name("Category 4 Women")
    series = Cat4WomensRaceSeries.create(:date => Date.new(2004))
    banana_belt = FactoryGirl.create(:series_event, :date => Date.new(2004))
    series.source_events << banana_belt
    kings_valley_2004 = FactoryGirl.create(:event, :date => Date.new(2004))
    series.source_events << kings_valley_2004
    
    banana_belt_women_cat_4 = banana_belt.races.create!(:category => @category_4_women)
    @alice = FactoryGirl.create(:person)
    banana_belt_women_cat_4.results.create!(:person => @alice, :place => '7')

    # All finishes count
    @molly = FactoryGirl.create(:person)
    banana_belt_women_cat_4.results.create!(:person => @molly, :place => '17')

    kv_women_cat_4 = kings_valley_2004.races.create!(:category => @category_4_women)
    kv_women_cat_4.results.create!(:person => @molly, :place => '205')
    
    # ... but not DNFs, DQs, etc...
    matson = FactoryGirl.create(:person)
    kv_women_cat_4.results.create!(:person => matson, :place => 'DQ')
    
    # ... and not results in different years
    wrong_year_event = SingleDayEvent.create!(:name => "Boat Street CT 2003", :date => "2003-12-31")
    race = wrong_year_event.races.create!(:category => @category_4_women)
    race.results.create!(:person => @molly, :place => "1")    

    wrong_year_event = SingleDayEvent.create!(:name => "Boat Street CT 2005", :date => "2005-01-01")
    race = wrong_year_event.races.create!(:category => @category_4_women)
    race.results.create!(:person => @alice, :place => "2")
    
    # WSBA results count for participation points
    other_wsba_event = SingleDayEvent.create!(:name => "Boat Street CT 2004", :date => "2004-06-26")
    race = other_wsba_event.races.create!(:category => @category_4_women)
    race.results.create!(:person => @molly, :place => "18")    

    # Blank results count -- finished, but don't know where
    race.results.create!(:person => @alice, :place => "")
    
    # Non-WSBA results count for participation points
    non_wsba_event = SingleDayEvent.create!(:name => "Classique des Alpes", :date => "2004-09-16", :sanctioned_by => "UCI")
    race = non_wsba_event.races.create!(:category => @category_4_women)
    race.results.create!(:person => @alice, :place => "56")
    
    # Other categories don't count
    category_3_women = FactoryGirl.create(:category, :name => "Women Cat 3")
    banana_belt_category_3_women = banana_belt.races.create!(:category => category_3_women)
    banana_belt_category_3_women.results.create!(:person => @alice, :place => '1')
    
    # Other competitions don't count!
    RiderRankings.calculate!(2004)
  end
end
