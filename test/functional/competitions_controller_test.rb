require File.dirname(__FILE__) + '/../test_helper'

# :stopdoc:
class CompetitionsControllerTest < ActionController::TestCase #:nodoc: all
  def test_rider_rankings_no_results
    opts = {:controller => "competitions", :action => "show", :type => 'rider_rankings'}
    assert_routing("/rider_rankings", opts)
    
    get(:show, :type => 'rider_rankings')
    assert_response(:success)
    assert_template("competitions/show")
    assert_not_nil(assigns["standings"], "Should assign standings")
    assert_not_nil(assigns["year"], "Should assign year")
  end

  def test_rider_rankings_result_with_no_racer
    RiderRankings.recalculate
    rider_rankings = RiderRankings.find_for_year
    rider_rankings.standings.first.races.first.results.create!(:place => "1")
    opts = {:controller => "competitions", :action => "show", :type => 'rider_rankings'}
    assert_routing("/rider_rankings", opts)
    
    get(:show, :type => 'rider_rankings')
    assert_response(:success)
    assert_template("competitions/show")
    assert_not_nil(assigns["standings"], "Should assign standings")
    assert_not_nil(assigns["year"], "Should assign year")
  end

  def test_cat4_womens_race_series
    opts = {:controller => "competitions", :action => "show", :type => 'cat4_womens_race_series'}
    assert_routing("/cat4_womens_race_series", opts)
    
    get(:show, :type => 'cat4_womens_race_series')
    assert_response(:success)
    assert_template("competitions/show")
    assert_not_nil(assigns["standings"], "Should assign standings")
    assert_not_nil(assigns["year"], "Should assign year")
  end

  def test_unknown_competition_type
    get(:show, :type => 'not_a_series')
    assert_response(:missing)
  end
end