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
    
    # Previous year should be ignored
    previous_event_standings = WeeklySeries.create!(:name => "Mt Tabor Series").events.create!(:date => Date.new(2006)).standings.create!
    previous_event_standings.races.create!(:category => categories(:cat_3)).results.create!(:place => 9, :racer => racers(:weaver))
    
    # Following year should be ignored
    following_event_standings = WeeklySeries.create!(:name => "Mt Tabor Series").events.create!(:date => Date.new(2008)).standings.create!
    following_event_standings.races.create!(:category => categories(:cat_3)).results.create!(:place => 10, :racer => racers(:weaver))
    
    TaborSeriesStandings.recalculate(2007)
    assert_equal(1, series.standings(true).size, "Should add new Standings to parent Series")
    overall_standings = series.standings.first
    assert_equal(9, overall_standings.races.size, "Overall races")
    
    TaborSeriesStandings.recalculate(2007)
    assert_equal(1, series.standings(true).size, "Should add new Standings to parent Series after deleting old standings")
    overall_standings = series.standings.first
    assert_equal(9, overall_standings.races.size, "Overall races")

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
  
  def test_best_5_of_6_count
    series = WeeklySeries.create!(:name => "Mt Tabor Series")

    event_standings = series.events.create!(:date => Date.new(2007, 6, 6)).standings.create!
    event_standings.races.create!(:category => categories(:cat_3)).results.create!(:place => 1, :racer => racers(:weaver))

    event_standings = series.events.create!(:date => Date.new(2007, 6, 13)).standings.create!
    event_standings.races.create!(:category => categories(:cat_3)).results.create!(:place => 14, :racer => racers(:weaver))

    event_standings = series.events.create!(:date => Date.new(2007, 6, 19)).standings.create!
    event_standings.races.create!(:category => categories(:cat_3)).results.create!(:place => 3, :racer => racers(:weaver))

    event_standings = series.events.create!(:date => Date.new(2007, 6, 27)).standings.create!
    event_standings.races.create!(:category => categories(:cat_3)).results.create!(:place => 5, :racer => racers(:weaver))

    event_standings = series.events.create!(:date => Date.new(2007, 7, 4)).standings.create!
    event_standings.races.create!(:category => categories(:cat_3)).results.create!(:place => 14, :racer => racers(:weaver))

    event_standings = series.events.create!(:date => Date.new(2007, 7, 11)).standings.create!
    event_standings.races.create!(:category => categories(:cat_3)).results.create!(:place => 11, :racer => racers(:weaver))
    
    TaborSeriesStandings.recalculate(2007)
    
    overall_standings = series.standings.first
    cat_3_overall_race = overall_standings.races.detect { |race| race.category == categories(:cat_3) }
    assert_not_nil(cat_3_overall_race, "Should have Cat 3 overall race")
    assert_equal(1, cat_3_overall_race.results.size, "Cat 3 race results")
    cat_3_overall_race.results(true).sort!
    result = cat_3_overall_race.results.first
    assert_equal("1", result.place, "place")
    assert_equal(5, result.scores.size, "Scores")
    assert_equal(100 + 12 + 50 + 36 + 15, result.points, "points")
    assert_equal(racers(:weaver), result.racer, "racer")
  end
end