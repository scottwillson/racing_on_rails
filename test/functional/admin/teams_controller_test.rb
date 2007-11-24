require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/teams_controller'

# :stopdoc:
class Admin::TeamsController; def rescue_action(e) raise e end; end

class Admin::TeamsControllerTest < ActiveSupport::TestCase
  
  def setup
    @controller = Admin::TeamsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.host = "localhost"
    @request.session[:user] = users(:candi)
  end
  
  def test_not_logged_in_index
    @request.session[:user] = nil
    get(:index)
    assert_response(:redirect)
    assert_redirected_to(:controller => '/admin/account', :action => 'login')
    assert_nil(@request.session["user"], "No user in session")
  end
  
  def test_not_logged_in_edit
    @request.session[:user] = nil
    vanilla = teams(:vanilla)
    get(:edit_name, :id => vanilla.to_param)
    assert_response(:redirect)
    assert_redirected_to(:controller => '/admin/account', :action => 'login')
    assert_nil(@request.session["user"], "No user in session")
  end

  def test_index
    opts = {:controller => "admin/teams", :action => "index"}
    assert_routing("/admin/teams", opts)
    
    get(:index)
    assert_response(:success)
    assert_template("admin/teams/index")
    assert_not_nil(assigns["teams"], "Should assign teams")
    assert(assigns["teams"].empty?, "Should have no racers")
    assert_not_nil(assigns["name"], "Should assign name")
  end

  def test_find
    get(:index, :name => 'van')
    assert_response(:success)
    assert_template("admin/teams/index")
    assert_not_nil(assigns["teams"], "Should assign teams")
    assert_equal([teams(:vanilla)], assigns['teams'], 'Search for van should find Vanilla')
    assert_not_nil(assigns["name"], "Should assign name")
    assert_equal('van', assigns['name'], "'name' assigns")
  end
  
  def test_find_nothing
    get(:index, :name => 's7dfnacs89danfx')
    assert_response(:success)
    assert_template("admin/teams/index")
    assert_not_nil(assigns["teams"], "Should assign teams")
    assert_equal(0, assigns['teams'].size, "Should find no teams")
  end
  
  def test_find_empty_name
    get(:index, :name => '')
    assert_response(:success)
    assert_template("admin/teams/index")
    assert_not_nil(assigns["teams"], "Should assign teams")
    assert_equal(0, assigns['teams'].size, "Search for '' should find no teams")
    assert_not_nil(assigns["name"], "Should assign name")
    assert_equal('', assigns['name'], "'name' assigns")
  end

  def test_find_limit
    for i in 0..Admin::TeamsController::RESULTS_LIMIT
      Team.create(:name => "Test Team #{i}")
    end
    
    get(:index, :name => 'Test')
    assert_response(:success)
    assert_template("admin/teams/index")
    assert_not_nil(assigns["teams"], "Should assign teams")
    assert_equal(Admin::TeamsController::RESULTS_LIMIT, assigns['teams'].size, "Search for '' should find all teams")
    assert_not_nil(assigns["name"], "Should assign name")
    assert(!flash.empty?, 'flash not empty?')
    assert_equal('Test', assigns['name'], "'name' assigns")
  end
  
  def test_edit_name
    vanilla = teams(:vanilla)
    get(:edit_name, :id => vanilla.to_param)
    assert_response(:success)
    assert_template("admin/teams/_edit")
    assert_not_nil(assigns["team"], "Should assign team")
    assert_equal(vanilla, assigns['team'], 'Team')
  end

  def test_blank_name
    vanilla = teams(:vanilla)
    post(:update, :id => vanilla.to_param, :name => '')
    assert_response(:success)
    assert_template("admin/teams/_edit")
    assert_not_nil(assigns["team"], "Should assign team")
    assert(!assigns["team"].errors.empty?, 'Attempt to assign blank name should add error')
    assert_equal(vanilla, assigns['team'], 'Team')
    vanilla.reload
    assert_equal('Vanilla', vanilla.name, 'Team name after cancel')
  end

  def test_cancel
    vanilla = teams(:vanilla)
    original_name = vanilla.name
    get(:cancel, :id => vanilla.to_param, :name => vanilla.name)
    assert_response(:success)
    assert_template("admin/teams/_team")
    assert_not_nil(assigns["team"], "Should assign team")
    assert_equal(vanilla, assigns['team'], 'Team')
    vanilla.reload
    assert_equal(original_name, vanilla.name, 'Team name after cancel')
  end

  def test_update
    vanilla = teams(:vanilla)
    post(:update, :id => vanilla.to_param, :name => 'Vaniller')
    assert_response(:success)
    assert_not_nil(assigns["team"], "Should assign team")
    assert_equal(vanilla, assigns['team'], 'Team')
    assert(assigns['team'].errors.empty?, assigns['team'].errors.full_messages)
    assert_template("admin/teams/_team")
    vanilla.reload
    assert_equal('Vaniller', vanilla.name, 'Team name after update')
  end
  
  def test_update_same_name
    vanilla = teams(:vanilla)
    post(:update, :id => vanilla.to_param, :name => 'Vanilla')
    assert_response(:success)
    assert_template("admin/teams/_team")
    assert_not_nil(assigns["team"], "Should assign team")
    assert_equal(vanilla, assigns['team'], 'Team')
    vanilla.reload
    assert_equal('Vanilla', vanilla.name, 'Team name after update')
  end
  
  def test_update_same_name_different_case
    vanilla = teams(:vanilla)
    post(:update, :id => vanilla.to_param, :name => 'vanilla')
    assert_response(:success)
    assert_template("admin/teams/_team")
    assert_not_nil(assigns["team"], "Should assign team")
    assert_equal(vanilla, assigns['team'], 'Team')
    vanilla.reload
    assert_equal('vanilla', vanilla.name, 'Team name after update')
  end
  
  def test_update_to_existing_name
    # Should ask to merge
    
    vanilla = teams(:vanilla)
    post(:update, :id => vanilla.to_param, :name => 'Kona')
    assert_response(:success)
    assert_template("admin/teams/_merge_confirm")
    assert_not_nil(assigns["team"], "Should assign team")
    assert_equal(vanilla, assigns['team'], 'Team')
    assert_not_nil(Team.find_by_name('Vanilla'), 'Vanilla still in database')
    assert_not_nil(Team.find_by_name('Kona'), 'Kona still in database')
    vanilla.reload
    assert_equal('Vanilla', vanilla.name, 'Team name after cancel')
  end
  
  def test_update_to_existing_alias
    vanilla_alias = Alias.find_by_name('Vanilla')
    assert_nil(vanilla_alias, 'Alias')
    
    vanilla = teams(:vanilla)
    post(:update, :id => vanilla.to_param, :name => 'Vanilla Bicycles')
    assert_response(:success)
    assert_not_nil(assigns["team"], "Should assign team")
    assert(assigns["team"].errors.empty?, assigns["team"].errors.full_messages)
    assert_template("admin/teams/_team")
    assert_equal(vanilla, assigns['team'], 'Team')
    vanilla.reload
    assert_equal('Vanilla Bicycles', vanilla.name, 'Team name after cancel')
    vanilla_alias = Alias.find_by_name('Vanilla')
    assert_not_nil(vanilla_alias, 'Alias')
    assert_equal(vanilla, vanilla_alias.team, 'Alias team')
    old_vanilla_alias = Alias.find_by_name('Vanilla Bicycles')
    assert_nil(old_vanilla_alias, 'Alias')
  end
  
  def test_update_to_existing_alias_different_case
    vanilla_alias = Alias.find_by_name('Vanilla')
    assert_nil(vanilla_alias, 'Alias')
    
    vanilla = teams(:vanilla)
    post(:update, :id => vanilla.to_param, :name => 'vanilla bicycles')
    assert_response(:success)
    assert_template("admin/teams/_team")
    assert_not_nil(assigns["team"], "Should assign team")
    assert_equal(vanilla, assigns['team'], 'Team')
    vanilla.reload
    assert_equal('vanilla bicycles', vanilla.name, 'Team name after update')
    vanilla_alias = Alias.find_by_name('Vanilla')
    assert_not_nil(vanilla_alias, 'Alias')
    assert_equal(vanilla, vanilla_alias.team, 'Alias team')
    old_vanilla_alias = Alias.find_by_name('vanilla bicycles')
    assert_nil(old_vanilla_alias, 'Alias')
  end
  
  def test_update_to_other_team_existing_alias
    kona = teams(:kona)
    post(:update, :id => kona.to_param, :name => 'Vanilla Bicycles')
    assert_response(:success)
    assert_template("admin/teams/_merge_confirm")
    assert_not_nil(assigns["team"], "Should assign team")
    assert_equal(kona, assigns['team'], 'Team')
    assert_equal('Vanilla Bicycles', assigns['existing_team_name'], 'existing_team_name')
    assert_not_nil(Team.find_by_name('Kona'), 'Kona still in database')
    assert_not_nil(Team.find_by_name('Vanilla'), 'Vanilla still in database')
    assert_nil(Team.find_by_name('Vanilla Bicycles'), 'Vanilla Bicycles not in database')
  end
  
  def test_update_land_shark_bug
    landshark = Team.create(:name => 'Landshark')
    landshark_alias = landshark.aliases.create(:name => 'Landshark')
    land_shark_alias = landshark.aliases.create(:name => 'Land Shark')
    team_landshark_alias = landshark.aliases.create(:name => 'Team Landshark')
    
    post(:update, :id => landshark.to_param, :name => 'Land Shark')
    assert_response(:success)
    assert_not_nil(assigns["team"], "Should assign team")
    assert(assigns["team"].errors.empty?, assigns["team"].errors.full_messages)
    assert_template("admin/teams/_team")
    assert_equal(landshark, assigns['team'], 'Team')
    landshark.reload
    assert_equal('Land Shark', landshark.name, 'Updated name')
    assert_equal(2, landshark.aliases(true).size, 'Aliases')
    assert(landshark.aliases.any? {|a| a.name == 'Landshark'}, 'Aliases should include Landshark')
    assert(!landshark.aliases.any? {|a| a.name == 'Land Shark'}, 'Aliases should not include Land Shark')
    assert(!landshark.aliases.any? {|a| a.name == 'LandTeam Landshark'}, 'Aliases should not include Team Landshark')
    # try with different cases
  end
  
  def test_destroy
    csc = Team.create(:name => 'CSC')
    post(:destroy, :id => csc.id, :commit => 'Delete')
    assert_response(:success)
    assert_raise(ActiveRecord::RecordNotFound, 'CSC should have been destroyed') { Team.find(csc.id) }
  end
  
  def test_merge?
    vanilla = teams(:vanilla)
    kona = teams(:kona)
    get(:update, :name => vanilla.name, :id => kona.to_param)
    assert_response(:success)
    assert_template("admin/teams/_merge_confirm")
    assert_equal(kona, assigns['team'], 'Team')
    assert_equal(vanilla.name, assigns['team'].name, 'Unsaved Kona name should be Vanilla')
    assert_equal(vanilla, assigns['existing_team'], 'Existing Team')
  end
  
  def test_merge
    vanilla = teams(:vanilla)
    kona = teams(:kona)
    old_id = kona.id
    assert(Team.find_by_name('Kona'), 'Kona should be in database')

    
    get(:merge, :id => kona.to_param, :target_id => vanilla.id)
    assert_response(:success)
    assert_template("admin/teams/merge")

    assert(Team.find_by_name('Vanilla'), 'Vanilla should be in database')
    assert_nil(Team.find_by_name('Kona'), 'Kona should not be in database')
  end

  def test_new_inline
    opts = {:controller => "admin/teams", :action => "new_inline"}
    assert_routing("/admin/teams/new_inline", opts)
  
    get(:new_inline)
    assert_response(:success)
    assert_template("/admin/_new_inline")
    assert_not_nil(assigns["record"], "Should assign team as 'record'")
    assert_not_nil(assigns["icon"], "Should assign 'icon'")
  end

  def test_update_member
    vanilla = teams(:vanilla)
    assert_equal(true, vanilla.member, 'member before update')
    post(:toggle_attribute, :id => vanilla.to_param, :attribute => 'member')
    assert_response(:success)
    assert_template("/admin/_attribute")
    vanilla.reload
    assert_equal(false, vanilla.member, 'member after update')

    vanilla = teams(:vanilla)
    post(:toggle_attribute, :id => vanilla.to_param, :attribute => 'member')
    assert_response(:success)
    assert_template("/admin/_attribute")
    vanilla.reload
    assert_equal(true, vanilla.member, 'member after second update')
  end

  def test_show
    vanilla = teams(:vanilla)
    opts = {:controller => "admin/teams", :action => "show", :id => vanilla.to_param.to_s}
    assert_routing("/admin/teams/#{vanilla.to_param}", opts)
    
    get(:show, :id => vanilla.to_param)
    assert_response(:success)
    assert_template("admin/teams/show")
    assert_not_nil(assigns["team"], "Should assign team")
    assert_equal(vanilla, assigns['team'], 'Should assign Vanilla to team')
  end
  
  def test_destroy_alias
    vanilla = teams(:vanilla)
    assert_equal(1, vanilla.aliases.count, 'Vanilla aliases')
    vanilla_bicycles_alias = vanilla.aliases.first

    opts = {:controller => "admin/teams", :action => "destroy_alias", :id => vanilla.id.to_s, :alias_id => vanilla_bicycles_alias.id.to_s}
    assert_routing("/admin/teams/#{vanilla.id}/aliases/#{vanilla_bicycles_alias.id}/destroy", opts)
    
    post(:destroy_alias, :id => vanilla_bicycles_alias.id.to_s, :alias_id => vanilla_bicycles_alias.id.to_s)
    assert_response(:success)
    assert_equal(0, vanilla.aliases(true).count, 'Vanilla aliases after destruction')
  end
end
