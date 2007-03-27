require File.dirname(__FILE__) + '/../test_helper'
require 'competitions_controller'

# :stopdoc:
# Re-raise errors caught by the controller.
class CompetitionsController; def rescue_action(e) raise e end; end #:nodoc: all

class CompetitionsControllerTest < Test::Unit::TestCase #:nodoc: all

  def setup
    @controller = CompetitionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_rider_rankings
    opts = {:controller => "competitions", :action => "show", :type => 'rider_rankings'}
    assert_routing("/rider_rankings", opts)
    
    get(:show, :competition_type => 'RiderRankings')
    assert_response(:success)
    assert_template("competitions/show")
    assert_not_nil(assigns["standings"], "Should assign standings")
    assert_not_nil(assigns["year"], "Should assign year")
  end
end