require File.dirname(__FILE__) + '/../test_helper'

class TeamRankingsTest < Test::Unit::TestCase

  def test_recalculate
    # FIXME Implement
    # team_standings = rider_rankings.standings.detect {|s| s.name == 'Team'}
    # assert_equal(1, team_standings.races.size, 'Should have only one team RiderRankings standings race')
    # team_race = team_standings.races.first
    #   
    # assert_equal(2, team_race.results.size, "Team RiderRankings results")
    # assert_equal_dates(Date.today, team_race.updated_at, "RiderRankings last updated")
    # 
    # team_race.results.sort!
    # assert_equal(teams(:kona), team_race.results[0].team, "Team RiderRankings results team")
    # assert_equal("1", team_race.results[0].place, "Team RiderRankings results place")
    # assert_in_delta(382, team_race.results[0].points, 0.0001, "Team RiderRankings results points")
    # 
    # assert_equal(teams(:gentle_lovers), team_race.results[1].team, "Team RiderRankings results team")
    # assert_equal("2", team_race.results[1].place, "Team RiderRankings results place")
    # assert_equal(70, team_race.results[1].points, "Team RiderRankings results points")
    # 
    # overall_rider_rankings = rider_rankings.standings.detect {|standings| standings.name == 'Overall'}
    # assert_nil(overall_rider_rankings, "Should not have overall RiderRankings")
  end
  
end