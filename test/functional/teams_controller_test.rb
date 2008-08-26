require File.dirname(__FILE__) + '/../test_helper'
require_or_load 'teams_controller'

class TeamsController; def rescue_action(e) raise e end; end

class TeamsControllerTest < ActiveSupport::TestCase

  def setup
    @controller = TeamsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    nonmember = Team.create!(:name => "Not Member")
    assert(!nonmember.member?, "Team should not be member")
    
    get(:index)
    assert_response(:success)
    assert_not_nil(assigns(:teams), "Should assign @teams")
    assert(!assigns(:teams).include?(nonmember), "Should only show member teams")
  end
  
  def test_show
    team = teams(:gentle_lovers)
    get(:show, :id => team.to_param)    
    assert_response(:success)
    assert_equal(team, assigns(:team), "Should assign @team")
  end
end