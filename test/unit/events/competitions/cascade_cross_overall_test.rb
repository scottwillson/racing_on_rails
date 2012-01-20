require File.expand_path("../../../../test_helper", __FILE__)

# :stopdoc:
class CascadeCrossOverallTest < ActiveSupport::TestCase  
  def test_recalc_with_one_event
    series = Series.create!(:name => "Cascade Cross Series")
    event = series.children.create!(:date => Date.new(2007, 10, 7), :name => "Cascade Cross #4")

    series.children.create!(:date => Date.new(2007, 10, 14))
    series.children.create!(:date => Date.new(2007, 10, 21))
    series.children.create!(:date => Date.new(2007, 10, 28))
    series.children.create!(:date => Date.new(2007, 11, 5))
    
    men_a = FactoryGirl.create(:category, :name => "Men A")
    men_a_race = event.races.create!(:category => men_a)
    weaver = FactoryGirl.create(:person)
    tonkin = FactoryGirl.create(:person)
    men_a_race.results.create!(:place => 1, :person => weaver)
    men_a_race.results.create!(:place => 9, :person => tonkin)

    masters_men = FactoryGirl.create(:category, :name => "Masters Men A 40+")
    masters_race = event.races.create!(:category => masters_men)
    alice = FactoryGirl.create(:person)
    molly = FactoryGirl.create(:person)
    masters_race.results.create!(:place => 15, :person => alice)
    masters_race.results.create!(:place => 19, :person => molly)
    
    # Previous year should be ignored
    previous_event = Series.create!(:name => "Cascade Cross Series").children.create!(:date => Date.new(2006), :name => "Cascade Cross #3")
    previous_event.races.create!(:category => men_a).results.create!(:place => 6, :person => weaver)
    
    # Following year should be ignored
    following_event = Series.create!(:name => "Cascade Cross Series").children.create!(:date => Date.new(2008))
    following_event.races.create!(:category => men_a).results.create!(:place => 10, :person => weaver)
    
    CascadeCrossOverall.calculate!(2007)
    assert_not_nil(series.overall(true), "Should add new Overall Competition child to parent Series")
    overall = series.overall
    assert_equal(11, overall.races.size, "Overall races")
    
    cx_a_overall_race = overall.races.detect { |race| race.category == men_a }
    assert_not_nil(cx_a_overall_race, "Should have Men A overall race")
    assert_equal(2, cx_a_overall_race.results.size, "Men A race results")
    cx_a_overall_race.results(true).sort!
    result = cx_a_overall_race.results.first
    assert_equal(false, result.preliminary?, "Preliminary?")
    assert_equal("1", result.place, "Men A first result place")
    assert_equal(26, result.points, "Men A first result points")
    assert_equal(weaver, result.person, "Men A first result person")
    result = cx_a_overall_race.results.last
    assert_equal(false, result.preliminary?, "Preliminary?")
    assert_equal("2", result.place, "Men A second result place")
    assert_equal(10, result.points, "Men A second result points (double points for last result)")
    assert_equal(tonkin, result.person, "Men A second result person")

    masters_men_overall_race = overall.races.detect { |race| race.category == masters_men }
    assert_not_nil(masters_men_overall_race, "Should have Masters Women overall race")
    assert_equal(1, masters_men_overall_race.results.size, "Masters Women race results")
    result = masters_men_overall_race.results.first
    assert_equal(false, result.preliminary?, "Preliminary?")
    assert_equal("1", result.place, "Masters Women first result place")
    assert_equal(4, result.points, "Masters Women first result points  (double points for last result)")
    assert_equal(alice, result.person, "Masters Women first result person")
  end

  def test_many_results
    series = Series.create!(:name => "Cascade Cross Series")
    masters = Category.find_or_create_by_name("Masters Men A 40+")
    men_a = Category.find_or_create_by_name("Men A")
    singlespeed = Category.find_or_create_by_name("Singlespeed")
    person = Person.create!(:name => "John Browning")
    
    event = series.children.create!(:date => Date.new(2008, 10, 5))
    event.races.create!(:category => masters).results.create!(:place => 1, :person => person)
    
    event = series.children.create!(:date => Date.new(2008, 10, 12))
    event.races.create!(:category => masters).results.create!(:place => 1, :person => person)
    
    event = series.children.create!(:date => Date.new(2008, 10, 19))
    event.races.create!(:category => masters).results.create!(:place => 2, :person => person)
    event.races.create!(:category => men_a).results.create!(:place => 4, :person => person)
    event.races.create!(:category => singlespeed).results.create!(:place => 5, :person => person)
    
    event = series.children.create!(:date => Date.new(2008, 10, 26))
    event.races.create!(:category => masters).results.create!(:place => 1, :person => person)
    
    event = series.children.create!(:date => Date.new(2008, 11, 2))
    event.races.create!(:category => masters).results.create!(:place => 2, :person => person)
    
    event = series.children.create!(:date => Date.new(2008, 11, 9))
    event.races.create!(:category => masters).results.create!(:place => 1, :person => person)
    event.races.create!(:category => men_a).results.create!(:place => 20, :person => person)
    
    event = series.children.create!(:date => Date.new(2008, 11, 10))
    event.races.create!(:category => masters).results.create!(:place => 1, :person => person)
    
    event = series.children.create!(:date => Date.new(2008, 11, 17))
    event.races.create!(:category => masters).results.create!(:place => 3, :person => person)
    event.races.create!(:category => men_a).results.create!(:place => 20, :person => person)

    CascadeCrossOverall.calculate!(2008)
    
    masters_overall_race = series.overall(true).races.detect { |race| race.category == masters }
    assert_not_nil(masters_overall_race, "Should have Masters overall race")
    masters_overall_race.results(true).sort!
    result = masters_overall_race.results.first
    assert_equal(false, result.preliminary?, "Preliminary?")
    assert_equal("1", result.place, "place")
    assert_equal(6, result.scores.size, "Scores")

    assert_equal(26 + 26 + 20 + 26 + 0 + 26 + 26 + 0, result.points, "points")
    assert_equal(person, result.person, "person")

    men_a_overall_race = series.overall.races.detect { |race| race.category == men_a }
    assert_not_nil(men_a_overall_race, "Should have Men A overall race")
    men_a_overall_race.results(true).sort!
    result = men_a_overall_race.results.first
    assert_equal(false, result.preliminary?, "Preliminary?")
    assert_equal("1", result.place, "place")
    assert_equal(1, result.scores.size, "Scores")
    assert_equal(15, result.points, "points")
    assert_equal(person, result.person, "person")

    singlespeed_overall_race = series.overall.races.detect { |race| race.category == singlespeed }
    assert_not_nil(singlespeed_overall_race, "Should have Singlespeed overall race")
    assert(singlespeed_overall_race.results.empty?, "Should not have any singlespeed results")
  end
end
