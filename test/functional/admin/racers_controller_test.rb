require File.dirname(__FILE__) + '/../../test_helper'

class Admin::RacersControllerTest < ActionController::TestCase

  def setup
    super
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
    weaver = racers(:weaver)
    get(:edit_name, :id => weaver.to_param)
    assert_response(:redirect)
    assert_redirected_to(:controller => '/admin/account', :action => 'login')
    assert_nil(@request.session["user"], "No user in session")
  end

  def test_index
    opts = {:controller => "admin/racers", :action => "index"}
    assert_routing("/admin/racers", opts)
    
    get(:index)
    assert_response(:success)
    assert_template("admin/racers/index")
    assert_equal('layouts/admin/application', @controller.active_layout)
    assert_not_nil(assigns["racers"], "Should assign racers")
    assert(assigns["racers"].empty?, "Should have no racers")
    assert_not_nil(assigns["name"], "Should assign name")
  end

  def test_find
    get(:index, :name => 'weav')
    assert_response(:success)
    assert_template("admin/racers/index")
    assert_not_nil(assigns["racers"], "Should assign racers")
    assert_equal([racers(:weaver)], assigns['racers'], 'Search for weav should find Weaver')
    assert_not_nil(assigns["name"], "Should assign name")
    assert_equal('weav', assigns['name'], "'name' assigns")
  end

  def test_find_by_number
    get(:index, :name => '102')
    assert_response(:success)
    assert_template("admin/racers/index")
    assert_not_nil(assigns["racers"], "Should assign racers")
    assert_equal([racers(:tonkin)], assigns['racers'], 'Search for 102 should find Tonkin')
    assert_not_nil(assigns["name"], "Should assign name")
    assert_equal('102', assigns['name'], "'name' assigns")
  end

  def test_find_nothing
    get(:index, :name => 's7dfnacs89danfx')
    assert_response(:success)
    assert_template("admin/racers/index")
    assert_not_nil(assigns["racers"], "Should assign racers")
    assert_equal(0, assigns['racers'].size, "Should find no racers")
  end
  
  def test_find_empty_name
    get(:index, :name => '')
    assert_response(:success)
    assert_template("admin/racers/index")
    assert_not_nil(assigns["racers"], "Should assign racers")
    assert_equal(0, assigns['racers'].size, "Search for '' should find no racers")
    assert_not_nil(assigns["name"], "Should assign name")
    assert_equal('', assigns['name'], "'name' assigns")
  end

  def test_find_limit
    for i in 0..Admin::RacersController::RESULTS_LIMIT
      Racer.create(:name => "Test Racer #{i}")
    end
    get(:index, :name => 'Test')
    assert_response(:success)
    assert_template("admin/racers/index")
    assert_not_nil(assigns["racers"], "Should assign racers")
    assert_equal(Admin::RacersController::RESULTS_LIMIT, assigns['racers'].size, "Search for '' should find all racers")
    assert_not_nil(assigns["name"], "Should assign name")
    assert(!flash.empty?, 'flash not empty?')
    assert_equal('Test', assigns['name'], "'name' assigns")
  end

  def test_edit_name
    weaver = racers(:weaver)
    get(:edit_name, :id => weaver.to_param)
    assert_response(:success)
    assert_template("admin/racers/_edit")
    assert_not_nil(assigns["racer"], "Should assign racer")
    assert_equal(weaver, assigns['racer'], 'Should assign racer')
  end

  def test_blank_name
    molly = racers(:molly)
    post(:update_name, :id => molly.to_param, :name => '')
    assert_response(:success)
    racer = assigns["racer"]
    assert_not_nil(racer, "Should assign racer")
    assert(racer.errors.empty?, "Should have no errors, but had: #{racer.errors.full_messages}")
    assert_template("admin/racers/_racer_name")
    assert_equal(molly, assigns['racer'], 'Racer')
    molly.reload
    assert_equal('', molly.first_name, 'Racer first_name after update')
    assert_equal('', molly.last_name, 'Racer last_name after update')
  end

  def test_cancel
    molly = racers(:molly)
    original_name = molly.name
    get(:cancel, :id => molly.to_param, :name => molly.name)
    assert_response(:success)
    assert_template("admin/racers/_racer_name")
    assert_not_nil(assigns["racer"], "Should assign racer")
    assert_equal(molly, assigns['racer'], 'Racer')
    molly.reload
    assert_equal(original_name, molly.name, 'Racer name after cancel')
  end

  def test_update_name
    molly = racers(:molly)
    post(:update_name, :id => molly.to_param, :name => 'Mollie Cameron')
    assert_response(:success)
    assert_template("admin/racers/_racer_name")
    assert_not_nil(assigns["racer"], "Should assign racer")
    assert_equal(molly, assigns['racer'], 'Racer')
    molly.reload
    assert_equal('Mollie', molly.first_name, 'Racer first_name after update')
    assert_equal('Cameron', molly.last_name, 'Racer last_name after update')
  end
  
  def test_update_same_name
    molly = racers(:molly)
    post(:update_name, :id => molly.to_param, :name => 'Molly Cameron')
    assert_response(:success)
    assert_template("admin/racers/_racer_name")
    assert_not_nil(assigns["racer"], "Should assign racer")
    assert_equal(molly, assigns['racer'], 'Racer')
    molly.reload
    assert_equal('Molly', molly.first_name, 'Racer first_name after update')
    assert_equal('Cameron', molly.last_name, 'Racer last_name after update')
  end
  
  def test_update_same_name_different_case
    molly = racers(:molly)
    post(:update_name, :id => molly.to_param, :name => 'molly cameron')
    assert_response(:success)
    assert_template("admin/racers/_racer_name")
    assert_not_nil(assigns["racer"], "Should assign racer")
    assert_equal(molly, assigns['racer'], 'Racer')
    molly.reload
    assert_equal('molly', molly.first_name, 'Racer first_name after update')
    assert_equal('cameron', molly.last_name, 'Racer last_name after update')
  end
  
  def test_update_to_existing_name
    # Should ask to merge
    molly = racers(:molly)
    post(:update_name, :id => molly.to_param, :name => 'Erik Tonkin')
    assert_response(:success)
    assert_template("admin/racers/_merge_confirm")
    assert_not_nil(assigns["racer"], "Should assign racer")
    assert_equal(molly, assigns['racer'], 'Racer')
    assert_not_nil(Racer.find_all_by_name('Molly Cameron'), 'Molly still in database')
    assert_not_nil(Racer.find_all_by_name('Erik Tonkin'), 'Tonkin still in database')
    molly.reload
    assert_equal('Molly Cameron', molly.name, 'Racer name after cancel')
  end
  
  def test_update_to_existing_alias
    erik_alias = Alias.find_by_name('Eric Tonkin')
    assert_not_nil(erik_alias, 'Alias')

    tonkin = racers(:tonkin)
    post(:update_name, :id => tonkin.to_param, :name => 'Eric Tonkin')
    assert_response(:success)
    assert_template("admin/racers/_racer_name")
    assert_not_nil(assigns["racer"], "Should assign racer")
    assert_equal(tonkin, assigns['racer'], 'Racer')
    tonkin.reload
    assert_equal('Eric Tonkin', tonkin.name, 'Racer name after cancel')
    erik_alias = Alias.find_by_name('Erik Tonkin')
    assert_not_nil(erik_alias, 'Alias')
    assert_equal(tonkin, erik_alias.racer, 'Alias racer')
    old_erik_alias = Alias.find_by_name('Eric Tonkin')
    assert_nil(old_erik_alias, 'Old alias')
  end
  
  def test_update_to_existing_alias_different_case
    molly_alias = Alias.find_by_name('Molly Cameron')
    assert_nil(molly_alias, 'Alias')
    mollie_alias = Alias.find_by_name('Mollie Cameron')
    assert_not_nil(mollie_alias, 'Alias')

    molly = racers(:molly)
    post(:update_name, :id => molly.to_param, :name => 'mollie cameron')
    assert_response(:success)
    assert_template("admin/racers/_racer_name")
    assert_not_nil(assigns["racer"], "Should assign racer")
    assert_equal(molly, assigns['racer'], 'Racer')
    molly.reload
    assert_equal('mollie cameron', molly.name, 'Racer name after update')
    molly_alias = Alias.find_by_name('Molly Cameron')
    assert_not_nil(molly_alias, 'Alias')
    assert_equal(molly, molly_alias.racer, 'Alias racer')
    mollie_alias = Alias.find_by_name('mollie cameron')
    assert_nil(mollie_alias, 'Alias')
  end
  
  def test_update_to_other_racer_existing_alias
    tonkin = racers(:tonkin)
    post(:update_name, :id => tonkin.to_param, :name => 'Mollie Cameron')
    assert_response(:success)
    assert_template("admin/racers/_merge_confirm")
    assert_not_nil(assigns["racer"], "Should assign racer")
    assert_equal(tonkin, assigns['racer'], 'Racer')
    assert_equal([racers(:molly)], assigns['existing_racers'], 'existing_racers')
    assert(!Alias.find_all_racers_by_name('Mollie Cameron').empty?, 'Mollie still in database')
    assert(!Racer.find_all_by_name('Molly Cameron').empty?, 'Molly still in database')
    assert(!Racer.find_all_by_name('Erik Tonkin').empty?, 'Erik Tonkin still in database')
  end
  
  def test_update_to_other_racer_existing_alias_and_duplicate_names
    tonkin = racers(:tonkin)
    molly_with_different_road_number = Racer.create!(:name => 'Molly Cameron', :road_number => '1009')

    assert_equal(0, Racer.count(:conditions => ['first_name = ? and last_name = ?', 'Mollie', 'Cameron']), 'Mollies in database')
    assert_equal(2, Racer.count(:conditions => ['first_name = ? and last_name = ?', 'Molly', 'Cameron']), 'Mollys in database')
    assert_equal(1, Racer.count(:conditions => ['first_name = ? and last_name = ?', 'Erik', 'Tonkin']), 'Eriks in database')
    assert_equal(1, Alias.count(:conditions => ['name = ?', 'Mollie Cameron']), 'Mollie aliases in database')

    post(:update_name, :id => tonkin.to_param, :name => 'Mollie Cameron')
    assert_response(:success)
    assert_template("admin/racers/_merge_confirm")
    assert_not_nil(assigns["racer"], "Should assign racer")
    assert_equal(tonkin, assigns['racer'], 'Racer')
    assert_equal(1, assigns['existing_racers'].size, "existing_racers: #{assigns['existing_racers']}")

    assert_equal(0, Racer.count(:conditions => ['first_name = ? and last_name = ?', 'Mollie', 'Cameron']), 'Mollies in database')
    assert_equal(2, Racer.count(:conditions => ['first_name = ? and last_name = ?', 'Molly', 'Cameron']), 'Mollys in database')
    assert_equal(1, Racer.count(:conditions => ['first_name = ? and last_name = ?', 'Erik', 'Tonkin']), 'Eriks in database')
    assert_equal(1, Alias.count(:conditions => ['name = ?', 'Mollie Cameron']), 'Mollie aliases in database')
  end
  
  def test_destroy
    racer = racers(:no_results)
    delete :destroy, :id => racer.id
    assert_response(:redirect)
    assert_redirected_to(admin_racers_path)
    assert(!Racer.exists?(racer.id), 'Racer should have been destroyed')
  end
  
  def test_ajax_destroy
    racer = racers(:no_results)
    delete :destroy, :id => racer.id, :format => 'js'
    assert_response(:success)
    assert_raise(ActiveRecord::RecordNotFound, 'Racer should have been destroyed') { Racer.find(racer.id) }
  end
  
  def test_destroy_number
    race_number = race_numbers(:molly_road_number)
    assert_not_nil(RaceNumber.find(race_number.id), 'RaceNumber should exist')
    
    opts = {:controller => "admin/racers", :action => "destroy_number", :id => race_number.to_param}
    assert_routing("/admin/racers/destroy_number/#{race_number.to_param}", opts)

    post(:destroy_number, :id => race_number.to_param)
    assert_response(:success)
    
    assert_raise(ActiveRecord::RecordNotFound, "Should delete RaceNumber") {RaceNumber.find(race_number.id)}
  end
  
  def test_destroy_alias
    tonkin = racers(:tonkin)
    assert_equal(1, tonkin.aliases.count, 'Tonkin aliases')
    eric_tonkin_alias = tonkin.aliases.first

    opts = {:controller => "admin/racers", :action => "destroy_alias", :id => tonkin.id.to_s, :alias_id => eric_tonkin_alias.id.to_s}
    assert_routing("/admin/racers/#{tonkin.id}/aliases/#{eric_tonkin_alias.id}/destroy", opts)
    
    post(:destroy_alias, :id => tonkin.id.to_s, :alias_id => eric_tonkin_alias.id.to_s)
    assert_response(:success)
    assert_equal(0, tonkin.aliases(true).count, 'Tonkin aliases after destruction')
  end
  
  def test_merge?
    molly = racers(:molly)
    tonkin = racers(:tonkin)
    get(:update_name, :name => molly.name, :id => tonkin.to_param)
    assert_response(:success)
    assert_equal(tonkin, assigns['racer'], 'Racer')
    racer = assigns['racer']
    assert(racer.errors.empty?, "Racer should have no errors, but had: #{racer.errors.full_messages}")
    assert_template("admin/racers/_merge_confirm")
    assert_equal(molly.name, assigns['racer'].name, 'Unsaved Tonkin name should be Molly')
    assert_equal([molly], assigns['existing_racers'], 'existing_racers')
  end
  
  def test_merge
    molly = racers(:molly)
    tonkin = racers(:tonkin)
    old_id = tonkin.id
    assert(Racer.find_all_by_name('Erik Tonkin'), 'Tonkin should be in database')

    get(:merge, :id => tonkin.to_param, :target_id => molly.id)
    assert_response(:success)
    assert_template("admin/racers/merge")

    assert(Racer.find_all_by_name('Molly Cameron'), 'Molly should be in database')
    assert_equal([], Racer.find_all_by_name('Erik Tonkin'), 'Tonkin should not be in database')
  end

  def test_edit_team_name
    weaver = racers(:weaver)
    get(:edit_team_name, :id => weaver.to_param)
    assert_response(:success)
    assert_template("admin/racers/_edit_team_name")
    assert_not_nil(assigns["racer"], "Should assign racer")
    assert_equal(weaver, assigns['racer'], 'Should assign racer')
  end
  
  def test_update_team_name_to_new_team
    assert_nil(Team.find_by_name('Velo Slop'), 'New team Velo Slop should not be in database')
    molly = racers(:molly)
    post(:update_team_name, :id => molly.to_param, :team_name => 'Velo Slop')
    assert_response(:success)
    assert_template("admin/racers/_team")
    assert_not_nil(assigns["racer"], "Should assign racer")
    assert_equal(molly, assigns['racer'], 'Racer')
    molly.reload
    assert_equal('Velo Slop', molly.team_name, 'Racer team name after update')
    assert_not_nil(Team.find_by_name('Velo Slop'), 'New team Velo Slop should be in database')
  end
  
  def test_update_team_name_to_existing_team
    molly = racers(:molly)
    assert_equal(Team.find_by_name('Vanilla'), molly.team, 'Molly should be on Vanilla')
    post(:update_team_name, :id => molly.to_param, :team_name => 'Gentle Lovers')
    assert_response(:success)
    assert_template("admin/racers/_team")
    assert_not_nil(assigns["racer"], "Should assign racer")
    assert_equal(molly, assigns['racer'], 'Racer')
    molly.reload
    assert_equal('Gentle Lovers', molly.team_name, 'Racer team name after update')
    assert_equal(Team.find_by_name('Gentle Lovers'), molly.team, 'Molly should be on Gentle Lovers')
  end

  def test_update_team_name_to_blank
    molly = racers(:molly)
    assert_equal(Team.find_by_name('Vanilla'), molly.team, 'Molly should be on Vanilla')
    post(:update_team_name, :id => molly.to_param, :team_name => '')
    assert_response(:success)
    assert_template("admin/racers/_team")
    assert_not_nil(assigns["racer"], "Should assign racer")
    assert_equal(molly, assigns['racer'], 'Racer')
    molly.reload
    assert_equal('', molly.team_name, 'Racer team name after update')
    assert_nil(molly.team, 'Molly should have no team')
  end
    
  def test_cancel_edit_team_name
    molly = racers(:molly)
    original_name = molly.name
    get(:cancel_edit_team_name, :id => molly.to_param, :name => molly.name)
    assert_response(:success)
    assert_template("admin/racers/_team")
    assert_not_nil(assigns["racer"], "Should assign racer")
    assert_equal(molly, assigns['racer'], 'Racer')
    molly.reload
    assert_equal(original_name, molly.name, 'Racer name after cancel')
  end

  def test_update_member
    molly = racers(:molly)
    assert_equal(true, molly.member, 'member before update')
    post(:toggle_attribute, :id => molly.to_param, :attribute => 'member')
    assert_response(:success)
    assert_template("admin/_attribute")
    molly.reload
    assert_equal(false, molly.member, 'member after update')

    molly = racers(:molly)
    post(:toggle_attribute, :id => molly.to_param, :attribute => 'member')
    assert_response(:success)
    assert_template("admin/_attribute")
    molly.reload
    assert_equal(true, molly.member, 'member after second update')
  end
  
  def test_dupes_merge?
    molly = racers(:molly)
    molly_with_different_road_number = Racer.create(:name => 'Molly Cameron', :road_number => '987123')
    tonkin = racers(:tonkin)
    get(:update_name, :name => molly.name, :id => tonkin.to_param)
    assert_response(:success)
    assert_equal(tonkin, assigns['racer'], 'Racer')
    racer = assigns['racer']
    assert(racer.errors.empty?, "Racer should have no errors, but had: #{racer.errors.full_messages}")
    assert_template("admin/racers/_merge_confirm")
    assert_equal(molly.name, assigns['racer'].name, 'Unsaved Tonkin name should be Molly')
    existing_racers = assigns['existing_racers'].sort {|x, y| x.id <=> y.id}
    assert_equal([molly, molly_with_different_road_number], existing_racers, 'existing_racers')
  end
  
  def test_dupes_merge_one_has_road_number_one_has_cross_number?
    molly = racers(:molly)
    molly.ccx_number = '102'
    molly.save!
    molly_with_different_cross_number = Racer.create(:name => 'Molly Cameron', :ccx_number => '810', :road_number => '1009')
    tonkin = racers(:tonkin)
    get(:update_name, :name => molly.name, :id => tonkin.to_param)
    assert_response(:success)
    assert_equal(tonkin, assigns['racer'], 'Racer')
    racer = assigns['racer']
    assert(racer.errors.empty?, "Racer should have no errors, but had: #{racer.errors.full_messages}")
    assert_template("admin/racers/_merge_confirm")
    assert_equal(molly.name, assigns['racer'].name, 'Unsaved Tonkin name should be Molly')
    existing_racers = assigns['existing_racers'].collect do |racer|
      "#{racer.name} ##{racer.id}"
    end
    existing_racers = existing_racers.join(', ')
    assert(assigns['existing_racers'].include?(molly), "existing_racers should include Molly ##{molly.id}, but has #{existing_racers}")
    assert(assigns['existing_racers'].include?(molly_with_different_cross_number), 'existing_racers')
    assert_equal(2, assigns['existing_racers'].size, 'existing_racers')
  end
  
  def test_dupes_merge_alias?
    molly = racers(:molly)
    tonkin = racers(:tonkin)
    get(:update_name, :name => 'Eric Tonkin', :id => molly.to_param)
    assert_response(:success)
    assert_equal(molly, assigns['racer'], 'Racer')
    racer = assigns['racer']
    assert(racer.errors.empty?, "Racer should have no errors, but had: #{racer.errors.full_messages}")
    assert_template("admin/racers/_merge_confirm")
    assert_equal('Eric Tonkin', assigns['racer'].name, 'Unsaved Molly name should be Eric Tonkin alias')
    assert_equal([tonkin], assigns['existing_racers'], 'existing_racers')
  end
  
  def test_dupe_merge
    molly = racers(:molly)
    tonkin = racers(:tonkin)
    tonkin_with_different_road_number = Racer.create(:name => 'Erik Tonkin', :road_number => 'YYZ')
    assert(tonkin_with_different_road_number.valid?, "tonkin_with_different_road_number not valid: #{tonkin_with_different_road_number.errors.full_messages}")
    assert_equal(tonkin_with_different_road_number.new_record?, false, 'tonkin_with_different_road_number should be saved')
    old_id = tonkin.id
    assert_equal(2, Racer.find_all_by_name('Erik Tonkin').size, 'Tonkins in database')

    get(:merge, :id => tonkin.to_param, :target_id => molly.id)
    assert_response(:success)
    assert_template("admin/racers/merge")

    assert(Racer.find_all_by_name('Molly Cameron'), 'Molly should be in database')
    tonkins_after_merge = Racer.find_all_by_name('Erik Tonkin')
    assert_equal(1, tonkins_after_merge.size, tonkins_after_merge)
  end
  
  def test_new
    opts = {:controller => "admin/racers", :action => "new"}
    assert_routing("/admin/racers/new", opts)
  
    get(:new)
    assert_response(:success)
    assert_template("admin/racers/show")
    assert_not_nil(assigns["racer"], "Should assign racer as 'racer'")
    assert_not_nil(assigns["race_numbers"], "Should assign racer's number for current year as 'race_numbers'")
  end

  def test_show
    alice = racers(:alice)
    opts = {:controller => "admin/racers", :action => "show", :id => alice.to_param.to_s}
    assert_routing("/admin/racers/#{alice.to_param}", opts)
    
    get(:show, :id => alice.to_param)
    assert_response(:success)
    assert_template("admin/racers/show")
    assert_not_nil(assigns["racer"], "Should assign racer")
    assert_equal(alice, assigns['racer'], 'Should assign Alice to racer')
  end
  
  def test_create
    assert_equal([], Racer.find_all_by_name('Jon Knowlson'), 'Knowlson should not be in database')
    
    post(:create, {"racer"=>{
                        "member_from(1i)"=>"", "member_from(2i)"=>"", "member_from(3i)"=>"", 
                        "member_to(1i)"=>"", "member_to(2i)"=>"", "member_to(3i)"=>"", 
                        "work_phone"=>"", "date_of_birth(2i)"=>"", "occupation"=>"", "city"=>"Brussels", "cell_fax"=>"", "zip"=>"", 
                        "date_of_birth(3i)"=>"", "mtb_category"=>"", "dh_category"=>"", "member"=>"1", "gender"=>"", "ccx_category"=>"", 
                        "team_name"=>"", "road_category"=>"", "xc_number"=>"", "street"=>"", "track_category"=>"", "home_phone"=>"", 
                        "dh_number"=>"", "road_number"=>"", "first_name"=>"Jon", "ccx_number"=>"", "last_name"=>"Knowlson", 
                        "date_of_birth(1i)"=>"", "email"=>"", "state"=>""}, "commit"=>"Save"})
    
    if assigns['racer']
      assert(assigns['racer'].errors.empty?, assigns['racer'].errors.full_messages)
    end
    
    assert(flash.empty?, "Flash should be empty, but was: #{flash}")
    assert_response(:redirect)
    knowlsons = Racer.find_all_by_name('Jon Knowlson')
    assert(!knowlsons.empty?, 'Knowlson should be created')
    assert_redirected_to(:id => knowlsons.first.id)
    assert_nil(knowlsons.first.member_from, 'member_from after update')
    assert_nil(knowlsons.first.member_to, 'member_to after update')
  end

  def test_create_with_road_number
    assert_equal([], Racer.find_all_by_name('Jon Knowlson'), 'Knowlson should not be in database')
    
    post(:create, {
      "racer"=>{"work_phone"=>"", "date_of_birth(2i)"=>"", "occupation"=>"", "city"=>"Brussels", "cell_fax"=>"", "zip"=>"", 
        "member_from(1i)"=>"2004", "member_from(2i)"=>"2", "member_from(3i)"=>"16", 
        "member_to(1i)"=>"2004", "member_to(2i)"=>"12", "member_to(3i)"=>"31", 
        "date_of_birth(3i)"=>"", "mtb_category"=>"", "dh_category"=>"", "member"=>"1", "gender"=>"", "ccx_category"=>"", 
        "team_name"=>"", "road_category"=>"", "xc_number"=>"", "street"=>"", "track_category"=>"", "home_phone"=>"", "dh_number"=>"", 
        "road_number"=>"", "first_name"=>"Jon", "ccx_number"=>"", "last_name"=>"Knowlson", "date_of_birth(1i)"=>"", "email"=>"", "state"=>""}, 
        "number_issuer_id"=>[number_issuers(:association).to_param, number_issuers(:association).to_param], "number_value"=>["8977", "BBB9"],
        "discipline_id"=>[disciplines(:road).id, disciplines(:mountain_bike).id], :number_year => '2007',
      "commit"=>"Save"})
    
    if assigns['racer']
      assert(assigns['racer'].errors.empty?, assigns['racer'].errors.full_messages)
    end
    
    assert(flash.empty?, "flash empty? #{flash}")
    knowlsons = Racer.find_all_by_name('Jon Knowlson')
    assert(!knowlsons.empty?, 'Knowlson should be created')
    assert_response(:redirect)
    assert_redirected_to(:id => knowlsons.first.id)
    race_numbers = knowlsons.first.race_numbers
    assert_equal(2, race_numbers.size, 'Knowlson race numbers')
    
    race_number = RaceNumber.find(:first, :conditions => ['discipline_id=? and year=? and racer_id=?', Discipline[:road].id, 2007, knowlsons.first.id])
    assert_not_nil(race_number, 'Road number')
    assert_equal(2007, race_number.year, 'Road number year')
    assert_equal('8977', race_number.value, 'Road number value')
    assert_equal(Discipline[:road], race_number.discipline, 'Road number discipline')
    assert_equal(number_issuers(:association), race_number.number_issuer, 'Road number issuer')
    
    race_number = RaceNumber.find(:first, :conditions => ['discipline_id=? and year=? and racer_id=?', Discipline[:mountain_bike].id, 2007, knowlsons.first.id])
    assert_not_nil(race_number, 'MTB number')
    assert_equal(2007, race_number.year, 'MTB number year')
    assert_equal('BBB9', race_number.value, 'MTB number value')
    assert_equal(Discipline[:mountain_bike], race_number.discipline, 'MTB number discipline')
    assert_equal(number_issuers(:association), race_number.number_issuer, 'MTB number issuer')

    assert_equal_dates('2004-02-16', knowlsons.first.member_from, 'member_from after update')
    assert_equal_dates('2004-12-31', knowlsons.first.member_to, 'member_to after update')
  end
  
  def test_create_with_duplicate_road_number
    assert_equal([], Racer.find_all_by_name('Jon Knowlson'), 'Knowlson should not be in database')
    
    post(:create, {
      "racer"=>{"work_phone"=>"", "date_of_birth(2i)"=>"", "occupation"=>"", "city"=>"Brussels", "cell_fax"=>"", "zip"=>"", 
        "member_from(1i)"=>"2004", "member_from(2i)"=>"2", "member_from(3i)"=>"16", 
        "member_to(1i)"=>"2004", "member_to(2i)"=>"12", "member_to(3i)"=>"31", 
        "date_of_birth(3i)"=>"", "mtb_category"=>"", "dh_category"=>"", "member"=>"1", "gender"=>"", "ccx_category"=>"", 
        "team_name"=>"", "road_category"=>"", "xc_number"=>"", "street"=>"", "track_category"=>"", "home_phone"=>"", "dh_number"=>"", 
        "road_number"=>"", "first_name"=>"Jon", "ccx_number"=>"", "last_name"=>"Knowlson", "date_of_birth(1i)"=>"", "email"=>"", "state"=>""}, 
      "number_issuer_id"=>["2", "2"], "number_value"=>["104", "BBB9"], "discipline_id"=>["4", "3"], :number_year => '2004',
      "commit"=>"Save"})
    
    assert_response(:success)
    assert_not_nil(assigns['racer'], "Should assign racer")
    assert(!assigns['racer'].errors.empty?, "Racer should have errors")
    
    knowlson = Racer.find(:first, :conditions => { :first_name => "Jon", :last_name => "Knowlson" })
    assert_not_nil(knowlson, 'Knowlson should not have be created')
    race_numbers = knowlson.race_numbers
    assert_equal(1, race_numbers.size, 'Knowlson race numbers')
  end
    
  def test_update
    molly = racers(:molly)
    put(:update, {"commit"=>"Save", 
                   "number_year" => Date.today.year.to_s,
                   "number_issuer_id"=>number_issuers(:association).to_param, "number_value"=>[""], "discipline_id"=>disciplines(:cyclocross).to_param,
                   "number"=>{race_numbers(:molly_road_number).to_param=>{"value"=>"222"}},
                   "racer"=>{
                     "member_from(1i)"=>"2004", "member_from(2i)"=>"2", "member_from(3i)"=>"16", 
                     "member_to(1i)"=>"2004", "member_to(2i)"=>"12", "member_to(3i)"=>"31", 
                     "print_card" => "1", "work_phone"=>"", "date_of_birth(2i)"=>"1", "occupation"=>"engineer", "city"=>"Wilsonville", 
                     "cell_fax"=>"", "zip"=>"97070", "date_of_birth(3i)"=>"1", "mtb_category"=>"Spt", "dh_category"=>"", 
                     "member"=>"1", "gender"=>"M", "notes"=>"rm", "ccx_category"=>"", "team_name"=>"", "road_category"=>"5", 
                     "xc_number"=>"1061", "street"=>"31153 SW Willamette Hwy W", "track_category"=>"", "home_phone"=>"503-582-8823", 
                     "dh_number"=>"917", "road_number"=>"2051", "first_name"=>"Paul", "ccx_number"=>"112", "last_name"=>"Formiller", 
                     "date_of_birth(1i)"=>"1969", "email"=>"paul.formiller@verizon.net", "state"=>"OR", "ccx_only" => "1"
                    }, 
                   "id"=>molly.to_param}
    )
    assert(flash.empty?, "Expected flash.empty? but was: #{flash[:warn]}")
    assert_response(:redirect)
    molly.reload
    assert_equal('222', molly.road_number(true), 'Road number should be updated')
    assert_equal(true, molly.print_card?, 'print_card?')
    assert_equal_dates('2004-02-16', molly.member_from, 'member_from after update')
    assert_equal_dates('2004-12-31', molly.member_to, 'member_to after update')
    assert_equal(true, molly.ccx_only?, 'ccx_only?')
  end
  
  def test_update_bad_member_from_date
    racer = racers(:weaver)
    put(:update, "commit"=>"Save", "racer"=>{
                 "member_from(1i)"=>"","member_from(2i)"=>"10", "member_from(3i)"=>"19",  
                 "member_to(3i)"=>"31", "date_of_birth(2i)"=>"1", "city"=>"Hood River", 
                 "work_phone"=>"541-387-8883 x 213", "occupation"=>"Sales Territory Manager", "cell_fax"=>"541-387-8884",
                 "date_of_birth(3i)"=>"1", "zip"=>"97031", "license"=>"583", "mtb_category"=>"Beg", "print_mailing_label"=>"1", 
                 "dh_category"=>"Beg", "notes"=>"interests: 6\r\nr\r\ninterests: 4\r\nr\r\ninterests: 4\r\n", "gender"=>"M", 
                 "ccx_category"=>"B", "team_name"=>"River City Specialized", "print_card"=>"1", 
                 "street"=>"3541 Avalon Drive", "home_phone"=>"503-367-5193", "road_category"=>"3", 
                 "track_category"=>"5", "first_name"=>"Karsten", "last_name"=>"Hagen", 
                 "member_to(1i)"=>"2008", "member_to(2i)"=>"12", "email"=>"khagen69@hotmail.com", "date_of_birth(1i)"=>"1969",  
                 "state"=>"OR"}, "number"=>{"30532"=>{"value"=>"1453"}, "30533"=>{"value"=>"373"}}, "id"=>racer.to_param, 
                 "number_year"=>"2008"
    )
    assert_not_nil(assigns(:racer), "@racer")
    assert(!assigns(:racer).errors.empty?, "Should have errors")
    assert(assigns(:racer).errors.on(:member_from), "Should have errors on 'member_from'")
    assert(flash.empty?, "Expected flash.empty?")
    assert_response :success
  end

  def test_update_new_number
    molly = racers(:molly)
    put(:update, {"commit"=>"Save", 
                   "number_year" => Date.today.year.to_s,
                   "number_issuer_id"=>[number_issuers(:association).to_param], "number_value"=>["AZY"], "discipline_id" => [disciplines(:mountain_bike).id],
                   "number"=>{race_numbers(:molly_road_number).to_param =>{"value"=>"202"}},
                   "racer"=>{"work_phone"=>"", "date_of_birth(2i)"=>"1", "occupation"=>"engineer", "city"=>"Wilsonville", 
                   "cell_fax"=>"", "zip"=>"97070", 
                   "date_of_birth(3i)"=>"1", "mtb_category"=>"Spt", "dh_category"=>"",
                   "member"=>"1", "gender"=>"M", "notes"=>"rm", "ccx_category"=>"", "team_name"=>"", "road_category"=>"5", 
                   "street"=>"31153 SW Willamette Hwy W", 
                   "track_category"=>"", "home_phone"=>"503-582-8823", "first_name"=>"Paul", "last_name"=>"Formiller", 
                   "date_of_birth(1i)"=>"1969", 
                   "member_from(1i)"=>"", "member_from(2i)"=>"", "member_from(3i)"=>"", 
                   "member_to(1i)"=>"", "member_to(2i)"=>"", "member_to(3i)"=>"", 
                   "email"=>"paul.formiller@verizon.net", "state"=>"OR"}, 
                   "id"=>molly.to_param}
    )
    assert_response(:redirect)
    assert(flash.empty?, 'flash empty?')
    molly.reload
    assert_equal('202', molly.road_number, 'Road number should not be updated')
    assert_equal('AZY', molly.xc_number, 'MTB number should be updated')
    assert_nil(molly.member_from, 'member_from after update')
    assert_nil(molly.member_to, 'member_to after update')
    assert_nil(RaceNumber.find(race_numbers(:molly_road_number).to_param ).updated_by, "updated_by")
    assert_equal("Candi Murray", RaceNumber.find_by_value("AZY").updated_by, "updated_by")
  end

  def test_update_error
    molly = racers(:molly)
    put(:update, 
    :id => molly.to_param, 
      :racer => {
        :first_name => 'Molly', :last_name => 'Cameron', :road_number => '123123612333', "member_to(1i)" => "AZZZ", :team_id => "-9"
    })
    assert_response(:success)
    assert_template("admin/racers/show")
    assert_not_nil(assigns["racer"], "Should assign racer")
    assert_equal(molly, assigns['racer'], 'Should assign Alice to racer')
    assert(!flash.empty?, 'flash not empty?')
  end
  
  def test_number_year_changed
    racer = racers(:molly)
    
    opts = {:controller => "admin/racers", :action => "number_year_changed", :id => racer.to_param.to_s}
    assert_routing("/admin/racers/number_year_changed/#{racer.to_param}", opts)

    post(:number_year_changed, 
         :id => racer.to_param.to_s,
         :year => '2010'
    )
    assert_response(:success)
    assert_template("admin/racers/_numbers")
    assert_not_nil(assigns["race_numbers"], "Should assign 'race_numbers'")
    assert_not_nil(assigns["year"], "Should assign today's year as 'year'")
    assert_equal('2010', assigns["year"], "Should assign selected year as 'year'")
    assert_not_nil(assigns["years"], "Should assign range of years as 'years'")
    assert(assigns["years"].size >= 2, "Should assign range of years as 'years', but was: #{assigns[:years]}")
  end
  
  def test_preview_import
    assert_recognizes({:controller => "admin/racers", :action => "preview_import"}, {:path => "/admin/racers/preview_import", :method => :post})

    racers_before_import = Racer.count

    file = uploaded_file("test/fixtures/membership/55612_061202_151958.csv, attachment filename=55612_061202_151958.csv", "55612_061202_151958.csv, attachment filename=55612_061202_151958.csv", "text/csv")
    post :preview_import, :racers_file => file

    assert(!flash.has_key?(:warn), "flash[:warn] should be empty,  but was: #{flash[:warn]}")
    assert_response :success
    assert_template("admin/racers/preview_import")
    assert_not_nil(assigns["racers_file"], "Should assign 'racers_file'")
    assert(session[:racers_file_path].include?('55612_061202_151958.csv, attachment filename=55612_061202_151958.csv'), 
      'Should store temp file path in session as :racers_file_path')
    
    assert_equal(racers_before_import, Racer.count, 'Should not have added racers')
  end
  
  def test_preview_import_with_no_file
    post(:preview_import, :commit => 'Import', :racers_file => "")
  
    assert(flash.has_key?(:warn), "should have flash[:warn]")
    assert_response(:redirect)
    assert_redirected_to(:action => 'index')
  end
  
  def test_import
    existing_duplicate = Duplicate.new(:new_attributes => Racer.new(:name => 'Erik Tonkin'))
    existing_duplicate.racers << racers(:tonkin)
    existing_duplicate.save!
    assert_recognizes({:controller => "admin/racers", :action => "import"}, {:path => "/admin/racers/import", :method => :post})
    racers_before_import = Racer.count
  
    file = uploaded_file("test/fixtures/membership/55612_061202_151958.csv, attachment filename=55612_061202_151958.csv", "55612_061202_151958.csv, attachment filename=55612_061202_151958.csv", "text/csv")
    @request.session[:racers_file_path] = File.expand_path("#{RAILS_ROOT}/test/fixtures/membership/55612_061202_151958.csv, attachment filename=55612_061202_151958.csv")
    post(:import, :commit => 'Import', :update_membership => 'true')
  
    assert(!flash.has_key?(:warn), "flash[:warn] should be empty, but was: #{flash[:warn]}")
    assert(flash.has_key?(:notice), "flash[:notice] should not be empty")
    assert_nil(session[:duplicates], 'session[:duplicates]')
    assert_response(:redirect)
    assert_redirected_to(:action => 'index')
    
    assert_nil(session[:racers_file_path], 'Should remove temp file path from session')
    assert(racers_before_import < Racer.count, 'Should have added racers')
    assert_equal(0, Duplicate.count, 'Should have no duplicates')
  end
  
  def test_import_next_year
    existing_duplicate = Duplicate.new(:new_attributes => Racer.new(:name => 'Erik Tonkin'))
    existing_duplicate.racers << racers(:tonkin)
    existing_duplicate.save!
    assert_recognizes({:controller => "admin/racers", :action => "import"}, {:path => "/admin/racers/import", :method => :post})
    racers_before_import = Racer.count
  
    file = uploaded_file("test/fixtures/membership/database.xls", "duplicates.xls", "application/vnd.ms-excel")
    @request.session[:racers_file_path] = File.expand_path("#{RAILS_ROOT}/test/fixtures/membership/database.xls")
    next_year = Date.today.year + 1
    post(:import, :commit => 'Import', :update_membership => 'true', :year => next_year)
  
    assert(!flash.has_key?(:warn), "flash[:warn] should be empty, but was: #{flash[:warn]}")
    assert(flash.has_key?(:notice), "flash[:notice] should not be empty")
    assert_nil(session[:duplicates], 'session[:duplicates]')
    assert_response(:redirect)
    assert_redirected_to(:action => 'index')
    
    assert_nil(session[:racers_file_path], 'Should remove temp file path from session')
    assert(racers_before_import < Racer.count, 'Should have added racers')
    assert_equal(0, Duplicate.count, 'Should have no duplicates')
    
    rene = Racer.find_by_name('Rene Babi')
    assert_not_nil(rene, 'Rene Babi should have been imported and created')
    road_number = rene.race_numbers.detect {|n| n.year == next_year && n.discipline == Discipline['road']}
    assert_not_nil(road_number, "Rene should have road number for #{next_year}")

    assert(rene.member?(Date.today), 'Should be a member for this year')
    assert(rene.member?(Date.new(next_year - 1, 12, 31)), 'Should be a member for this year')
    assert(rene.member?(Date.new(next_year, 1, 1)), 'Should be a member for next year')

    heidi = Racer.find_by_name('Heidi Babi')
    assert_not_nil(heidi, 'Heidi Babi should have been imported and created')
    assert(heidi.member?(Date.today), 'Should be a member for this year')
    assert(heidi.member?(Date.new(next_year - 1, 12, 31)), 'Should be a member for this year')
    assert(heidi.member?(Date.new(next_year, 1, 1)), 'Should be a member for next year')
  end
  
  def test_import_with_duplicates
    Racer.create(:name => 'Erik Tonkin')
    racers_before_import = Racer.count
  
    file = uploaded_file("test/fixtures/membership/duplicates.xls", "duplicates.xls", "application/vnd.ms-excel")
    @request.session[:racers_file_path] = File.expand_path("#{RAILS_ROOT}/test/fixtures/membership/duplicates.xls")
    post(:import, :commit => 'Import', :update_membership => 'true')
  
    assert(flash.has_key?(:warn), "flash[:warn] should not be empty")
    assert(flash.has_key?(:notice), "flash[:notice] should not be empty")
    assert_equal(1, Duplicate.count, 'Should have duplicates')
    assert_response(:redirect)
    assert_redirected_to(:action => 'duplicates')
    
    assert_nil(session[:racers_file_path], 'Should remove temp file path from session')
    assert(racers_before_import < Racer.count, 'Should have added racers')
  end
  
  def test_import_with_no_file
    post(:import, :commit => 'Import', :update_membership => 'true')
  
    assert(flash.has_key?(:warn), "should have flash[:warn]")
    assert_response(:redirect)
    assert_redirected_to(:action => 'index')
  end
  
  def test_duplicates
    @request.session[:duplicates] = []
    get(:duplicates)
    assert_response(:success)
    assert_template("admin/racers/duplicates")
  end
  
  def test_resolve_duplicates
    Racer.create!(:name => 'Erik Tonkin')
    weaver_2 = Racer.create!(:name => 'Ryan Weaver', :city => 'Kenton')
    weaver_3 = Racer.create!(:name => 'Ryan Weaver', :city => 'Lake Oswego')
    alice_2 = Racer.create!(:name => 'Alice Pennington', :road_category => '3')
    racers_before_import = Racer.count
  
    tonkin_dupe = Duplicate.create!(:new_attributes => {:name => 'Erik Tonkin'}, :racers => Racer.find(:all, :conditions => ['last_name = ?', 'Tonkin']))
    ryan_dupe = Duplicate.create!(:new_attributes => {:name => 'Ryan Weaver', :city => 'Las Vegas'}, :racers => Racer.find(:all, :conditions => ['last_name = ?', 'Weaver']))
    alice_dupe = Duplicate.create!(:new_attributes => {:name => 'Alice Pennington', :road_category => '2'}, :racers => Racer.find(:all, :conditions => ['last_name = ?', 'Pennington']))
    post(:resolve_duplicates, {tonkin_dupe.to_param => 'new', ryan_dupe.to_param => weaver_3.to_param, alice_dupe.to_param => alice_2.to_param})
    assert_response(:redirect)
    assert_redirected_to(:action => 'index')
    assert_equal(0, Duplicate.count, 'Should have no duplicates')
    
    assert_equal(3, Racer.find(:all, :conditions => ['last_name = ?', 'Tonkin']).size, 'Tonkins in database')
    assert_equal(3, Racer.find(:all, :conditions => ['last_name = ?', 'Weaver']).size, 'Weaver in database')
    assert_equal(2, Racer.find(:all, :conditions => ['last_name = ?', 'Pennington']).size, 'Pennington in database')
    
    weaver_3.reload
    assert_equal('Las Vegas', weaver_3.city, 'Weaver city')
    
    alice_2.reload
    assert_equal('2', alice_2.road_category, 'Alice category')
  end
  
  def test_cancel_import
    post(:import, :commit => 'Cancel', :update_membership => 'false')
    assert_response(:redirect)
    assert_redirected_to(:action => 'index')
    assert_nil(session[:racers_file_path], 'Should remove temp file path from session')
  end
  
  def test_one_print_card
    tonkin = racers(:tonkin)

    get(:card, :format => "pdf", :id => tonkin.to_param)

    assert_response(:success)
    assert_equal(tonkin, assigns['racer'], 'Should assign racer')
    tonkin.reload
    assert(!tonkin.print_card?, 'Tonkin.print_card? after printing')
  end
  
  def test_print_no_cards_pending
    get(:cards, :format => "pdf")
    assert_redirected_to(formatted_no_cards_admin_racers_path("html"))
  end
  
  def test_no_cards
    get(:no_cards)
    assert_response(:success)
    assert_template("admin/racers/no_cards")
    assert_equal('layouts/admin/application', @controller.active_layout)
  end
  
  def test_print_cards
    tonkin = racers(:tonkin)
    tonkin.print_card = true
    tonkin.save!

    get(:cards, :format => "pdf")

    assert_response(:success)
    assert_template("admin/racers/cards")
    # TODO How to test layout?
    assert_equal(1, assigns['racers'].size, 'Should assign racers')
    tonkin.reload
    assert(!tonkin.print_card?, 'Tonkin.print_card? after printing')
  end
  
  def test_many_print_cards
    racers = []
    for i in 1..4
      racers << Racer.create!(:first_name => 'First Name', :last_name => "Last #{i}", :print_card => true)
    end

    get(:cards, :format => "pdf")

    assert_response(:success)
    assert_template("admin/racers/cards")
    # TODO How to test layout?
    assert_equal(4, assigns['racers'].size, 'Should assign racers')
    for racer in racers
      racer.reload
      assert(!racer.print_card?, 'Racer.print_card? after printing')
    end
  end
  
  def test_print_no_mailing_labels_pending
    get(:mailing_labels, :format => "pdf")
    assert_redirected_to(formatted_no_mailing_labels_admin_racers_path("html"))
  end
  
  def test_print_no_mailing_labels
    get(:no_mailing_labels)
    assert_response(:success)
    assert_template("admin/racers/no_mailing_labels")
    assert_equal('layouts/admin/application', @controller.active_layout)
  end
  
  def test_print_mailing_labels
    tonkin = racers(:tonkin)
    tonkin.print_mailing_label = true
    tonkin.save!

    get(:mailing_labels, :format => "pdf")

    assert_response(:success)
    assert_template("admin/racers/mailing_labels")
    # How to test layout?
    assert_equal(1, assigns['racers'].size, 'Should assign racers')
    tonkin.reload
    assert(!tonkin.print_mailing_label?, 'Tonkin.mailing_label? after printing')
  end

  def test_many_mailing_labels
    racers = []
    for i in 1..31
      racers << Racer.create(:first_name => 'First Name', :last_name => "Last #{i}", :print_mailing_label => true)
    end

    get(:mailing_labels, :format => "pdf")

    assert_response(:success)
    assert_template("admin/racers/mailing_labels")
    assert_equal(31, assigns['racers'].size, 'Should assign racers')
    for racer in racers
      racer.reload
      assert(!racer.print_mailing_label?, 'Racer.print_mailing_label? after printing')
    end
  end
  
  def test_export_to_excel
    tonkin = racers(:tonkin)
    tonkin.singlespeed_number = "409"
    tonkin.track_number = "765"
    tonkin.save!
    
    RaceNumber.create!(:racer => tonkin, :discipline => Discipline[:singlespeed], :value => "410")

    weaver = racers(:weaver)
    RaceNumber.create!(:racer => weaver, :discipline => Discipline[:road], :value => "888")
    RaceNumber.create!(:racer => weaver, :discipline => Discipline[:road], :value => "999")
    assert_equal(4, weaver.race_numbers(true).size, "Weaver numbers")
    
    get(:index, :format => 'xls', :include => 'all')

    assert_response(:success)
    today = Date.today
    assert_equal("filename=\"racers_#{today.year}_#{today.month}_#{today.day}.xls\"", @response.headers['Content-Disposition'], 'Should set disposition')
    assert_equal('application/vnd.ms-excel; charset=utf-8', @response.headers['type'], 'Should set content to Excel')
    assert_not_nil(@response.headers['Content-Length'], 'Should set content length')
    assert_equal(6, assigns['racers'].size, "Racers export size")
  end
  
  def test_export_members_only_to_excel
    get(:index, :format => 'xls', :include => 'members_only')

    assert_response(:success)
    today = Date.today
    assert_equal("filename=\"racers_#{today.year}_#{today.month}_#{today.day}.xls\"", @response.headers['Content-Disposition'], 'Should set disposition')
    assert_equal('application/vnd.ms-excel; charset=utf-8', @response.headers['type'], 'Should set content to Excel')
    assert_not_nil(@response.headers['Content-Length'], 'Should set content length')
  end
  
  def test_export_to_finish_lynx
    opts = {
      :controller => "admin/racers", 
      :action => "index",
      :format => 'ppl'
    }
    assert_routing("/admin/racers.ppl", opts)
    get(:index, :format => 'ppl', :include => 'all')

    assert_response(:success)
    today = Date.today
    assert_equal("filename=\"lynx.ppl\"", @response.headers['Content-Disposition'], 'Should set disposition')
    assert_equal('application/vnd.ms-excel; charset=utf-8', @response.headers['type'], 'Should set content to Excel')
    assert_not_nil(@response.headers['Content-Length'], 'Should set content length')
  end
  
  def test_export_members_only_to_finish_lynx
    get(:index, :format => 'ppl', :include => 'members_only')

    assert_response(:success)
    today = Date.today
    assert_equal("filename=\"lynx.ppl\"", @response.headers['Content-Disposition'], 'Should set disposition')
    assert_equal('application/vnd.ms-excel; charset=utf-8', @response.headers['type'], 'Should set content to Excel')
    assert_not_nil(@response.headers['Content-Length'], 'Should set content length')
  end
  
  def test_export_members_only_to_scoring_sheet
    get(:index, :format => 'xls', :include => 'members_only', :excel_layout => 'scoring_sheet')

    assert_response(:success)
    today = Date.today
    assert_equal("filename=\"scoring_sheet.xls\"", @response.headers['Content-Disposition'], 'Should set disposition')
    assert_equal('application/vnd.ms-excel; charset=utf-8', @response.headers['type'], 'Should set content to Excel')
    assert_not_nil(@response.headers['Content-Length'], 'Should set content length')
  end
end