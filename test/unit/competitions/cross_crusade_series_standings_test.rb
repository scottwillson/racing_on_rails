require File.dirname(__FILE__) + '/../../test_helper'

class CrossCrusadeSeriesStandingsTest < ActiveSupport::TestCase  
  def test_recalc_with_no_series
    standings_count = Standings.count
    CrossCrusadeSeriesStandings.recalculate
    CrossCrusadeSeriesStandings.recalculate(2007)
    assert_equal(standings_count, Standings.count, "Should add no new Standings if there are no Cross Crusade events")
  end


  def test_recalc_with_one_event
    series = Series.create!(:name => "Cross Crusade")
    event = series.events.create!(:date => Date.new(2007, 10, 7))
    event_standings = event.standings.create!
    
    series.reload
    assert_equal(Date.new(2007, 10, 7), series.date, "Series date")
    
    cat_a = Category.find_or_create_by_name("Category A")
    cat_a_race = event_standings.races.create!(:category => cat_a)
    cat_a_race.results.create!(:place => 1, :racer => racers(:weaver))
    cat_a_race.results.create!(:place => 9, :racer => racers(:tonkin))

    masters_35_plus_women = Category.find_or_create_by_name("Women Masters 35+")
    masters_race = event_standings.races.create!(:category => masters_35_plus_women)
    masters_race.results.create!(:place => 15, :racer => racers(:alice))
    masters_race.results.create!(:place => 19, :racer => racers(:molly))
    
    # Previous year should be ignored
    previous_event_standings = Series.create!(:name => "Cross Crusade").events.create!(:date => Date.new(2006)).standings.create!
    previous_event_standings.races.create!(:category => cat_a).results.create!(:place => 6, :racer => racers(:weaver))
    
    # Following year should be ignored
    following_event_standings = Series.create!(:name => "Cross Crusade").events.create!(:date => Date.new(2008)).standings.create!
    following_event_standings.races.create!(:category => cat_a).results.create!(:place => 10, :racer => racers(:weaver))
    
    CrossCrusadeSeriesStandings.recalculate(2007)
    assert_equal(1, series.standings(true).size, "Should add new Standings to parent Series")
    overall_standings = series.standings.first
    assert_equal(17, overall_standings.races.size, "Overall races")
    
    CrossCrusadeSeriesStandings.recalculate(2007)
    assert_equal(1, series.standings(true).size, "Should add new Standings to parent Series after deleting old standings")
    overall_standings = series.standings.first
    assert_equal(17, overall_standings.races.size, "Overall races")

    cx_a_overall_race = overall_standings.races.detect { |race| race.category == cat_a }
    assert_not_nil(cx_a_overall_race, "Should have Men A overall race")
    assert_equal(2, cx_a_overall_race.results.size, "Men A race results")
    cx_a_overall_race.results(true).sort!
    result = cx_a_overall_race.results.first
    assert_equal("1", result.place, "Men A first result place")
    assert_equal(52, result.points, "Men A first result points (double points for last result)")
    assert_equal(racers(:weaver), result.racer, "Men A first result racer")
    result = cx_a_overall_race.results.last
    assert_equal("2", result.place, "Men A second result place")
    assert_equal(20, result.points, "Men A second result points (double points for last result)")
    assert_equal(racers(:tonkin), result.racer, "Men A second result racer")

    masters_35_plus_women_overall_race = overall_standings.races.detect { |race| race.category == masters_35_plus_women }
    assert_not_nil(masters_35_plus_women_overall_race, "Should have Masters Women overall race")
    assert_equal(1, masters_35_plus_women_overall_race.results.size, "Masters Women race results")
    result = masters_35_plus_women_overall_race.results.first
    assert_equal("1", result.place, "Masters Women first result place")
    assert_equal(8, result.points, "Masters Women first result points  (double points for last result)")
    assert_equal(racers(:alice), result.racer, "Masters Women first result racer")
  end
end
