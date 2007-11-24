require File.dirname(__FILE__) + '/../test_helper'

class AgeGradedBarTest < ActiveSupport::TestCase
  
  def test_recalculate_no_results
    results_baseline_count = Result.count
    assert_equal(0, AgeGradedBar.count, "AgeGradedBar standings before recalculate")
    assert_equal(11, Result.count, "Total count of results in DB before AgeGradedBar recalculate")
    AgeGradedBar.recalculate(2004)
    bar = AgeGradedBar.find(:first, :conditions => ['date = ?', Date.new(2004, 1, 1)])
    assert_not_nil(bar, "2004 AgeGradedBar after recalculate")
    assert_equal(1, AgeGradedBar.count, "AgeGradedBar events after recalculate")
    assert_equal(1, bar.standings.count, "AgeGradedBar standings after recalculate")
    assert_equal(11, Result.count, "Total count of results in DB")
    # Should delete old AgeGradedBar
    AgeGradedBar.recalculate(2004)
    assert_equal(1, AgeGradedBar.count, "AgeGradedBar events after recalculate")
    bar = AgeGradedBar.find(:first, :conditions => ['date = ?', Date.new(2004, 1, 1)])
    assert_not_nil(bar, "2004 AgeGradedBar after recalculate")
    assert_equal(1, bar.standings.count, "AgeGradedBar standings after recalculate")
    assert_equal(Date.new(2004, 1, 1), bar.date, "2004 AgeGradedBar date")
    assert_equal("2004 Age Graded BAR", bar.name, "2004 Bar name")
    assert_equal_dates(Date.today, bar.updated_at, "AgeGradedBar last updated")
    assert_equal(11, Result.count, "Total count of results in DB")    
  end
  
  def test_recalculate
    # Masters 30-34 result
    weaver = racers(:weaver)
    # 32
    weaver.date_of_birth = Date.new(1972)
    weaver.save!    
    banana_belt_standings = standings(:banana_belt)
    masters_men = categories(:masters_men)
    masters_30_34 = Category.find_by_name('Masters Men 30-34')
    banana_belt_masters_30_34 = banana_belt_standings.races.create!(:category => masters_30_34)
    banana_belt_masters_30_34.results.create!(:racer => weaver, :place => '10')
    
    # Masters 35-39 results
    tonkin = racers(:tonkin)
    # 36
    tonkin.date_of_birth = Date.new(1968)
    tonkin.save!
    masters_35_39 = Category.create!(:name => 'Masters Men 35-39', :ages => 35..39, :parent => masters_men)
    banana_belt_masters = banana_belt_standings.races.create!(:category => masters_35_39)
    banana_belt_masters.results.create!(:racer => tonkin, :place => '5')
    
    # Masters 35-39 result, but now is 40+ racing age
    molly = racers(:molly)
    # 39 in 2004 
    molly.date_of_birth = Date.new(1965)
    molly.save!
    banana_belt_masters.results.create!(:racer => molly, :place => '15')
    
    # Racing age is 35, but was 34 on race day
    carl_roberts = Racer.create!(:name => 'Carl Roberts', :date_of_birth => Date.new(1969, 11, 2), :member_from => Date.new(2004), :member_to => Date.new(2004, 12, 31))
    banana_belt_masters.results.create!(:racer => carl_roberts, :place => '11')
    
    # No age, but Masters result
    david_auker = Racer.create!(:name => 'David Auker', :member_from => Date.new(2004), :member_to => Date.new(2004, 12, 31))
    banana_belt_masters.results.create!(:racer => david_auker, :place => '9')
    
    # Result by a 32-year-old and a 36 year-old in a 30-39 race
    standings = events(:banana_belt_2).standings.create!
    masters_30_39 = Category.create!(:name => 'Masters Men 30-39', :ages => 30..39, :parent => masters_men)
    banana_belt_2_masters_30_39 = banana_belt_standings.races.create!(:category => masters_30_39)
    banana_belt_2_masters_30_39.results.create!(:racer => tonkin, :place => '1')
    banana_belt_2_masters_30_39.results.create!(:racer => weaver, :place => '2')    

    # Age Graded BAR is based on Overall BAR, which is based on discipline BAR
    Bar.recalculate(2004)
    OverallBar.recalculate(2004)
    
    results_baseline_count = Result.count
    assert_equal(0, AgeGradedBar.count, "AgeGradedBar standings before recalculate")
    assert_equal(38, Result.count, "Total count of results in DB before AgeGradedBar recalculate")
    AgeGradedBar.recalculate(2004)
    bar = AgeGradedBar.find(:first, :conditions => ['date = ?', Date.new(2004, 1, 1)])
    assert_not_nil(bar, "2004 AgeGradedBar after recalculate")
    assert_equal(1, AgeGradedBar.count, "AgeGradedBar events after recalculate")
    assert_equal(1, bar.standings.count, "AgeGradedBar standings after recalculate")
    assert_equal(42, Result.count, "Total count of results in DB")
    # Should delete old AgeGradedBar
    AgeGradedBar.recalculate(2004)
    assert_equal(1, AgeGradedBar.count, "AgeGradedBar events after recalculate")
    bar = AgeGradedBar.find(:first, :conditions => ['date = ?', Date.new(2004, 1, 1)])
    assert_not_nil(bar, "2004 AgeGradedBar after recalculate")
    assert_equal(1, bar.standings.count, "AgeGradedBar standings after recalculate")
    assert_equal(Date.new(2004, 1, 1), bar.date, "2004 AgeGradedBar date")
    assert_equal("2004 Age Graded BAR", bar.name, "2004 Bar name")
    assert_equal_dates(Date.today, bar.updated_at, "AgeGradedBar last updated")
    assert_equal(42, Result.count, "Total count of results in DB")
    
    bar_standings = bar.standings.first
    assert_equal('Age Graded', bar_standings.discipline, 'Age Graded BAR standings discipline')    
    
    race = bar_standings.races.detect {|race| race.category == masters_30_34}
    assert_not_nil(race, 'Age Graded BAR should have Men 30-34 race')
    assert_equal(1, race.results.size, 'Men 30-34 should have one result')
    result = race.results.first
    assert_equal('1', result.place, 'Place')
    assert_equal(weaver, result.racer, 'Racer')
    assert_equal(299, result.points, 'Points')
    
    race = bar_standings.races.detect {|race| race.category == masters_35_39}
    assert_not_nil(race, 'Age Graded BAR should have Men 35-39 race')
    assert_equal(3, race.results.size, 'Men 35-39 results')
    race.results.sort!
    result = race.results.first
    assert_equal('1', result.place, 'Place')
    assert_equal(tonkin, result.racer, 'Racer')
    assert_equal(300, result.points, 'Points')
    result = race.results[1]
    assert_equal('2', result.place, 'Place')
    assert_equal(carl_roberts, result.racer, 'Racer')
    assert_equal(297, result.points, 'Points')
    result = race.results[2]
    assert_equal('3', result.place, 'Place')
    assert_equal(molly, result.racer, 'Racer')
    assert_equal(296, result.points, 'Points')
  end
end