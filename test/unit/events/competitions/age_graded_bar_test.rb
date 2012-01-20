require File.expand_path("../../../../test_helper", __FILE__)

# :stopdoc:
class AgeGradedBarTest < ActiveSupport::TestCase  
  def test_calculate
    # Discipline and categories. Age-graded BAR is a third-order competition
    age_graded = FactoryGirl.create(:discipline, :name => "Age Graded")
    masters_men = FactoryGirl.create(:category, :name => "Masters Men")
    masters_30_34 = FactoryGirl.create(:category, :name => "Masters Men 30-34", :ages => 30..34, :parent => masters_men)
    age_graded.bar_categories << masters_30_34

    road = FactoryGirl.create(:discipline, :name => "Road")
    road.bar_categories << masters_men

    overall = FactoryGirl.create(:discipline, :name => "Overall")
    
    # Masters 30-34 result. (32)
    weaver = FactoryGirl.create(:person, :date_of_birth => Date.new(1972))
    banana_belt_1 = FactoryGirl.create(:event, :date => Date.new(2004))
    banana_belt_masters_30_34 = banana_belt_1.races.create!(:category => masters_30_34)
    banana_belt_masters_30_34.results.create!(:person => weaver, :place => '10')
    
    # Masters 35-39 results (36)
    tonkin = FactoryGirl.create(:person, :date_of_birth => Date.new(1968))
    masters_35_39 = FactoryGirl.create(:category, :name => "Masters Men 35-39", :ages => 35..39, :parent => masters_men)
    banana_belt_masters = banana_belt_1.races.create!(:category => masters_35_39)
    banana_belt_masters.results.create!(:person => tonkin, :place => '5')
    
    # Masters 35-39 result, but now is 40+ racing age (39 in 2004)
    molly = FactoryGirl.create(:person, :date_of_birth => Date.new(1965))
    banana_belt_masters.results.create!(:person => molly, :place => '15')
    
    # Racing age is 35, but was 34 on race day
    carl_roberts = FactoryGirl.create(:person, :date_of_birth => Date.new(1969, 11, 2), :member_from => Date.new(2004), :member_to => Date.new(2004, 12, 31))
    banana_belt_masters.results.create!(:person => carl_roberts, :place => '11')
    
    # No age, but Masters result
    david_auker = FactoryGirl.create(:person, :member_from => Date.new(2004), :member_to => Date.new(2004, 12, 31))
    banana_belt_masters.results.create!(:person => david_auker, :place => '9')
    
    # Result by a 32-year-old and a 36 year-old in a 30-39 race
    banana_belt_2 = FactoryGirl.create(:event, :date => Date.new(2004))
    masters_30_39 = FactoryGirl.create(:category, :name => "Masters Men 30-39", :ages => 30..39, :parent => masters_men)
    banana_belt_2_masters_30_39 = banana_belt_2.races.create!(:category => masters_30_39)
    banana_belt_2_masters_30_39.results.create!(:person => tonkin, :place => '1')
    banana_belt_2_masters_30_39.results.create!(:person => weaver, :place => '2')
    
    # Age Graded BAR is based on Overall BAR, which is based on discipline BAR
    Bar.calculate! 2004
    OverallBar.calculate! 2004
    
    assert_difference "Result.count", 4 do
      AgeGradedBar.calculate! 2004
    end

    bar = AgeGradedBar.find_for_year(2004)
    assert_not_nil(bar, "2004 AgeGradedBar after calculate!")
    assert_equal(Date.new(2004), bar.date, "2004 AgeGradedBar date")
    assert_equal("2004 Age Graded BAR", bar.name, "2004 Bar name")
    assert_equal_dates(Time.zone.today, bar.updated_at, "AgeGradedBar last updated")
    assert_equal('Age Graded', bar.discipline, 'Age Graded BAR discipline')    
    
    race = bar.races.detect { |race| race.category == masters_30_34 }
    assert_not_nil(race, 'Age Graded BAR should have Men 30-34 race')
    assert_equal(1, race.results.size, 'Men 30-34 should have one result')
    result = race.results.first
    assert_equal('1', result.place, 'Place')
    assert_equal(weaver, result.person, 'Person')
    assert_equal(299, result.points, 'Points')
    
    race = bar.races.detect { |race| race.category == masters_35_39 }
    assert_not_nil(race, 'Age Graded BAR should have Men 35-39 race')
    assert_equal(3, race.results.size, 'Men 35-39 results')
    race.results.sort!
    result = race.results.first
    assert_equal('1', result.place, 'Place')
    assert_equal(tonkin, result.person, 'Person')
    assert_equal(300, result.points, 'Points')
    result = race.results[1]
    assert_equal('2', result.place, 'Place')
    assert_equal(carl_roberts, result.person, 'Person')
    assert_equal(297, result.points, 'Points')
    result = race.results[2]
    assert_equal('3', result.place, 'Place')
    assert_equal(molly, result.person, 'Person')
    assert_equal(296, result.points, 'Points')
  end
end
