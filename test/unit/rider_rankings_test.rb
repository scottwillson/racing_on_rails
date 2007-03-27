require File.dirname(__FILE__) + '/../test_helper'

class RiderRankingsTest < Test::Unit::TestCase
  def test_new
    RiderRankings.recalculate
    rider_rankings = RiderRankings.find(:first, :conditions => ['date = ?', Date.new(Date.today.year, 1, 1)])
    assert_not_nil(rider_rankings, "RiderRankings after recalculate")
    assert_equal(1, RiderRankings.count, "RiderRankings events after recalculate")
    assert_equal(1, rider_rankings.standings.count, "RiderRankings standings after recalculate")
    assert_equal(12, rider_rankings.standings.first.races.count, "RiderRankings races after recalculate")
    race = rider_rankings.standings.first.races.first
  end
  
  def test_recalculate
    cross_crusade = Series.create!(:name => "Cross Crusade")
    rider_rankingston = SingleDayEvent.create!({
      :name => "Cross Crusade: Barton Park",
      :discipline => "Cyclocross",
      :date => Date.new(2004, 11, 7),
      :parent => cross_crusade
    })
    rider_rankingston_standings = rider_rankingston.standings.create
    men_a = Category.find_by_name('Men A')
    rider_rankingston_a = rider_rankingston_standings.races.create(:category => men_a, :field_size => 5)
    rider_rankingston_a.results.create({
      :place => 3,
      :racer => racers(:tonkin)
    })
    rider_rankingston_a.results.create({
      :place => 10,
      :racer => racers(:weaver)
    })
    
    swan_island = SingleDayEvent.create!({
      :name => "Swan Island",
      :discipline => "Criterium",
      :date => Date.new(2004, 5, 17),
    })
    swan_island_standings = swan_island.standings.create
    senior_men = Category.find_by_name("Senior Men Pro 1/2")
    swan_island_senior_men = swan_island_standings.races.create(:category => senior_men, :field_size => 4)
    swan_island_senior_men.results.create({
      :place => 8,
      :racer => racers(:tonkin)
    })
    swan_island_senior_men.results.create({
      :place => 2,
      :racer => racers(:mollie)
    })
    senior_women = Category.find_by_name("Senior Women")
    senior_women_swan_island = swan_island_standings.races.create(:category => senior_women, :field_size => 3)
    senior_women_swan_island.results.create({
      :place => 1,
      :racer => racers(:mollie)
    })
    # No points
    senior_women_swan_island.bar_points = 0
    senior_women_swan_island.save!
    
    thursday_track_series = Series.create!(:name => "Thursday Track")
    thursday_track = SingleDayEvent.create!({
      :name => "Thursday Track",
      :discipline => "Track",
      :date => Date.new(2004, 5, 12),
      :parent => thursday_track_series
    })
    thursday_track_standings = thursday_track.standings.create
    thursday_track_senior_men = thursday_track_standings.races.create(:category => senior_men, :field_size => 6)
    r = thursday_track_senior_men.results.create(
      :place => 5,
      :racer => racers(:weaver)
    )
    thursday_track_senior_men.results.create(
      :place => 10,
      :racer => racers(:tonkin),
      :team => teams(:kona)
    )
    
    team_track = SingleDayEvent.create!({
      :name => "Team Track State Championships",
      :discipline => "Track",
      :date => Date.new(2004, 9, 1)
    })
    team_track_standings = team_track.standings.create
    team_track_standings.bar_points = 2
    team_track_standings.save!
    team_track_senior_men = team_track_standings.races.create(:category => senior_men, :field_size => 6)
    team_track_senior_men.results.create({
      :place => 1,
      :racer => racers(:weaver),
      :team => teams(:kona)
    })
    team_track_senior_men.results.create({
      :place => 1,
      :racer => racers(:tonkin),
      :team => teams(:kona)
    })
    team_track_senior_men.results.create({
      :place => 1,
      :racer => racers(:mollie)
    })
    team_track_senior_men.results.create({
      :place => 5,
      :racer => racers(:alice)
    })
    team_track_senior_men.results.create({
      :place => 5,
      :racer => racers(:matson)
    })
    # Weaver and Erik's second ride should not count
    team_track_senior_men.results.create({
      :place => 10,
      :racer => racers(:weaver),
      :team => teams(:kona)
    })
    team_track_senior_men.results.create({
      :place => 10,
      :racer => racers(:tonkin),
      :team => teams(:kona)
    })
    
    larch_mt_hillclimb = SingleDayEvent.create!({
      :name => "Larch Mountain Hillclimb",
      :discipline => "Time Trial",
      :date => Date.new(2004, 2, 1)
    })
    larch_mt_hillclimb_standings = larch_mt_hillclimb.standings.create(:event => larch_mt_hillclimb)
    larch_mt_hillclimb_senior_men = larch_mt_hillclimb_standings.races.create(:category => senior_men, :field_size => 6)
    # Should bump Tonkin result up one place to fifth. In real life, we'd have all results 1-5, too
    non_member = Racer.create(:name => "Non Member", :member => false)
    larch_mt_hillclimb_senior_men.results.create({
      :place => 3,
      :racer => non_member
    })
    larch_mt_hillclimb_senior_men.results.create({
      :place => 6,
      :racer => racers(:tonkin),
      :team => teams(:kona)
    })
  
    results_baseline_count = Result.count
    assert_equal(0, RiderRankings.count, "RiderRankings standings before recalculate")
    assert_equal(29, Result.count, "Total count of results in DB before RiderRankings recalculate")
    RiderRankings.recalculate(2004)
    rider_rankings = RiderRankings.find(:first, :conditions => ['date = ?', Date.new(2004, 1, 1)])
    assert_not_nil(rider_rankings, "2004 RiderRankings after recalculate")
    assert_equal(1, RiderRankings.count, "RiderRankings events after recalculate")
    assert_equal(1, rider_rankings.standings.count, "RiderRankings standings after recalculate")
    assert_equal(35, Result.count, "Total count of results in DB")
    # Should delete old RiderRankings
    RiderRankings.recalculate(2004)
    assert_equal(1, RiderRankings.count, "RiderRankings events after recalculate")
    rider_rankings = RiderRankings.find(:first, :conditions => ['date = ?', Date.new(2004, 1, 1)])
    assert_not_nil(rider_rankings, "2004 RiderRankings after recalculate")
    assert_equal(1, rider_rankings.standings.count, "RiderRankings standings after recalculate")
    assert_equal(Date.new(2004, 1, 1), rider_rankings.date, "2004 RiderRankings date")
    assert_equal("2004 Rider Rankings", rider_rankings.name, "2004 RiderRankings name")
    assert_equal_dates(Date.today, rider_rankings.updated_at, "RiderRankings last updated")
    assert_equal(35, Result.count, "Total count of results in DB")

    road_rider_rankings = rider_rankings.standings.first
    assert_equal("2004 Rider Rankings", road_rider_rankings.name, "2004 rider rankings name")
    assert_equal(12, road_rider_rankings.races.size, "2004 rider rankings races")
    assert_equal_dates(Date.today, road_rider_rankings.updated_at, "RiderRankings last updated")
    
    senior_men = road_rider_rankings.races.detect {|b| b.name == "Senior Men"}
    assert_equal(5, senior_men.results.size, "Senior Men rider rankings results")
    assert_equal_dates(Date.today, senior_men.updated_at, "RiderRankings last updated")

    senior_men.results.sort!
    assert_equal(racers(:tonkin), senior_men.results[0].racer, "Senior Men rider rankings results racer")
    assert_equal("1", senior_men.results[0].place, "Senior Men rider rankings results place")
    assert_in_delta(259.333, senior_men.results[0].points, 0.001, "Senior Men rider rankings results points")

    assert_equal(racers(:weaver), senior_men.results[1].racer, "Senior Men rider rankings results racer")
    assert_equal("2", senior_men.results[1].place, "Senior Men rider rankings results place")
    assert_in_delta(155.333, senior_men.results[1].points, 0.001, "Senior Men rider rankings results points")
    assert_equal(4, senior_men.results[1].scores.size, "Weaver rider rankings results scores")

    assert_equal(racers(:matson), senior_men.results[3].racer, "Senior Men rider rankings results racer")
    assert_equal("4", senior_men.results[3].place, "Senior Men rider rankings results place")
    assert_equal(68, senior_men.results[3].points, "Senior Men rider rankings results points")
    
    women = road_rider_rankings.races.detect {|b| b.name == "Senior Women"}
    assert_equal(1, women.results.size, "Senior Women rider rankings results")

    women.results.sort!
    assert_equal(racers(:alice), women.results[0].racer, "Senior Women rider rankings results racer")
    assert_equal("1", women.results[0].place, "Senior Women rider rankings results place")
    assert_equal(70, women.results[0].points, "Senior Women rider rankings results points")
  end
end