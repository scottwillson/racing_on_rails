require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class TeamsControllerTest < ActionController::TestCase
  def test_index
    nonmember = Team.create!(:name => "Not Member")
    assert(!nonmember.member?, "Team should not be member")
    
    hidden_team = Team.create!(:name => "Hidden Member", :member => true, :show_on_public_page => false)
    
    get(:index)
    assert_response(:success)
    assert_not_nil(assigns(:teams), "Should assign @teams")
    assert(!assigns(:teams).include?(nonmember), "Should only show member teams") unless RacingAssociation.current.show_all_teams_on_public_page?
    assert(!assigns(:teams).include?(hidden_team), "Should not show hidden teams") unless RacingAssociation.current.show_all_teams_on_public_page?
  end
end
