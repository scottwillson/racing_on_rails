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

    series.events.create!(:date => Date.new(2007, 10, 14))
    series.events.create!(:date => Date.new(2007, 10, 21))
    series.events.create!(:date => Date.new(2007, 10, 28))
    series.events.create!(:date => Date.new(2007, 11, 5))
    
    series.reload
    assert_equal(Date.new(2007, 10, 7), series.date, "Series date")
    
    cat_a = Category.find_or_create_by_name("Category A")
    cat_a_race = event_standings.races.create!(:category => cat_a)
    cat_a_race.results.create!(:place => 1, :racer => racers(:weaver))
    cat_a_race.results.create!(:place => 9, :racer => racers(:tonkin))

    masters_35_plus_women = Category.find_or_create_by_name("Masters Women 35+")
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
    assert_equal(false, result.preliminary?, "Preliminary?")
    assert_equal("1", result.place, "Men A first result place")
    assert_equal(26, result.points, "Men A first result points")
    assert_equal(racers(:weaver), result.racer, "Men A first result racer")
    result = cx_a_overall_race.results.last
    assert_equal(false, result.preliminary?, "Preliminary?")
    assert_equal("2", result.place, "Men A second result place")
    assert_equal(10, result.points, "Men A second result points (double points for last result)")
    assert_equal(racers(:tonkin), result.racer, "Men A second result racer")

    masters_35_plus_women_overall_race = overall_standings.races.detect { |race| race.category == masters_35_plus_women }
    assert_not_nil(masters_35_plus_women_overall_race, "Should have Masters Women overall race")
    assert_equal(1, masters_35_plus_women_overall_race.results.size, "Masters Women race results")
    result = masters_35_plus_women_overall_race.results.first
    assert_equal(false, result.preliminary?, "Preliminary?")
    assert_equal("1", result.place, "Masters Women first result place")
    assert_equal(4, result.points, "Masters Women first result points  (double points for last result)")
    assert_equal(racers(:alice), result.racer, "Masters Women first result racer")
  end

  def test_many_results
    series = WeeklySeries.create!(:name => "Cross Crusade")
    masters = Category.find_or_create_by_name("Masters 35+ A")
    category_a = Category.find_or_create_by_name("Category A")
    singlespeed = Category.find_or_create_by_name("Singlespeed")
    racer = Racer.create!(:name => "John Browning")
    
    event_standings = series.events.create!(:date => Date.new(2008, 10, 5)).standings.create!
    event_standings.races.create!(:category => masters).results.create!(:place => 1, :racer => racer)
    
    event_standings = series.events.create!(:date => Date.new(2008, 10, 12)).standings.create!
    event_standings.races.create!(:category => masters).results.create!(:place => 1, :racer => racer)
    
    event_standings = series.events.create!(:date => Date.new(2008, 10, 19)).standings.create!
    event_standings.races.create!(:category => masters).results.create!(:place => 2, :racer => racer)
    event_standings.races.create!(:category => category_a).results.create!(:place => 4, :racer => racer)
    event_standings.races.create!(:category => singlespeed).results.create!(:place => 5, :racer => racer)
    
    event_standings = series.events.create!(:date => Date.new(2008, 10, 26)).standings.create!
    event_standings.races.create!(:category => masters).results.create!(:place => 1, :racer => racer)
    
    event_standings = series.events.create!(:date => Date.new(2008, 11, 2)).standings.create!
    event_standings.races.create!(:category => masters).results.create!(:place => 2, :racer => racer)
    
    event_standings = series.events.create!(:date => Date.new(2008, 11, 9)).standings.create!
    event_standings.races.create!(:category => masters).results.create!(:place => 1, :racer => racer)
    event_standings.races.create!(:category => category_a).results.create!(:place => 20, :racer => racer)
    event_standings.races.create!(:category => singlespeed).results.create!(:place => 12, :racer => racer)
    
    event_standings = series.events.create!(:date => Date.new(2008, 11, 10)).standings.create!
    event_standings.races.create!(:category => masters).results.create!(:place => 1, :racer => racer)
    
    event_standings = series.events.create!(:date => Date.new(2008, 11, 17)).standings.create!
    event_standings.races.create!(:category => masters).results.create!(:place => 3, :racer => racer)
    event_standings.races.create!(:category => category_a).results.create!(:place => 20, :racer => racer)

    CrossCrusadeSeriesStandings.recalculate(2008)
    
    overall_standings = series.standings.first
    masters_overall_race = overall_standings.races.detect { |race| race.category == masters }
    assert_not_nil(masters_overall_race, "Should have Masters overall race")
    masters_overall_race.results(true).sort!
    result = masters_overall_race.results.first
    assert_equal(false, result.preliminary?, "Preliminary?")
    assert_equal("1", result.place, "place")
    assert_equal(6, result.scores.size, "Scores")
    assert_equal(26 + 26 + 20 + 26 + 0 + 26 + 26 + (0 * 2), result.points, "points")
    assert_equal(racer, result.racer, "racer")

    category_a_overall_race = overall_standings.races.detect { |race| race.category == category_a }
    assert_not_nil(category_a_overall_race, "Should have Category A overall race")
    category_a_overall_race.results(true).sort!
    result = category_a_overall_race.results.first
    assert_equal(false, result.preliminary?, "Preliminary?")
    assert_equal("1", result.place, "place")
    assert_equal(1, result.scores.size, "Scores")
    assert_equal(15, result.points, "points")
    assert_equal(racer, result.racer, "racer")

    singlespeed_overall_race = overall_standings.races.detect { |race| race.category == singlespeed }
    assert_not_nil(singlespeed_overall_race, "Should have Singlespeed overall race")
    assert(singlespeed_overall_race.results.empty?, "Should not have any singlespeed results")
  end
  
  def test_preliminary_results_after_event_minimum
    series = Series.create!(:name => "Cross Crusade")
    series.events.create!(:date => Date.new(2007, 10, 7))

    series.events.create!(:date => Date.new(2007, 10, 14))
    series.events.create!(:date => Date.new(2007, 10, 21))
    series.events.create!(:date => Date.new(2007, 10, 28))
    series.events.create!(:date => Date.new(2007, 11, 5))

    cat_a = Category.find_or_create_by_name("Category A")
    cat_a_race = series.events[0].standings.create!.races.create!(:category => cat_a)
    cat_a_race.results.create!(:place => 1, :racer => racers(:weaver))
    cat_a_race.results.create!(:place => 2, :racer => racers(:tonkin))
    
    cat_a_race = series.events[1].standings.create!.races.create!(:category => cat_a)
    cat_a_race.results.create!(:place => 43, :racer => racers(:weaver))

    cat_a_race = series.events[2].standings.create!.races.create!(:category => cat_a)
    cat_a_race.results.create!(:place => 1, :racer => racers(:weaver))

    cat_a_race = series.events[3].standings.create!.races.create!(:category => cat_a)
    cat_a_race.results.create!(:place => 8, :racer => racers(:tonkin))

    CrossCrusadeSeriesStandings.recalculate(2007)
    
    overall_standings = series.standings.first

    category_a_overall_race = overall_standings.races.detect { |race| race.category == cat_a }
    assert_not_nil(category_a_overall_race, "Should have Category A overall race")
    category_a_overall_race.results(true).sort!
    result = category_a_overall_race.results.first
    assert_equal(false, result.preliminary?, "Weaver did three races. His result should not be preliminary")
    
    result = category_a_overall_race.results.last
    assert_equal(true, result.preliminary?, "Tonkin did only two races. His result should be preliminary")
  end
  
  def test_raced_minimum_events_boundaries
    series = Series.create!(:name => "Cross Crusade")
    cat_a = Category.find_or_create_by_name("Category A")
    molly = racers(:molly)
    event = series.events.create!(:date => Date.new(2007, 10, 7))
    
    # Molly does three races in different categories
    cat_a_race = event.standings.create!.races.create!(:category => cat_a)
    cat_a_race.results.create!(:place => 6, :racer => molly)
    single_speed_race = event.standings.create!.races.create!(:category => categories(:single_speed))
    single_speed_race.results.create!(:place => 8, :racer => molly)
    masters_women_race = event.standings.create!.races.create!(:category => categories(:masters_women))
    masters_women_race.results.create!(:place => 10, :racer => molly)
    
    cat_a_race.results.create!(:place => 17, :racer => racers(:alice))

    CrossCrusadeSeriesStandings.recalculate(2007)
    overall_standings = series.standings.first
    category_a_overall_race = overall_standings.races.detect { |race| race.category == cat_a }
    assert(!overall_standings.raced_minimum_events?(molly, category_a_overall_race), "One event. No racers have raced minimum")
    assert(!overall_standings.raced_minimum_events?(racers(:alice), category_a_overall_race), "One event. No racers have raced minimum")
    
    event = series.events.create!(:date => Date.new(2007, 10, 14))
    cat_a_race = event.standings.create!.races.create!(:category => cat_a)
    cat_a_race.results.create!(:place => 14, :racer => molly)
    cat_a_race.results.create!(:place => 6, :racer => racers(:alice))

    CrossCrusadeSeriesStandings.recalculate(2007)
    overall_standings = series.standings(true).first
    category_a_overall_race = overall_standings.races.detect { |race| race.category == cat_a }
    assert(!overall_standings.raced_minimum_events?(molly, category_a_overall_race), "Two events. No racers have raced minimum")
    assert(!overall_standings.raced_minimum_events?(racers(:alice), category_a_overall_race), "Two events. No racers have raced minimum")

    event = series.events.create!(:date => Date.new(2007, 10, 21))
    cat_a_race = event.standings.create!.races.create!(:category => cat_a)
    cat_a_race.results.create!(:place => "DNF", :racer => molly)
    single_speed_race = event.standings.create!.races.create!(:category => categories(:single_speed))
    single_speed_race.results.create!(:place => 8, :racer => racers(:alice))
    
    CrossCrusadeSeriesStandings.recalculate(2007)
    overall_standings = series.standings(true).first
    category_a_overall_race = overall_standings.races.detect { |race| race.category == cat_a }
    assert(overall_standings.raced_minimum_events?(molly, category_a_overall_race), "Three events. Molly has raced minimum")
    assert(!overall_standings.raced_minimum_events?(racers(:alice), category_a_overall_race), "Three events. Alice has not raced minimum")

    event = series.events.create!(:date => Date.new(2007, 10, 28))
    cat_a_race = event.standings.create!.races.create!(:category => cat_a)
    
    CrossCrusadeSeriesStandings.recalculate(2007)
    overall_standings = series.standings(true).first
    category_a_overall_race = overall_standings.races.detect { |race| race.category == cat_a }
    assert(overall_standings.raced_minimum_events?(molly, category_a_overall_race), "Four events. Molly has raced minimum")
    assert(!overall_standings.raced_minimum_events?(racers(:alice), category_a_overall_race), "Four events. Alice has not raced minimum")
  end
end
