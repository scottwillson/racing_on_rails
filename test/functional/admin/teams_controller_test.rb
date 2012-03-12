require File.expand_path("../../../test_helper", __FILE__)

# :stopdoc:
class Admin::TeamsControllerTest < ActionController::TestCase  
  def setup
    super
    create_administrator_session
    use_ssl
  end
  
  def test_not_logged_in_index
    destroy_person_session
    get(:index)
    assert_redirected_to new_person_session_url(secure_redirect_options)
    assert_nil(@request.session["person"], "No person in session")
  end
  
  def test_not_logged_in_edit
    destroy_person_session
    vanilla = FactoryGirl.create(:team)
    get(:edit, :id => vanilla.to_param)
    assert_redirected_to new_person_session_url(secure_redirect_options)
    assert_nil(@request.session["person"], "No person in session")
  end

  def test_index
    get(:index)
    assert_response(:success)
    assert_template("admin/teams/index")
    assert_not_nil(assigns["teams"], "Should assign teams")
    assert(assigns["teams"].empty?, "Should have no people")
    assert_not_nil(assigns["name"], "Should assign name")
  end
  
  def test_index_with_cookie
    FactoryGirl.create(:team, :name => "Gentle Lovers")
    @request.cookies["team_name"] = "gentle"
    get(:index)
    assert_response(:success)
    assert_template("admin/teams/index")
    assert_not_nil(assigns["teams"], "Should assign teams")
    assert_equal("gentle", assigns["name"], "Should assign name")
    assert_equal(1, assigns["teams"].size, "Should have no teams")
  end
  
  def test_index_rjs
    vanilla = FactoryGirl.create(:team, :name => "Vanilla Bicycles")
    get(:index, :name => 'nilla', :format => "js")
    assert_response(:success)
    assert_template("admin/teams/index")
    assert_not_nil(assigns["teams"], "Should assign teams")
    assert_equal([vanilla], assigns['teams'], 'Search for nilla should find Vanilla')
  end

  def test_find
    vanilla = FactoryGirl.create(:team, :name => "Vanilla Bicycles")
    get(:index, :name => 'van')
    assert_response(:success)
    assert_template("admin/teams/index")
    assert_not_nil(assigns["teams"], "Should assign teams")
    assert_equal([vanilla], assigns['teams'], 'Search for van should find Vanilla')
    assert_not_nil(assigns["name"], "Should assign name")
    assert_equal('van', assigns['name'], "'name' assigns")
  end
  
  def test_find_json
    vanilla = FactoryGirl.create(:team, :name => "Vanilla Bicycles")
    get :index, :name => 'van', :format => "json"
    assert_response :success
    assert_equal [vanilla], assigns['teams'], "Search for 'van' should find Vanilla"
    assert_equal "van", assigns["name"], "'name' assigns"
  end
  
  def test_find_nothing
    vanilla = FactoryGirl.create(:team, :name => "Vanilla Bicycles")
    FactoryGirl.create(:team)
    
    get(:index, :name => 's7dfnacs89danfx')
    assert_response(:success)
    assert_template("admin/teams/index")
    assert_not_nil(assigns["teams"], "Should assign teams")
    assert_equal(0, assigns['teams'].size, "Should find no teams")
  end
  
  def test_find_empty_name
    vanilla = FactoryGirl.create(:team, :name => "Vanilla Bicycles")

    get(:index, :name => '')
    assert_response(:success)
    assert_template("admin/teams/index")
    assert_not_nil(assigns["teams"], "Should assign teams")
    assert_equal(0, assigns['teams'].size, "Search for '' should find no teams")
    assert_not_nil(assigns["name"], "Should assign name")
    assert_equal('', assigns['name'], "'name' assigns")
  end

  def test_find_limit
    for i in 0..RacingAssociation.current.search_results_limit
      Team.create(:name => "Test Team #{i}")
    end
    
    get(:index, :name => 'Test')
    assert_response(:success)
    assert_template("admin/teams/index")
    assert_not_nil(assigns["teams"], "Should assign teams")
    assert_equal(RacingAssociation.current.search_results_limit, assigns['teams'].size, "Search for '' should find all teams")
    assert_not_nil(assigns["name"], "Should assign name")
    assert(!flash.empty?, 'flash not empty?')
    assert_equal('Test', assigns['name'], "'name' assigns")
  end
  
  def test_blank_name
    vanilla = FactoryGirl.create(:team, :name => "Vanilla Bicycles")
    assert_raise(ActiveRecord::RecordInvalid) do
      xhr :put, :update_attribute, 
          :id => vanilla.to_param,
          :name => "name",
          :value => ""
    end
    assert_template(nil)
    assert_not_nil(assigns["team"], "Should assign team")
    assert(!assigns["team"].errors.empty?, 'Attempt to assign blank name should add error')
    assert_equal(vanilla, assigns['team'], 'Team')
    vanilla.reload
    assert_equal('Vanilla Bicycles', vanilla.name, 'Team name')
  end

  def test_set_name
    vanilla = FactoryGirl.create(:team, :name => "Vanilla Bicycles")
    xhr :put, :update_attribute, 
        :id => vanilla.to_param,
        :name => "name",
        :value => "Vaniller"
    assert_response(:success)
    assert_not_nil(assigns["team"], "Should assign team")
    assert_equal(vanilla, assigns['team'], 'Team')
    assert assigns['team'].errors.empty?, assigns['team'].errors.full_messages.join
    assert_template(nil)
    vanilla.reload
    assert_equal('Vaniller', vanilla.name, 'Team name after update')
  end
  
  def test_set_name_same_name
    vanilla = FactoryGirl.create(:team, :name => "Vanilla Bicycles")
    xhr :put, :update_attribute, 
        :id => vanilla.to_param,
        :name => "name",
        :value => "Vanilla"
    assert_response(:success)
    assert_template(nil)
    assert_not_nil(assigns["team"], "Should assign team")
    assert_equal(vanilla, assigns['team'], 'Team')
    vanilla.reload
    assert_equal('Vanilla', vanilla.name, 'Team name after update')
  end
  
  def test_set_name_same_name_different_case
    vanilla = FactoryGirl.create(:team, :name => "Vanilla Bicycles")
    xhr :put, :update_attribute, 
        :id => vanilla.to_param,
        :name => "name",
        :value => "vanilla"
    assert_response(:success)
    assert_template(nil)
    assert_not_nil(assigns["team"], "Should assign team")
    assert_equal(vanilla, assigns['team'], 'Team')
    vanilla.reload
    assert_equal('vanilla', vanilla.name, 'Team name after update')
  end
  
  def test_set_name_to_existing_name
    vanilla = FactoryGirl.create(:team, :name => "Vanilla Bicycles")
    FactoryGirl.create(:team, :name => "Kona")

    xhr :put, :update_attribute, 
        :id => vanilla.to_param,
        :name => "name",
        :value => "Kona"
    assert_response(:success)
    assert_template("admin/teams/merge_confirm")
    assert_not_nil(assigns["team"], "Should assign team")
    assert_equal(vanilla, assigns['team'], 'Team')
    assert_not_nil(Team.find_by_name('Vanilla Bicycles'), 'Vanilla still in database')
    assert_not_nil(Team.find_by_name('Kona'), 'Kona still in database')
    vanilla.reload
    assert_equal('Vanilla Bicycles', vanilla.name, 'Team name after cancel')
  end
  
  def test_set_name_to_existing_alias
    vanilla = FactoryGirl.create(:team, :name => "Vanilla")
    vanilla.aliases.create!(:name => "Vanilla Bicycles")
    
    xhr :put, :update_attribute, 
        :id => vanilla.to_param,
        :name => "name",
        :value => "Vanilla Bicycles"
    assert_response(:success)
    assert_not_nil(assigns["team"], "Should assign team")
    assert assigns["team"].errors.empty?, assigns["team"].errors.full_messages.join
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
    vanilla = FactoryGirl.create(:team, :name => "Vanilla")
    vanilla.aliases.create!(:name => "Vanilla Bicycles")
    
    vanilla = vanilla
    xhr :put, :update_attribute, 
        :id => vanilla.to_param,
        :name => "name",
        :value => "vanilla bicycles"
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
    vanilla = FactoryGirl.create(:team, :name => "Vanilla")
    vanilla.aliases.create!(:name => "Vanilla Bicycles")
    
    kona = FactoryGirl.create(:team, :name => "Kona")
    
    xhr :put, :update_attribute, 
        :id => kona.to_param,
        :name => "name",
        :value => "Vanilla Bicycles"
    assert_response(:success)
    assert_template("admin/teams/merge_confirm")
    assert_not_nil(assigns["team"], "Should assign team")
    assert_equal(kona, assigns['team'], 'Team')
    assert_equal([vanilla], assigns['other_teams'], 'existing_teams')
    assert_not_nil(Team.find_by_name('Kona'), 'Kona still in database')
    assert_not_nil(Team.find_by_name('Vanilla'), 'Vanilla still in database')
    assert_nil(Team.find_by_name('Vanilla Bicycles'), 'Vanilla Bicycles not in database')
  end
  
  def test_set_name_land_shark_bug
    landshark = Team.create(:name => 'Landshark')
    landshark_alias = landshark.aliases.create(:name => 'Landshark')
    land_shark_alias = landshark.aliases.create(:name => 'Land Shark')
    team_landshark_alias = landshark.aliases.create(:name => 'Team Landshark')
    
    xhr :put, :update_attribute, 
        :id => landshark.to_param,
        :name => "name",
        :value => "Land Shark"
    assert_response(:success)
    assert_not_nil(assigns["team"], "Should assign team")
    assert assigns["team"].errors.empty?, assigns["team"].errors.full_messages.join
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
    csc = Team.create!(:name => 'CSC')
    delete(:destroy, :id => csc.id)
    assert_redirected_to(admin_teams_path)
    assert(!Team.exists?(csc.id), 'CSC should have been destroyed')
  end
  
  def test_destroy_team_with_results_should_not_cause_hard_errors
    team = FactoryGirl.create(:result).team
    delete(:destroy, :id => team.id)
    assert(Team.exists?(team.id), 'Team should not have been destroyed')
    assert(!assigns(:team).errors.empty?, "Team should have error")
    assert_response(:success)
  end

  def test_merge?
    vanilla = FactoryGirl.create(:team, :name => "Vanilla")
    kona = FactoryGirl.create(:team)
    xhr :put, :update_attribute, 
        :id => kona.to_param,
        :name => "name",
        :value => "Vanilla"
    assert_response(:success)
    assert_template("admin/teams/merge_confirm")
    assert_equal(kona, assigns['team'], 'Team')
    assert_equal(vanilla.name, assigns['team'].name, 'Unsaved Kona name should be Vanilla')
    assert_equal([vanilla], assigns['other_teams'], 'Existing Team')
  end
  
  def test_merge
    vanilla = FactoryGirl.create(:team, :name => "Vanilla")
    kona = FactoryGirl.create(:team, :name => "Kona")
    old_id = kona.id
    assert(Team.find_by_name('Kona'), 'Kona should be in database')
    
    xhr :post, :merge, :id => vanilla.id, :other_team_id => kona.to_param
    assert_response(:success)
    assert_template("admin/teams/merge")

    assert(Team.find_by_name('Vanilla'), 'Vanilla should be in database')
    assert_nil(Team.find_by_name('Kona'), 'Kona should not be in database')
  end

  def test_toggle_member
    vanilla = FactoryGirl.create(:team, :name => "Vanilla")

    assert_equal(true, vanilla.member, 'member before update')
    post(:toggle_member, :id => vanilla.to_param)
    assert_response(:success)
    assert_template("shared/_member")
    vanilla.reload
    assert_equal(false, vanilla.member, 'member after update')

    post(:toggle_member, :id => vanilla.to_param)
    assert_response(:success)
    assert_template("shared/_member")
    vanilla.reload
    assert_equal(true, vanilla.member, 'member after second update')
  end

  def test_edit
    vanilla = FactoryGirl.create(:team, :name => "Vanilla")
    get(:edit, :id => vanilla.to_param)
    assert_response(:success)
    assert_template("admin/teams/edit")
    assert_not_nil(assigns["team"], "Should assign team")
    assert_equal(vanilla, assigns['team'], 'Should assign Vanilla to team')
  end
  
  def test_destroy_name
    vanilla = FactoryGirl.create(:team, :name => "Vanilla")
    vanilla.names.create!(:name => "Generic Team", :year => 1990)
    assert_equal(1, vanilla.names.count, "Vanilla names")
    name = vanilla.names.first

    xhr :post, :destroy_name, :id => vanilla.to_param, :name_id => name.to_param
    assert_response(:success)
    assert_equal(0, vanilla.names(true).count, 'Vanilla names after destruction')
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
    team = FactoryGirl.create(:team, :name => "Vanilla")
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
    team = FactoryGirl.create(:team, :name => "Vanilla")
    post :update, :id => team.to_param, :team => { :name => "" }
    assert_response :success
    assert_not_nil assigns(:team), "@team"
    assert !assigns(:team).errors.empty?, "@team should have errors"
  end
end
