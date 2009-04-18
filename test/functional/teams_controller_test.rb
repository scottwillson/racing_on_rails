require "test_helper"

class TeamsControllerTest < ActionController::TestCase
  def test_index
    nonmember = Team.create!(:name => "Not Member")
    assert(!nonmember.member?, "Team should not be member")
    
    hidden_team = Team.create!(:name => "Hidden Member", :member => true, :show_on_public_page => false)
    
    get(:index)
    assert_response(:success)
    assert_not_nil(assigns(:teams), "Should assign @teams")
    assert(!assigns(:teams).include?(nonmember), "Should only show member teams")
    assert(!assigns(:teams).include?(hidden_team), "Should not show hidden teams")
  end
  
  def test_show
    team = teams(:gentle_lovers)
    get(:show, :id => team.to_param)    
    assert_response(:success)
    assert_equal(team, assigns(:team), "Should assign @team")
  end
end
