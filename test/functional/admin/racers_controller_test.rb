require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/racers_controller'

# :stopdoc:
class Admin::RacersController; def rescue_action(e) raise e end; end

class Admin::RacersControllerTest < Test::Unit::TestCase

  def setup
    @controller = Admin::RacersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.host = "localhost"
    @request.session[:user] = users(:candi)
  end

  def test_not_logged_in_index
    @request.session[:user] = nil
    get(:index)
    assert_response(:redirect)
    assert_redirect_url "http://localhost/admin/account/login"
    assert_nil(@request.session["user"], "No user in session")
  end
  
  def test_not_logged_in_edit
    @request.session[:user] = nil
    weaver = racers(:weaver)
    get(:edit_name, :id => weaver.to_param)
    assert_response(:redirect)
    assert_redirect_url "http://localhost/admin/account/login"
    assert_nil(@request.session["user"], "No user in session")
  end

  def test_index
    opts = {:controller => "admin/racers", :action => "index"}
    assert_routing("/admin/racers", opts)
    
    get(:index)
    assert_response(:success)
    assert_template("admin/racers/index")
    assert_not_nil(assigns["racers"], "Should assign racers")
    assert(assigns["racers"].empty?, "Should have no racers")
    assert_not_nil(assigns["name"], "Should assign name")
  end

  def test_find
    @request.session[:user] = users(:candi)
    get(:index, :name => 'weav')
    assert_response(:success)
    assert_template("admin/racers/index")
    assert_not_nil(assigns["racers"], "Should assign racers")
    assert_equal([racers(:weaver)], assigns['racers'], 'Search for weav should find Weaver')
    assert_not_nil(assigns["name"], "Should assign name")
    assert_equal('weav', assigns['name'], "'name' assigns")
  end

  def test_find_nothing
    @request.session[:user] = users(:candi)
    get(:index, :name => 's7dfnacs89danfx')
    assert_response(:success)
    assert_template("admin/racers/index")
    assert_not_nil(assigns["racers"], "Should assign racers")
    assert_equal(0, assigns['racers'].size, "Should find no racers")
  end
  
  def test_find_empty_name
    @request.session[:user] = users(:candi)
    get(:index, :name => '')
    assert_response(:success)
    assert_template("admin/racers/index")
    assert_not_nil(assigns["racers"], "Should assign racers")
    assert_equal(0, assigns['racers'].size, "Search for '' should find all racers")
    assert_not_nil(assigns["name"], "Should assign name")
    assert_equal('', assigns['name'], "'name' assigns")
  end

  def test_find_limit
    for i in 0..Admin::RacersController::RESULTS_LIMIT
      Racer.create(:name => "Test Racer #{i}")
    end
    @request.session[:user] = users(:candi)
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
    @request.session[:user] = users(:candi)
    weaver = racers(:weaver)
    get(:edit_name, :id => weaver.to_param)
    assert_response(:success)
    assert_template("admin/racers/_edit")
    assert_not_nil(assigns["racer"], "Should assign racer")
    assert_equal(weaver, assigns['racer'], 'Should assign racer')
  end

  def test_blank_name
    @request.session[:user] = users(:candi)
    mollie = racers(:mollie)
    post(:update_name, :id => mollie.to_param, :name => '')
    assert_response(:success)
    racer = assigns["racer"]
    assert_not_nil(racer, "Should assign racer")
    assert(racer.errors.empty?, "Should have no errors, but had: #{racer.errors.full_messages}")
    assert_template("/admin/_attribute")
    assert_equal(mollie, assigns['racer'], 'Racer')
    mollie.reload
    assert_equal('', mollie.first_name, 'Racer first_name after update')
    assert_equal('', mollie.last_name, 'Racer last_name after update')
  end

  def test_cancel
    @request.session[:user] = users(:candi)
    mollie = racers(:mollie)
    original_name = mollie.name
    get(:cancel, :id => mollie.to_param, :name => mollie.name)
    assert_response(:success)
    assert_template("/admin/_attribute")
    assert_not_nil(assigns["racer"], "Should assign racer")
    assert_equal(mollie, assigns['racer'], 'Racer')
    mollie.reload
    assert_equal(original_name, mollie.name, 'Racer name after cancel')
  end

  def test_update_name
    @request.session[:user] = users(:candi)
    mollie = racers(:mollie)
    post(:update_name, :id => mollie.to_param, :name => 'Molly Cameron')
    assert_response(:success)
    assert_template("/admin/_attribute")
    assert_not_nil(assigns["racer"], "Should assign racer")
    assert_equal(mollie, assigns['racer'], 'Racer')
    mollie.reload
    assert_equal('Molly', mollie.first_name, 'Racer first_name after update')
    assert_equal('Cameron', mollie.last_name, 'Racer last_name after update')
  end
  
  def test_update_same_name
    @request.session[:user] = users(:candi)
    mollie = racers(:mollie)
    post(:update_name, :id => mollie.to_param, :name => 'Mollie Cameron')
    assert_response(:success)
    assert_template("/admin/_attribute")
    assert_not_nil(assigns["racer"], "Should assign racer")
    assert_equal(mollie, assigns['racer'], 'Racer')
    mollie.reload
    assert_equal('Mollie', mollie.first_name, 'Racer first_name after update')
    assert_equal('Cameron', mollie.last_name, 'Racer last_name after update')
  end
  
  def test_update_same_name_different_case
    @request.session[:user] = users(:candi)
    mollie = racers(:mollie)
    post(:update_name, :id => mollie.to_param, :name => 'mollie cameron')
    assert_response(:success)
    assert_template("/admin/_attribute")
    assert_not_nil(assigns["racer"], "Should assign racer")
    assert_equal(mollie, assigns['racer'], 'Racer')
    mollie.reload
    assert_equal('mollie', mollie.first_name, 'Racer first_name after update')
    assert_equal('cameron', mollie.last_name, 'Racer last_name after update')
  end
  
  def test_update_to_existing_name
    # Should ask to merge
    @request.session[:user] = users(:candi)
    mollie = racers(:mollie)
    post(:update_name, :id => mollie.to_param, :name => 'Erik Tonkin')
    assert_response(:success)
    assert_template("admin/racers/_merge_confirm")
    assert_not_nil(assigns["racer"], "Should assign racer")
    assert_equal(mollie, assigns['racer'], 'Racer')
    assert_not_nil(Racer.find_all_by_name('Mollie Cameron'), 'Mollie still in database')
    assert_not_nil(Racer.find_all_by_name('Erik Tonkin'), 'Tonkin still in database')
    mollie.reload
    assert_equal('Mollie Cameron', mollie.name, 'Racer name after cancel')
  end
  
  def test_update_to_existing_alias
    erik_alias = Alias.find_by_name('Eric Tonkin')
    assert_not_nil(erik_alias, 'Alias')

    @request.session[:user] = users(:candi)
    tonkin = racers(:tonkin)
    post(:update_name, :id => tonkin.to_param, :name => 'Eric Tonkin')
    assert_response(:success)
    assert_template("/admin/_attribute")
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
    mollie_alias = Alias.find_by_name('Mollie Cameron')
    assert_nil(mollie_alias, 'Alias')
    molly_alias = Alias.find_by_name('Molly Cameron')
    assert_not_nil(molly_alias, 'Alias')

    @request.session[:user] = users(:candi)
    mollie = racers(:mollie)
    post(:update_name, :id => mollie.to_param, :name => 'molly cameron')
    assert_response(:success)
    assert_template("/admin/_attribute")
    assert_not_nil(assigns["racer"], "Should assign racer")
    assert_equal(mollie, assigns['racer'], 'Racer')
    mollie.reload
    assert_equal('molly cameron', mollie.name, 'Racer name after update')
    mollie_alias = Alias.find_by_name('Mollie Cameron')
    assert_not_nil(mollie_alias, 'Alias')
    assert_equal(mollie, mollie_alias.racer, 'Alias racer')
    molly_alias = Alias.find_by_name('molly cameron')
    assert_nil(molly_alias, 'Alias')
  end
  
  def test_update_to_other_racer_existing_alias
    @request.session[:user] = users(:candi)
    tonkin = racers(:tonkin)
    post(:update_name, :id => tonkin.to_param, :name => 'Molly Cameron')
    assert_response(:success)
    assert_template("admin/racers/_merge_confirm")
    assert_not_nil(assigns["racer"], "Should assign racer")
    assert_equal(tonkin, assigns['racer'], 'Racer')
    assert_equal([racers(:mollie)], assigns['existing_racers'], 'existing_racers')
    assert(!Alias.find_all_racers_by_name('Molly Cameron').empty?, 'Molly still in database')
    assert(!Racer.find_all_by_name('Mollie Cameron').empty?, 'Mollie still in database')
    assert(!Racer.find_all_by_name('Erik Tonkin').empty?, 'Erik Tonkin still in database')
  end
  
  def test_update_to_other_racer_existing_alias_and_duplicate_names
    @request.session[:user] = users(:candi)
    tonkin = racers(:tonkin)
    mollie_with_different_road_number = Racer.create(:name => 'Molly Cameron', :road_number => '1009')
    post(:update_name, :id => tonkin.to_param, :name => 'Molly Cameron')
    assert_response(:success)
    assert_template("admin/racers/_merge_confirm")
    assert_not_nil(assigns["racer"], "Should assign racer")
    assert_equal(tonkin, assigns['racer'], 'Racer')
    assert_equal(2, assigns['existing_racers'].size, 'existing_racers')
    assert(!Racer.find_all_by_name('Molly Cameron').empty?, 'Molly still in database')
    assert(!Racer.find_all_by_name('Mollie Cameron').empty?, 'Mollie still in database')
    assert(!Racer.find_all_by_name('Erik Tonkin').empty?, 'Erik Tonkin still in database')
  end
  
  def test_destroy
    @request.session[:user] = users(:candi)
    csc = Racer.create(:name => 'CSC')
    post(:destroy, :id => csc.id, :commit => 'Delete')
    assert_response(:success)
    assert_raise(ActiveRecord::RecordNotFound, 'CSC should have been destroyed') { Racer.find(csc.id) }
  end
  
  def test_merge?
    @request.session[:user] = users(:candi)
    mollie = racers(:mollie)
    tonkin = racers(:tonkin)
    get(:update_name, :name => mollie.name, :id => tonkin.to_param)
    assert_response(:success)
    assert_equal(tonkin, assigns['racer'], 'Racer')
    racer = assigns['racer']
    assert(racer.errors.empty?, "Racer should have no errors, but had: #{racer.errors.full_messages}")
    assert_template("admin/racers/_merge_confirm")
    assert_equal(mollie.name, assigns['racer'].name, 'Unsaved Tonkin name should be Mollie')
    assert_equal([mollie], assigns['existing_racers'], 'existing_racers')
  end
  
  def test_merge
    mollie = racers(:mollie)
    tonkin = racers(:tonkin)
    old_id = tonkin.id
    assert(Racer.find_all_by_name('Erik Tonkin'), 'Tonkin should be in database')

    @request.session[:user] = users(:candi)
    get(:merge, :id => tonkin.to_param, :target_id => mollie.id)
    assert_response(:success)
    assert_template("admin/racers/merge")

    assert(Racer.find_all_by_name('Mollie Cameron'), 'Mollie should be in database')
    assert_equal([], Racer.find_all_by_name('Erik Tonkin'), 'Tonkin should not be in database')
  end

  def test_new_inline
    @request.session[:user] = users(:candi)
    opts = {:controller => "admin/racers", :action => "new_inline"}
    assert_routing("/admin/racers/new_inline", opts)
  
    get(:new_inline)
    assert_response(:success)
    assert_template("/admin/_new_inline")
    assert_not_nil(assigns["record"], "Should assign category as 'record'")
    assert_not_nil(assigns["icon"], "Should assign 'icon'")
  end
  
  def test_edit_team_name
    @request.session[:user] = users(:candi)
    weaver = racers(:weaver)
    get(:edit_team_name, :id => weaver.to_param)
    assert_response(:success)
    assert_template("admin/racers/_edit_team_name")
    assert_not_nil(assigns["racer"], "Should assign racer")
    assert_equal(weaver, assigns['racer'], 'Should assign racer')
  end
  
  def test_update_team_name_to_new_team
    assert_nil(Team.find_by_name('Velo Slop'), 'New team Velo Slop should not be in database')
    @request.session[:user] = users(:candi)
    mollie = racers(:mollie)
    post(:update_team_name, :id => mollie.to_param, :team_name => 'Velo Slop')
    assert_response(:success)
    assert_template("admin/racers/_team")
    assert_not_nil(assigns["racer"], "Should assign racer")
    assert_equal(mollie, assigns['racer'], 'Racer')
    mollie.reload
    assert_equal('Velo Slop', mollie.team_name, 'Racer team name after update')
    assert_not_nil(Team.find_by_name('Velo Slop'), 'New team Velo Slop should be in database')
  end
  
  def test_update_team_name_to_existing_team
    mollie = racers(:mollie)
    assert_equal(Team.find_by_name('Vanilla'), mollie.team, 'Mollie should be on Vanilla')
    @request.session[:user] = users(:candi)
    post(:update_team_name, :id => mollie.to_param, :team_name => 'Gentle Lovers')
    assert_response(:success)
    assert_template("admin/racers/_team")
    assert_not_nil(assigns["racer"], "Should assign racer")
    assert_equal(mollie, assigns['racer'], 'Racer')
    mollie.reload
    assert_equal('Gentle Lovers', mollie.team_name, 'Racer team name after update')
    assert_equal(Team.find_by_name('Gentle Lovers'), mollie.team, 'Mollie should be on Gentle Lovers')
  end

  def test_update_team_name_to_blank
    mollie = racers(:mollie)
    assert_equal(Team.find_by_name('Vanilla'), mollie.team, 'Mollie should be on Vanilla')
    @request.session[:user] = users(:candi)
    post(:update_team_name, :id => mollie.to_param, :team_name => '')
    assert_response(:success)
    assert_template("admin/racers/_team")
    assert_not_nil(assigns["racer"], "Should assign racer")
    assert_equal(mollie, assigns['racer'], 'Racer')
    mollie.reload
    assert_equal('', mollie.team_name, 'Racer team name after update')
    assert_nil(mollie.team, 'Mollie should have no team')
  end
    
  def test_cancel_edit_team_name
    @request.session[:user] = users(:candi)
    mollie = racers(:mollie)
    original_name = mollie.name
    get(:cancel_edit_team_name, :id => mollie.to_param, :name => mollie.name)
    assert_response(:success)
    assert_template("admin/racers/_team")
    assert_not_nil(assigns["racer"], "Should assign racer")
    assert_equal(mollie, assigns['racer'], 'Racer')
    mollie.reload
    assert_equal(original_name, mollie.name, 'Racer name after cancel')
  end

  def test_update_member
    @request.session[:user] = users(:candi)
    mollie = racers(:mollie)
    assert_equal(true, mollie.member, 'member before update')
    post(:toggle_attribute, :id => mollie.to_param, :attribute => 'member')
    assert_response(:success)
    assert_template("/admin/_attribute")
    mollie.reload
    assert_equal(false, mollie.member, 'member after update')

    mollie = racers(:mollie)
    post(:toggle_attribute, :id => mollie.to_param, :attribute => 'member')
    assert_response(:success)
    assert_template("/admin/_attribute")
    mollie.reload
    assert_equal(true, mollie.member, 'member after second update')
  end
  
  def test_dupes_merge?
    @request.session[:user] = users(:candi)
    mollie = racers(:mollie)
    mollie_with_different_road_number = Racer.create(:name => 'Mollie Cameron', :road_number => '987123')
    tonkin = racers(:tonkin)
    get(:update_name, :name => mollie.name, :id => tonkin.to_param)
    assert_response(:success)
    assert_equal(tonkin, assigns['racer'], 'Racer')
    racer = assigns['racer']
    assert(racer.errors.empty?, "Racer should have no errors, but had: #{racer.errors.full_messages}")
    assert_template("admin/racers/_merge_confirm")
    assert_equal(mollie.name, assigns['racer'].name, 'Unsaved Tonkin name should be Mollie')
    assert_equal([mollie, mollie_with_different_road_number], assigns['existing_racers'], 'existing_racers')
  end
  
  def test_dupes_merge_one_has_road_number_one_has_cross_number?
    @request.session[:user] = users(:candi)
    mollie = racers(:mollie)
    mollie.ccx_number = '2'
    mollie.save!
    mollie_with_different_cross_number = Racer.create(:name => 'Mollie Cameron', :ccx_number => '810', :road_number => '1009')
    tonkin = racers(:tonkin)
    get(:update_name, :name => mollie.name, :id => tonkin.to_param)
    assert_response(:success)
    assert_equal(tonkin, assigns['racer'], 'Racer')
    racer = assigns['racer']
    assert(racer.errors.empty?, "Racer should have no errors, but had: #{racer.errors.full_messages}")
    assert_template("admin/racers/_merge_confirm")
    assert_equal(mollie.name, assigns['racer'].name, 'Unsaved Tonkin name should be Mollie')
    assert_equal([mollie, mollie_with_different_cross_number], assigns['existing_racers'], 'existing_racers')
  end
  
  def test_dupes_merge_alias?
    @request.session[:user] = users(:candi)
    mollie = racers(:mollie)
    tonkin = racers(:tonkin)
    get(:update_name, :name => 'Eric Tonkin', :id => mollie.to_param)
    assert_response(:success)
    assert_equal(mollie, assigns['racer'], 'Racer')
    racer = assigns['racer']
    assert(racer.errors.empty?, "Racer should have no errors, but had: #{racer.errors.full_messages}")
    assert_template("admin/racers/_merge_confirm")
    assert_equal('Eric Tonkin', assigns['racer'].name, 'Unsaved Mollie name should be Eric Tonkin alias')
    assert_equal([tonkin], assigns['existing_racers'], 'existing_racers')
  end
  
  def test_dupe_merge
    mollie = racers(:mollie)
    tonkin = racers(:tonkin)
    tonkin_with_different_road_number = Racer.create(:name => 'Erik Tonkin', :road_number => 'YYZ')
    assert(tonkin_with_different_road_number.valid?, "tonkin_with_different_road_number not valid: #{tonkin_with_different_road_number.errors.full_messages}")
    assert_equal(tonkin_with_different_road_number.new_record?, false, 'tonkin_with_different_road_number should be saved')
    old_id = tonkin.id
    assert_equal(2, Racer.find_all_by_name('Erik Tonkin').size, 'Tonkins in database')

    @request.session[:user] = users(:candi)
    get(:merge, :id => tonkin.to_param, :target_id => mollie.id)
    assert_response(:success)
    assert_template("admin/racers/merge")

    assert(Racer.find_all_by_name('Mollie Cameron'), 'Mollie should be in database')
    tonkins_after_merge = Racer.find_all_by_name('Erik Tonkin')
    assert_equal(1, tonkins_after_merge.size, tonkins_after_merge)
  end
  
  def test_new
    @request.session[:user] = users(:candi)
    opts = {:controller => "admin/racers", :action => "new"}
    assert_routing("/admin/racers/new", opts)
  
    get(:new)
    assert_response(:success)
    assert_template("/admin/racers/show")
    assert_not_nil(assigns["racer"], "Should assign racer as 'racer'")
    assert_not_nil(assigns["race_numbers"], "Should assign racer's number for current year as 'race_numbers'")
  end

  def test_show
    @request.session[:user] = users(:candi)
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
    opts = {:controller => "admin/racers", :action => "update"}
    assert_routing("/admin/racers/update", opts)

    assert_equal([], Racer.find_all_by_name('Jon Knowlson'), 'Knowlson should not be in database')
    @request.session[:user] = users(:candi)
    
    post(:update, {"racer"=>{"work_phone"=>"", "date_of_birth(2i)"=>"", "occupation"=>"", "city"=>"Brussels", "cell_fax"=>"", "zip"=>"", "date_of_birth(3i)"=>"", "mtb_category"=>"", "dh_category"=>"", "member"=>"1", "gender"=>"", "ccx_category"=>"", "team_name"=>"", "road_category"=>"", "xc_number"=>"", "street"=>"", "track_category"=>"", "home_phone"=>"", "dh_number"=>"", "road_number"=>"", "first_name"=>"Jon", "ccx_number"=>"", "last_name"=>"Knowlson", "date_of_birth(1i)"=>"", "email"=>"", "state"=>""}, "commit"=>"Save"})
    
    if assigns['racer']
      assert(assigns['racer'].errors.empty?, assigns['racer'].errors.full_messages)
    end
    
    assert(flash.empty?, "Flash should be empty, but was: #{flash}")
    assert_response(:redirect)
    knowlsons = Racer.find_all_by_name('Jon Knowlson')
    assert(!knowlsons.empty?, 'Knowlson should be created')
    assert_redirected_to(:id => knowlsons.first.id)
  end

  def test_create_with_road_number
    opts = {:controller => "admin/racers", :action => "update"}
    assert_routing("/admin/racers/update", opts)

    assert_equal([], Racer.find_all_by_name('Jon Knowlson'), 'Knowlson should not be in database')
    @request.session[:user] = users(:candi)
    
    post(:update, {
      "racer"=>{"work_phone"=>"", "date_of_birth(2i)"=>"", "occupation"=>"", "city"=>"Brussels", "cell_fax"=>"", "zip"=>"", "date_of_birth(3i)"=>"", "mtb_category"=>"", "dh_category"=>"", "member"=>"1", "gender"=>"", "ccx_category"=>"", "team_name"=>"", "road_category"=>"", "xc_number"=>"", "street"=>"", "track_category"=>"", "home_phone"=>"", "dh_number"=>"", "road_number"=>"", "first_name"=>"Jon", "ccx_number"=>"", "last_name"=>"Knowlson", "date_of_birth(1i)"=>"", "email"=>"", "state"=>""}, 
      "number_issuer_id"=>["1", "1"], "number_value"=>["8977", "BBB9"], "discipline_id"=>["4", "3"], :number_year => '2007',
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
  end

  def test_update
    mollie = racers(:mollie)
    post(:update, {"commit"=>"Save", 
                   "number_year" => Date.today.year.to_s,
                   "number_issuer_id"=>["1"], "number_value"=>[""], "discipline_id"=>["1"],
                   "number"=>{"5"=>{"value"=>"222"}},
                   "racer"=>{"work_phone"=>"", "date_of_birth(2i)"=>"1", "occupation"=>"engineer", "city"=>"Wilsonville", "cell_fax"=>"", "zip"=>"97070", "date_of_birth(3i)"=>"1", "mtb_category"=>"Spt", "member_on(1i)"=>"2005", "dh_category"=>"", "member_on(2i)"=>"12", "member_on(3i)"=>"17", "member"=>"1", "gender"=>"M", "notes"=>"rm", "ccx_category"=>"", "team_name"=>"", "road_category"=>"5", "xc_number"=>"1061", "street"=>"31153 SW Willamette Hwy W", "track_category"=>"", "home_phone"=>"503-582-8823", "dh_number"=>"917", "road_number"=>"2051", "first_name"=>"Paul", "ccx_number"=>"112", "last_name"=>"Formiller", "date_of_birth(1i)"=>"1969", "email"=>"paul.formiller@verizon.net", "state"=>"OR"}, 
                   "id"=>mollie.to_param}
    )
    assert_response(:redirect)
    assert(flash.empty?, 'flash empty?')
    assert_equal('222', mollie.road_number(true), 'Road number should be updated')
  end

  def test_update_new_number
    mollie = racers(:mollie)
    post(:update, {"commit"=>"Save", 
                   "number_year" => Date.today.year.to_s,
                   "number_issuer_id"=>["1"], "number_value"=>["AZY"], "discipline_id"=>["3"],
                   "number"=>{"5"=>{"value"=>"202"}},
                   "racer"=>{"work_phone"=>"", "date_of_birth(2i)"=>"1", "occupation"=>"engineer", "city"=>"Wilsonville", "cell_fax"=>"", "zip"=>"97070", 
                   "date_of_birth(3i)"=>"1", "mtb_category"=>"Spt", "member_on(1i)"=>"2005", "dh_category"=>"", "member_on(2i)"=>"12", "member_on(3i)"=>"17", 
                   "member"=>"1", "gender"=>"M", "notes"=>"rm", "ccx_category"=>"", "team_name"=>"", "road_category"=>"5", "street"=>"31153 SW Willamette Hwy W", 
                   "track_category"=>"", "home_phone"=>"503-582-8823", "first_name"=>"Paul", "last_name"=>"Formiller", "date_of_birth(1i)"=>"1969", 
                   "email"=>"paul.formiller@verizon.net", "state"=>"OR"}, 
                   "id"=>mollie.to_param}
    )
    assert_response(:redirect)
    assert(flash.empty?, 'flash empty?')
    mollie.reload
    assert_equal('202', mollie.road_number, 'Road number should not be updated')
    assert_equal('AZY', mollie.xc_number, 'MTB number should be updated')
  end

  def test_update_error
    mollie = racers(:mollie)
    post(:update, 
    :id => mollie.to_param, 
      :racer => {
        :first_name => 'Mollie', :last_name => 'Cameron', :road_number => '123123612333', "member_on(2i)" => "999", :team_id => "-9"
    })
    assert_response(:success)
    assert_template("admin/racers/show")
    assert_not_nil(assigns["racer"], "Should assign racer")
    assert_equal(mollie, assigns['racer'], 'Should assign Alice to racer')
    assert(!flash.empty?, 'flash not empty?')
  end
  
  def test_number_year_changed
    racer = racers(:mollie)
    
    opts = {:controller => "admin/racers", :action => "number_year_changed", :id => racer.to_param.to_s}
    assert_routing("/admin/racers/number_year_changed/#{racer.to_param}", opts)

    post(:number_year_changed, 
         :id => racer.to_param.to_s,
         :year => '2010'
    )
    assert_response(:success)
    assert_template("/admin/racers/_numbers")
    assert_not_nil(assigns["race_numbers"], "Should assign 'race_numbers'")
    assert_not_nil(assigns["year"], "Should assign today's year as 'year'")
    assert_equal('2010', assigns["year"], "Should assign selected year as 'year'")
    assert_not_nil(assigns["years"], "Should assign range of years as 'years'")
    assert(assigns["years"].size >= 2, "Should assign range of years as 'years', but was: #{assigns[:years]}")
  end
  
  def test_destroy_number
    assert_not_nil(RaceNumber.find(5), 'RaceNumber with ID 5 should exist')
    
    opts = {:controller => "admin/racers", :action => "destroy_number", :id => '5'}
    assert_routing("/admin/racers/destroy_number/5", opts)

    post(:destroy_number, :id => '5')
    assert_response(:success)
    
    assert_raise(ActiveRecord::RecordNotFound, 'Should delete RaceNumber with ID of 5') {RaceNumber.find(5)}
  end
end