require File.dirname(__FILE__) + '/../../test_helper'

class TaborSeriesStandingsTest < ActiveSupport::TestCase  

  def test_recalc_with_no_tabor_series
    standings_count = Standings.count
    TaborSeriesStandings.recalculate
    TaborSeriesStandings.recalculate(2007)
    assert_equal(standings_count, Standings.count, "Should add no new Standings if there are no Tabor events")
  end
  
  def test_recalc_with_one_event
    series = WeeklySeries.create!(:name => "Mt Tabor Series")
    event = series.events.create!(:date => Date.new(2007, 6, 6))
    event_standings = event.standings.create!
    
    series.reload
    assert_equal(Date.new(2007, 6, 6), series.date, "Series date")
    
    cat_3_race = event_standings.races.create!(:category => categories(:cat_3))
    cat_3_race.results.create!(:place => 1, :racer => racers(:weaver))
    cat_3_race.results.create!(:place => 3, :racer => racers(:tonkin))
    
    masters_40_plus_women_category = Category.create!(:name => "Women Masters 40+")
    masters_race = event_standings.races.create!(:category => masters_40_plus_women_category)
    masters_race.results.create!(:place => 15, :racer => racers(:alice))
    masters_race.results.create!(:place => 16, :racer => racers(:molly))
    
    TaborSeriesStandings.recalculate(2007)
    assert_equal(1, series.standings(true).size, "Should add new Standings to parent Series")
    overall_standings = series.standings.first
    assert_equal(8, overall_standings.races.size, "Overall races")

    cat_3_overall_race = overall_standings.races.detect { |race| race.category == categories(:cat_3) }
    assert_not_nil(cat_3_overall_race, "Should have Cat 3 overall race")
    assert_equal(2, cat_3_overall_race.results.size, "Cat 3 race results")
    cat_3_overall_race.results(true).sort!
    result = cat_3_overall_race.results.first
    assert_equal("1", result.place, "Cat 3 first result place")
    assert_equal(100, result.points, "Cat 3 first result points")
    assert_equal(racers(:weaver), result.racer, "Cat 3 first result racer")
    result = cat_3_overall_race.results.last
    assert_equal("2", result.place, "Cat 3 second result place")
    assert_equal(50, result.points, "Cat 3 second result points")
    assert_equal(racers(:tonkin), result.racer, "Cat 3 second result racer")

    masters_40_plus_women_overall_race = overall_standings.races.detect { |race| race.category == masters_40_plus_women_category }
    assert_not_nil(masters_40_plus_women_overall_race, "Should have Masters Women overall race")
    assert_equal(1, masters_40_plus_women_overall_race.results.size, "Masters Women race results")
    result = masters_40_plus_women_overall_race.results.first
    assert_equal("1", result.place, "Masters Women first result place")
    assert_equal(11, result.points, "Masters Women first result points")
    assert_equal(racers(:alice), result.racer, "Masters Women first result racer")
  end
  
  # Ensure skips races from different years
  # test replaces previous standings
  # best 5 of 6
  # Competitive module?
  # Outer joins to inner joins?
end