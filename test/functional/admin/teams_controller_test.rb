require "test_helper"

# :stopdoc:
class Admin::TeamsControllerTest < ActionController::TestCase  
  def setup
    @request.session[:user_id] = users(:administrator).id
  end
  
  def test_not_logged_in_index
    @request.session[:user_id] = nil
    get(:index)
    assert_response(:redirect)
    assert_redirected_to(:controller => '/account', :action => 'login')
    assert_nil(@request.session["user"], "No user in session")
  end
  
  def test_not_logged_in_edit
    @request.session[:user_id] = nil
    vanilla = teams(:vanilla)
    get(:edit_name, :id => vanilla.to_param)
    assert_response(:redirect)
    assert_redirected_to(:controller => '/account', :action => 'login')
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
  
  def test_blank_name
    vanilla = teams(:vanilla)
    post(:set_team_name, 
        :id => vanilla.to_param,
        :value => "",
        :editorId => "team_#vanilla.id}_name"
    )
    assert_response(:success)
    assert_template(nil)
    assert_not_nil(assigns["team"], "Should assign team")
    assert(!assigns["team"].errors.empty?, 'Attempt to assign blank name should add error')
    assert_equal(vanilla, assigns['team'], 'Team')
    vanilla.reload
    assert_equal('Vanilla', vanilla.name, 'Team name after cancel')
  end

  def test_set_name
    vanilla = teams(:vanilla)
    post(:set_team_name, 
        :id => vanilla.to_param,
        :value => "Vaniller",
        :editorId => "team_#vanilla.id}_name"
    )
    assert_response(:success)
    assert_not_nil(assigns["team"], "Should assign team")
    assert_equal(vanilla, assigns['team'], 'Team')
    assert(assigns['team'].errors.empty?, assigns['team'].errors.full_messages)
    assert_template(nil)
    vanilla.reload
    assert_equal('Vaniller', vanilla.name, 'Team name after update')
  end
  
  def test_set_name_same_name
    vanilla = teams(:vanilla)
    post(:set_team_name, 
        :id => vanilla.to_param,
        :value => "Vanilla",
        :editorId => "team_#vanilla.id}_name"
    )
    assert_response(:success)
    assert_template(nil)
    assert_not_nil(assigns["team"], "Should assign team")
    assert_equal(vanilla, assigns['team'], 'Team')
    vanilla.reload
    assert_equal('Vanilla', vanilla.name, 'Team name after update')
  end
  
  def test_set_name_same_name_different_case
    vanilla = teams(:vanilla)
    post(:set_team_name, 
        :id => vanilla.to_param,
        :value => "vanilla",
        :editorId => "team_#vanilla.id}_name"
    )
    assert_response(:success)
    assert_template(nil)
    assert_not_nil(assigns["team"], "Should assign team")
    assert_equal(vanilla, assigns['team'], 'Team')
    vanilla.reload
    assert_equal('vanilla', vanilla.name, 'Team name after update')
  end
  
  def test_set_name_to_existing_name
    # Should ask to merge
    
    vanilla = teams(:vanilla)
    post(:set_team_name, 
        :id => vanilla.to_param,
        :value => "Kona",
        :editorId => "team_#vanilla.id}_name"
    )
    assert_response(:success)
    assert_template("admin/teams/_merge_confirm")
    assert_not_nil(assigns["team"], "Should assign team")
    assert_equal(vanilla, assigns['team'], 'Team')
    assert_not_nil(Team.find_by_name('Vanilla'), 'Vanilla still in database')
    assert_not_nil(Team.find_by_name('Kona'), 'Kona still in database')
    vanilla.reload
    assert_equal('Vanilla', vanilla.name, 'Team name after cancel')
  end
  
  def test_set_name_to_existing_alias
    vanilla_alias = Alias.find_by_name('Vanilla')
    assert_nil(vanilla_alias, 'Alias')
    
    vanilla = teams(:vanilla)
    post(:set_team_name, 
        :id => vanilla.to_param,
        :value => "Vanilla Bicycles",
        :editorId => "team_#vanilla.id}_name"
    )
    assert_response(:success)
    assert_not_nil(assigns["team"], "Should assign team")
    assert(assigns["team"].errors.empty?, assigns["team"].errors.full_messages)
    assert_template(nil)
    assert_equal(vanilla, assigns['team'], 'Team')
    vanilla.reload
    assert_equal('Vanilla Bicycles', vanilla.name, 'Team name after cancel')
    vanilla_alias = Alias.find_by_name('Vanilla')
    assert_not_nil(vanilla_alias, 'Alias')
    assert_equal(vanilla, vanilla_alias.team, 'Alias team')
    old_vanilla_alias = Alias.find_by_name('Vanilla Bicycles')
    assert_nil(old_vanilla_alias, 'Alias')
  end
  
  def test_set_name_to_existing_alias_different_case
    vanilla_alias = Alias.find_by_name('Vanilla')
    assert_nil(vanilla_alias, 'Alias')
    
    vanilla = teams(:vanilla)
    post(:set_team_name, 
        :id => vanilla.to_param,
        :value => "vanilla bicycles",
        :editorId => "team_#vanilla.id}_name"
    )
    assert_response(:success)
    assert_template(nil)
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
  
  def test_set_name_to_other_team_existing_alias
    kona = teams(:kona)
    post(:set_team_name, 
        :id => kona.to_param,
        :value => "Vanilla Bicycles",
        :editorId => "team_#kona.id}_name"
    )
    assert_response(:success)
    assert_template("admin/teams/_merge_confirm")
    assert_not_nil(assigns["team"], "Should assign team")
    assert_equal(kona, assigns['team'], 'Team')
    assert_equal([teams(:vanilla)], assigns['existing_teams'], 'existing_teams')
    assert_not_nil(Team.find_by_name('Kona'), 'Kona still in database')
    assert_not_nil(Team.find_by_name('Vanilla'), 'Vanilla still in database')
    assert_nil(Team.find_by_name('Vanilla Bicycles'), 'Vanilla Bicycles not in database')
  end
  
  def test_set_name_land_shark_bug
    landshark = Team.create(:name => 'Landshark')
    landshark_alias = landshark.aliases.create(:name => 'Landshark')
    land_shark_alias = landshark.aliases.create(:name => 'Land Shark')
    team_landshark_alias = landshark.aliases.create(:name => 'Team Landshark')
    
    post(:set_team_name, 
        :id => landshark.to_param,
        :value => "Land Shark",
        :editorId => "team_#landshark.id}_name"
    )
    assert_response(:success)
    assert_not_nil(assigns["team"], "Should assign team")
    assert(assigns["team"].errors.empty?, assigns["team"].errors.full_messages)
    assert_template(nil)
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
    delete(:destroy, :id => csc.id)
    assert_redirected_to(admin_teams_path)
    assert(!Team.exists?(csc.id), 'CSC should have been destroyed')
  end
  
  def test_destroy_team_with_results_should_not_cause_hard_errors
    team = teams(:gentle_lovers)
    delete(:destroy, :id => team.id)
    assert(Team.exists?(team.id), 'Team should not have been destroyed')
    assert(!assigns(:team).errors.empty?, "Team should have error")
    assert_response(:success)
  end

  def test_merge?
    vanilla = teams(:vanilla)
    kona = teams(:kona)
    post(:set_team_name, 
        :id => kona.to_param,
        :value => vanilla.name,
        :editorId => "team_#kona.id}_name"
    )
    assert_response(:success)
    assert_template("admin/teams/_merge_confirm")
    assert_equal(kona, assigns['team'], 'Team')
    assert_equal(vanilla.name, assigns['team'].name, 'Unsaved Kona name should be Vanilla')
    assert_equal([vanilla], assigns['existing_teams'], 'Existing Team')
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

  def test_toggle_member
    vanilla = teams(:vanilla)
    assert_equal(true, vanilla.member, 'member before update')
    post(:toggle_member, :id => vanilla.to_param)
    assert_response(:success)
    assert_template("shared/_member")
    vanilla.reload
    assert_equal(false, vanilla.member, 'member after update')

    vanilla = teams(:vanilla)
    post(:toggle_member, :id => vanilla.to_param)
    assert_response(:success)
    assert_template("shared/_member")
    vanilla.reload
    assert_equal(true, vanilla.member, 'member after second update')
  end

  def test_edit
    vanilla = teams(:vanilla)
    opts = {:controller => "admin/teams", :action => "edit", :id => vanilla.to_param.to_s}
    assert_routing("/admin/teams/#{vanilla.to_param}/edit", opts)
    
    get(:edit, :id => vanilla.to_param)
    assert_response(:success)
    assert_template("admin/teams/edit")
    assert_not_nil(assigns["team"], "Should assign team")
    assert_equal(vanilla, assigns['team'], 'Should assign Vanilla to team')
  end
  
  def test_destroy_alias
    vanilla = teams(:vanilla)
    assert_equal(1, vanilla.aliases.count, 'Vanilla aliases')
    vanilla_bicycles_alias = vanilla.aliases.first

    opts = {:controller => "admin/teams", :action => "destroy_alias", :id => vanilla.id.to_s, :alias_id => vanilla_bicycles_alias.id.to_s}
    assert_routing("/admin/teams/#{vanilla.id}/aliases/#{vanilla_bicycles_alias.id}/destroy", opts)
    
    post(:destroy_alias, :id => vanilla.id.to_s, :alias_id => vanilla_bicycles_alias.id.to_s)
    assert_response(:success)
    assert_equal(0, vanilla.aliases(true).count, 'Vanilla aliases after destruction')
  end
  
  def test_destroy_historical_name
    vanilla = teams(:vanilla)
    vanilla.historical_names.create!(:name => "Generic Team", :year => 1990)
    assert_equal(1, vanilla.historical_names.count, "Vanilla historical_names")
    historical_name = vanilla.historical_names.first

    post(:destroy_historical_name, :id => vanilla.to_param, :historical_name_id => historical_name.to_param)
    assert_response(:success)
    assert_equal(0, vanilla.historical_names(true).count, 'Vanilla historical_names after destruction')
  end
  
  def test_new
    get(:new)
    assert_response(:success)
    assert_not_nil(assigns(:team), "@team")
  end
  
  def test_create
    post(:create, :team => { :name => "My Fancy New Bike Team" })
    team = Team.find_by_name("My Fancy New Bike Team")
    assert_not_nil(team, "Should create new team")
    assert_redirected_to(edit_admin_team_path(team))
  end
  
  def test_update
    team = teams(:vanilla)
    post(:update, :id => team.to_param, :team => { :name => "Speedvagen", 
                                                   :website => "http://speedvagen.net",
                                                   :sponsors => %Q{<a href="http://stumptowncoffeeroasters">Stumptown</a>},
                                                   :contact_name => "Sacha White",
                                                   :contact_email => "sacha@speedvagen.net",
                                                   :contact_phone => "14115555",
                                                   :member => true
                                                 })
    assert_redirected_to(edit_admin_team_path(team))
    team.reload
    assert_equal("Speedvagen", team.name, "Name should be updated")
    assert_equal("http://speedvagen.net", team.website, "website should be updated")
    assert_equal( %Q{<a href="http://stumptowncoffeeroasters">Stumptown</a>}, team.sponsors, "sponsors should be updated")
    assert_equal("Sacha White", team.contact_name, "contact_name should be updated")
    assert_equal("sacha@speedvagen.net", team.contact_email, "contact_email should be updated")
    assert_equal("14115555", team.contact_phone, "contact_phone should be updated")
    assert(team.member?, "member should be updated")
  end
  
  def test_invalid_update
    team = teams(:vanilla)
    post :update, :id => team.to_param, :team => { :name => "" }
    assert_response :success
    assert_not_nil assigns(:team), "@team"
    assert !assigns(:team).errors.empty?, "@team should have errors"
  end
end
