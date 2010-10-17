require File.expand_path("../../../test_helper", __FILE__)

# :stopdoc:
class Admin::PeopleControllerTest < ActionController::TestCase
  def setup
    super
    create_administrator_session
    use_ssl
  end

  def test_not_logged_in_index
    destroy_person_session
    get(:index)
    assert_redirected_to(new_person_session_url(secure_redirect_options))
    assert_nil(@request.session["person"], "No person in session")
  end
  
  def test_not_logged_in_edit
    destroy_person_session
    weaver = people(:weaver)
    get(:edit_name, :id => weaver.to_param)
    assert_redirected_to(new_person_session_url(secure_redirect_options))
    assert_nil(@request.session["person"], "No person in session")
  end

  def test_index
    opts = {:controller => "admin/people", :action => "index"}
    assert_routing("/admin/people", opts)
    
    get(:index)
    assert_response(:success)
    assert_template("admin/people/index")
    assert_layout("admin/application")
    assert_not_nil(assigns["people"], "Should assign people")
    assert(assigns["people"].empty?, "Should have no people")
    assert_not_nil(assigns["name"], "Should assign name")
  end

  def test_find
    get(:index, :name => 'weav')
    assert_response(:success)
    assert_template("admin/people/index")
    assert_not_nil(assigns["people"], "Should assign people")
    assert_equal([people(:weaver)], assigns['people'], 'Search for weav should find Weaver')
    assert_not_nil(assigns["name"], "Should assign name")
    assert_equal('weav', assigns['name'], "'name' assigns")
  end

  def test_find_by_number
    get(:index, :name => '102')
    assert_response(:success)
    assert_template("admin/people/index")
    assert_not_nil(assigns["people"], "Should assign people")
    assert_equal([people(:tonkin)], assigns['people'], 'Search for 102 should find Tonkin')
    assert_not_nil(assigns["name"], "Should assign name")
    assert_equal('102', assigns['name'], "'name' assigns")
  end

  def test_find_nothing
    get(:index, :name => 's7dfnacs89danfx')
    assert_response(:success)
    assert_template("admin/people/index")
    assert_not_nil(assigns["people"], "Should assign people")
    assert_equal(0, assigns['people'].size, "Should find no people")
  end
  
  def test_find_empty_name
    get(:index, :name => '')
    assert_response(:success)
    assert_template("admin/people/index")
    assert_not_nil(assigns["people"], "Should assign people")
    assert_equal(0, assigns['people'].size, "Search for '' should find no people")
    assert_not_nil(assigns["name"], "Should assign name")
    assert_equal('', assigns['name'], "'name' assigns")
  end

  def test_find_limit
    for i in 0..RacingAssociation.current.search_results_limit
      Person.create(:name => "Test Person #{i}")
    end
    get(:index, :name => 'Test')
    assert_response(:success)
    assert_template("admin/people/index")
    assert_not_nil(assigns["people"], "Should assign people")
    assert_equal(RacingAssociation.current.search_results_limit, assigns['people'].size, "Search for '' should find all people")
    assert_not_nil(assigns["name"], "Should assign name")
    assert(!flash.empty?, 'flash not empty?')
    assert_equal('Test', assigns['name'], "'name' assigns")
  end
  
  def test_index_rjs
    get(:index, :name => 'weav', :format => "js")
    assert_response(:success)
    assert_template("admin/people/index")
    assert_not_nil(assigns["people"], "Should assign people")
    assert_equal([people(:weaver)], assigns['people'], 'Search for weav should find Weaver')
  end

  def test_blank_name
    molly = people(:molly)
    post(:set_person_name, 
        :id => molly.to_param,
        :value => "",
        :editorId => "person_#{molly.id}_name"
    )
    assert_response(:success)
    person = assigns["person"]
    assert_not_nil(person, "Should assign person")
    assert(person.errors.empty?, "Should have no errors, but had: #{person.errors.full_messages}")
    assert_template(nil)
    assert_equal(molly, assigns['person'], 'Person')
    molly.reload
    assert_equal('', molly.first_name, 'Person first_name after update')
    assert_equal('', molly.last_name, 'Person last_name after update')
  end

  def test_index_with_cookie
    @request.cookies["person_name"] = "weaver"
    get(:index)
    assert_response(:success)
    assert_not_nil(assigns["people"], "Should assign people")
    assert_equal("weaver", assigns["name"], "Should assign name")
    assert_equal(1, assigns["people"].size, "Should have no people")
  end

  def test_update_name
    molly = people(:molly)
    post(:set_person_name, 
        :id => molly.to_param,
        :value => "Mollie Cameron",
        :editorId => "person_#{molly.id}_name"
    )
    assert_response(:success)
    assert_template(nil)
    assert_not_nil(assigns["person"], "Should assign person")
    assert_equal(molly, assigns['person'], 'Person')
    molly.reload
    assert_equal('Mollie', molly.first_name, 'Person first_name after update')
    assert_equal('Cameron', molly.last_name, 'Person last_name after update')
  end
  
  def test_update_same_name
    molly = people(:molly)
    post(:set_person_name, 
        :id => molly.to_param,
        :value => "Molly Cameron",
        :editorId => "person_#{molly.id}_name"
    )
    assert_response(:success)
    assert_template(nil)
    assert_not_nil(assigns["person"], "Should assign person")
    assert_equal(molly, assigns['person'], 'Person')
    molly.reload
    assert_equal('Molly', molly.first_name, 'Person first_name after update')
    assert_equal('Cameron', molly.last_name, 'Person last_name after update')
  end
  
  def test_update_same_name_different_case
    molly = people(:molly)
    post(:set_person_name, 
        :id => molly.to_param,
        :value => "molly cameron",
        :editorId => "person_#{molly.id}_name"
    )
    assert_response(:success)
    assert_template(nil)
    assert_not_nil(assigns["person"], "Should assign person")
    assert_equal(molly, assigns['person'], 'Person')
    molly.reload
    assert_equal('molly', molly.first_name, 'Person first_name after update')
    assert_equal('cameron', molly.last_name, 'Person last_name after update')
  end
  
  def test_update_to_existing_name
    # Should ask to merge
    molly = people(:molly)
    post(:set_person_name, 
        :id => molly.to_param,
        :value => "Erik Tonkin",
        :editorId => "person_#{molly.id}_name"
    )
    assert_response(:success)
    assert_template("admin/people/_merge_confirm")
    assert_not_nil(assigns["person"], "Should assign person")
    assert_equal(molly, assigns['person'], 'Person')
    assert_not_nil(Person.find_all_by_name('Molly Cameron'), 'Molly still in database')
    assert_not_nil(Person.find_all_by_name('Erik Tonkin'), 'Tonkin still in database')
    molly.reload
    assert_equal('Molly Cameron', molly.name, 'Person name after cancel')
  end
  
  def test_update_to_existing_alias
    erik_alias = Alias.find_by_name('Eric Tonkin')
    assert_not_nil(erik_alias, 'Alias')

    tonkin = people(:tonkin)
    post(:set_person_name, 
        :id => tonkin.to_param,
        :value => 'Eric Tonkin',
        :editorId => "person_#tonkin.id}_name"
    )
    assert_response(:success)
    assert_template(nil)
    assert_not_nil(assigns["person"], "Should assign person")
    assert_equal(tonkin, assigns['person'], 'Person')
    tonkin.reload
    assert_equal('Eric Tonkin', tonkin.name, 'Person name after cancel')
    erik_alias = Alias.find_by_name('Erik Tonkin')
    assert_not_nil(erik_alias, 'Alias')
    assert_equal(tonkin, erik_alias.person, 'Alias person')
    old_erik_alias = Alias.find_by_name('Eric Tonkin')
    assert_nil(old_erik_alias, 'Old alias')
  end
  
  def test_update_to_existing_alias_different_case
    molly_alias = Alias.find_by_name('Molly Cameron')
    assert_nil(molly_alias, 'Alias')
    mollie_alias = Alias.find_by_name('Mollie Cameron')
    assert_not_nil(mollie_alias, 'Alias')

    molly = people(:molly)
    post(:set_person_name, 
        :id => molly.to_param,
        :value => 'mollie cameron',
        :editorId => "person_#{molly.id}_name"
    )
    assert_response(:success)
    assert_template(nil)
    assert_not_nil(assigns["person"], "Should assign person")
    assert_equal(molly, assigns['person'], 'Person')
    molly.reload
    assert_equal('mollie cameron', molly.name, 'Person name after update')
    molly_alias = Alias.find_by_name('Molly Cameron')
    assert_not_nil(molly_alias, 'Alias')
    assert_equal(molly, molly_alias.person, 'Alias person')
    mollie_alias = Alias.find_by_name('mollie cameron')
    assert_nil(mollie_alias, 'Alias')
  end
  
  def test_update_to_other_person_existing_alias
    tonkin = people(:tonkin)
    post(:set_person_name, 
        :id => tonkin.to_param,
        :value => "Mollie Cameron",
        :editorId => "person_#tonkin.id}_name"
    )
    assert_response(:success)
    assert_template("admin/people/_merge_confirm")
    assert_not_nil(assigns["person"], "Should assign person")
    assert_equal(tonkin, assigns['person'], 'Person')
    assert_equal([people(:molly)], assigns['existing_people'], 'existing_people')
    assert(!Alias.find_all_people_by_name('Mollie Cameron').empty?, 'Mollie still in database')
    assert(!Person.find_all_by_name('Molly Cameron').empty?, 'Molly still in database')
    assert(!Person.find_all_by_name('Erik Tonkin').empty?, 'Erik Tonkin still in database')
  end
  
  def test_update_to_other_person_existing_alias_and_duplicate_names
    tonkin = people(:tonkin)
    molly_with_different_road_number = Person.create!(:name => 'Molly Cameron', :road_number => '1009')

    assert_equal(0, Person.count(:conditions => ['first_name = ? and last_name = ?', 'Mollie', 'Cameron']), 'Mollies in database')
    assert_equal(2, Person.count(:conditions => ['first_name = ? and last_name = ?', 'Molly', 'Cameron']), 'Mollys in database')
    assert_equal(1, Person.count(:conditions => ['first_name = ? and last_name = ?', 'Erik', 'Tonkin']), 'Eriks in database')
    assert_equal(1, Alias.count(:conditions => ['name = ?', 'Mollie Cameron']), 'Mollie aliases in database')

    post(:set_person_name, 
        :id => tonkin.to_param,
        :value => "Mollie Cameron",
        :editorId => "person_#tonkin.id}_name"
    )
    assert_response(:success)
    assert_template("admin/people/_merge_confirm")
    assert_not_nil(assigns["person"], "Should assign person")
    assert_equal(tonkin, assigns['person'], 'Person')
    assert_equal(1, assigns['existing_people'].size, "existing_people: #{assigns['existing_people']}")

    assert_equal(0, Person.count(:conditions => ['first_name = ? and last_name = ?', 'Mollie', 'Cameron']), 'Mollies in database')
    assert_equal(2, Person.count(:conditions => ['first_name = ? and last_name = ?', 'Molly', 'Cameron']), 'Mollys in database')
    assert_equal(1, Person.count(:conditions => ['first_name = ? and last_name = ?', 'Erik', 'Tonkin']), 'Eriks in database')
    assert_equal(1, Alias.count(:conditions => ['name = ?', 'Mollie Cameron']), 'Mollie aliases in database')
  end
  
  def test_destroy
    person = people(:no_results)
    delete :destroy, :id => person.id
    assert_redirected_to(admin_people_path)
    assert(!Person.exists?(person.id), 'Person should have been destroyed')
  end
  
  def test_ajax_destroy
    person = people(:no_results)
    delete :destroy, :id => person.id, :format => 'js'
    assert_response(:success)
    assert_raise(ActiveRecord::RecordNotFound, 'Person should have been destroyed') { Person.find(person.id) }
  end
  
  def test_destroy_number
    race_number = race_numbers(:molly_road_number)
    assert_not_nil(RaceNumber.find(race_number.id), 'RaceNumber should exist')

    post(:destroy_number, :id => race_number.to_param)
    assert_response(:success)
    
    assert_raise(ActiveRecord::RecordNotFound, "Should delete RaceNumber") {RaceNumber.find(race_number.id)}
  end
  
  def test_destroy_alias
    tonkin = people(:tonkin)
    assert_equal(1, tonkin.aliases.count, 'Tonkin aliases')
    eric_tonkin_alias = tonkin.aliases.first

    opts = {:controller => "admin/people", :action => "destroy_alias", :id => tonkin.id.to_s, :alias_id => eric_tonkin_alias.id.to_s}
    assert_routing("/admin/people/#{tonkin.id}/aliases/#{eric_tonkin_alias.id}/destroy", opts)
    
    post(:destroy_alias, :id => tonkin.id.to_s, :alias_id => eric_tonkin_alias.id.to_s)
    assert_response(:success)
    assert_equal(0, tonkin.aliases(true).count, 'Tonkin aliases after destruction')
  end
  
  def test_merge?
    molly = people(:molly)
    tonkin = people(:tonkin)
    post(:set_person_name, 
        :id => tonkin.to_param,
        :value => molly.name,
        :editorId => "person_#{molly.id}_name"
    )
    assert_response(:success)
    assert_equal(tonkin, assigns['person'], 'Person')
    person = assigns['person']
    assert(person.errors.empty?, "Person should have no errors, but had: #{person.errors.full_messages}")
    assert_template("admin/people/_merge_confirm")
    assert_equal(molly.name, assigns['person'].name, 'Unsaved Tonkin name should be Molly')
    assert_equal([molly], assigns['existing_people'], 'existing_people')
  end
  
  def test_merge
    molly = people(:molly)
    tonkin = people(:tonkin)
    old_id = tonkin.id
    assert Person.find_all_by_name("Erik Tonkin"), "Tonkin should be in database"

    get :merge, :id => tonkin.to_param, :target_id => molly.id
    assert_response :success
    assert_template %Q{admin/people/merge}

    assert Person.find_all_by_name("Molly Cameron"), "Molly should be in database"
    assert_equal [], Person.find_all_by_name("Erik Tonkin"), "Tonkin should not be in database"
  end

  def test_update_team_name_to_new_team
    assert_nil(Team.find_by_name('Velo Slop'), 'New team Velo Slop should not be in database')
    molly = people(:molly)
    post(:set_person_team_name, 
        :id => molly.to_param,
        :value => 'Velo Slop',
        :editorId => "person_#{molly.id}_team_name"
    )
    assert_response(:success)
    assert_template(nil)
    molly.reload
    assert_equal('Velo Slop', molly.team_name, 'Person team name after update')
    assert_not_nil(Team.find_by_name('Velo Slop'), 'New team Velo Slop should be in database')
  end
  
  def test_update_team_name_to_existing_team
    molly = people(:molly)
    assert_equal(Team.find_by_name('Vanilla'), molly.team, 'Molly should be on Vanilla')
    post(:set_person_team_name, 
        :id => molly.to_param,
        :value => 'Gentle Lovers',
        :editorId => "person_#{molly.id}_team_name"
    )
    assert_response(:success)
    assert_template(nil)
    molly.reload
    assert_equal('Gentle Lovers', molly.team_name, 'Person team name after update')
    assert_equal(Team.find_by_name('Gentle Lovers'), molly.team, 'Molly should be on Gentle Lovers')
  end

  def test_update_team_name_to_blank
    molly = people(:molly)
    assert_equal(Team.find_by_name('Vanilla'), molly.team, 'Molly should be on Vanilla')
    post(:set_person_team_name, 
        :id => molly.to_param,
        :value => '',
        :editorId => "person_#{molly.id}_team_name"
    )
    assert_response(:success)
    assert_template(nil)
    molly.reload
    assert_equal('', molly.team_name, 'Person team name after update')
    assert_nil(molly.team, 'Molly should have no team')
  end
    
  def test_toggle_member
    molly = people(:molly)
    assert_equal(true, molly.member, 'member before update')
    post(:toggle_member, :id => molly.to_param)
    assert_response(:success)
    assert_template("shared/_member")
    molly.reload
    assert_equal(false, molly.member, 'member after update')

    molly = people(:molly)
    post(:toggle_member, :id => molly.to_param)
    assert_response(:success)
    assert_template("shared/_member")
    molly.reload
    assert_equal(true, molly.member, 'member after second update')
  end
  
  def test_cancel_in_place_edit
    xhr :post, :cancel_in_place_edit, :id => people(:molly)
    assert_response(:success)
    assert !@response.body["No action responded"], "Response should not include 'No action responded' error"
  end
  
  def test_dupes_merge?
    molly = people(:molly)
    molly_with_different_road_number = Person.create(:name => 'Molly Cameron', :road_number => '987123')
    tonkin = people(:tonkin)
    post(:set_person_name, 
        :id => tonkin.to_param,
        :value => molly.name,
        :editorId => "person_#tonkin.id}_name"
    )
    assert_response(:success)
    assert_equal(tonkin, assigns['person'], 'Person')
    person = assigns['person']
    assert(person.errors.empty?, "Person should have no errors, but had: #{person.errors.full_messages}")
    assert_template("admin/people/_merge_confirm")
    assert_equal(molly.name, assigns['person'].name, 'Unsaved Tonkin name should be Molly')
    existing_people = assigns['existing_people'].sort {|x, y| x.id <=> y.id}
    assert_equal([molly, molly_with_different_road_number], existing_people, 'existing_people')
  end
  
  def test_dupes_merge_one_has_road_number_one_has_cross_number?
    molly = people(:molly)
    molly.ccx_number = '102'
    molly.save!
    molly_with_different_cross_number = Person.create(:name => 'Molly Cameron', :ccx_number => '810', :road_number => '1009')
    tonkin = people(:tonkin)
    post(:set_person_name, 
        :id => tonkin.to_param,
        :value => molly.name,
        :editorId => "person_#tonkin.id}_name"
    )
    assert_response(:success)
    assert_equal(tonkin, assigns['person'], 'Person')
    person = assigns['person']
    assert(person.errors.empty?, "Person should have no errors, but had: #{person.errors.full_messages}")
    assert_template("admin/people/_merge_confirm")
    assert_equal(molly.name, assigns['person'].name, 'Unsaved Tonkin name should be Molly')
    existing_people = assigns['existing_people'].collect do |person|
      "#{person.name} ##{person.id}"
    end
    existing_people = existing_people.join(', ')
    assert(assigns['existing_people'].include?(molly), "existing_people should include Molly ##{molly.id}, but has #{existing_people}")
    assert(assigns['existing_people'].include?(molly_with_different_cross_number), 'existing_people')
    assert_equal(2, assigns['existing_people'].size, 'existing_people')
  end
  
  def test_dupes_merge_alias?
    molly = people(:molly)
    tonkin = people(:tonkin)
    post(:set_person_name, 
        :id => molly.to_param,
        :value => 'Eric Tonkin',
        :editorId => "person_#{molly.id}_name"
    )
    assert_response(:success)
    assert_equal(molly, assigns['person'], 'Person')
    person = assigns['person']
    assert(person.errors.empty?, "Person should have no errors, but had: #{person.errors.full_messages}")
    assert_template("admin/people/_merge_confirm")
    assert_equal('Eric Tonkin', assigns['person'].name, 'Unsaved Molly name should be Eric Tonkin alias')
    assert_equal([tonkin], assigns['existing_people'], 'existing_people')
  end
  
  def test_dupe_merge
    molly = people(:molly)
    tonkin = people(:tonkin)
    tonkin_with_different_road_number = Person.create(:name => 'Erik Tonkin', :road_number => 'YYZ')
    assert(tonkin_with_different_road_number.valid?, "tonkin_with_different_road_number not valid: #{tonkin_with_different_road_number.errors.full_messages}")
    assert_equal(tonkin_with_different_road_number.new_record?, false, 'tonkin_with_different_road_number should be saved')
    old_id = tonkin.id
    assert_equal(2, Person.find_all_by_name('Erik Tonkin').size, 'Tonkins in database')

    get(:merge, :id => tonkin.to_param, :target_id => molly.id)
    assert_response(:success)
    assert_template("admin/people/merge")

    assert(Person.find_all_by_name('Molly Cameron'), 'Molly should be in database')
    tonkins_after_merge = Person.find_all_by_name('Erik Tonkin')
    assert_equal(1, tonkins_after_merge.size, tonkins_after_merge)
  end
  
  def test_new
    get(:new)
    assert_response(:success)
    assert_template("admin/people/edit")
    assert_not_nil(assigns["person"], "Should assign person as 'person'")
    assert_not_nil(assigns["race_numbers"], "Should assign person's number for current year as 'race_numbers'")
  end

  def test_edit
    alice = people(:alice)

    get(:edit, :id => alice.to_param)
    assert_response(:success)
    assert_template("admin/people/edit")
    assert_not_nil(assigns["person"], "Should assign person")
    assert_equal(alice, assigns['person'], 'Should assign Alice to person')
    assert_nil(assigns['event'], "Should not assign 'event'")
  end

  def test_edit_created_by_import_file
    alice = people(:alice)
    alice.created_by = ImportFile.create!(:name => "some_very_long_import_file_name.xls")
    alice.save!

    get(:edit, :id => alice.to_param)
    assert_response(:success)
    assert_template("admin/people/edit")
    assert_not_nil(assigns["person"], "Should assign person")
    assert_equal(alice, assigns['person'], 'Should assign Alice to person')
  end
  
  def test_create
    assert_equal([], Person.find_all_by_name('Jon Knowlson'), 'Knowlson should not be in database')
    
    post(:create, {"person"=>{
                        "member_from(1i)"=>"", "member_from(2i)"=>"", "member_from(3i)"=>"", 
                        "member_to(1i)"=>"", "member_to(2i)"=>"", "member_to(3i)"=>"", 
                        "work_phone"=>"", "date_of_birth(2i)"=>"", "occupation"=>"", "city"=>"Brussels", "cell_fax"=>"", "zip"=>"", 
                        "date_of_birth(3i)"=>"", "mtb_category"=>"", "dh_category"=>"", "member"=>"1", "gender"=>"", "ccx_category"=>"", 
                        "team_name"=>"", "road_category"=>"", "xc_number"=>"", "street"=>"", "track_category"=>"", "home_phone"=>"", 
                        "dh_number"=>"", "road_number"=>"", "first_name"=>"Jon", "ccx_number"=>"", "last_name"=>"Knowlson", 
                        "date_of_birth(1i)"=>"", "email"=>"", "state"=>""}, "commit"=>"Save"})
    
    assert assigns['person'].errors.empty?, assigns['person'].errors.full_messages.join
    
    assert(flash.empty?, "Flash should be empty, but was: #{flash}")
    knowlsons = Person.find_all_by_name('Jon Knowlson')
    assert(!knowlsons.empty?, 'Knowlson should be created')
    assert_redirected_to(edit_admin_person_path(knowlsons.first))
    assert_nil(knowlsons.first.member_from, 'member_from after update')
    assert_nil(knowlsons.first.member_to, 'member_to after update')
    assert_equal(people(:administrator), knowlsons.first.created_by, "created by")
    assert_equal("Candi Murray", knowlsons.first.created_by.name, "created by")
  end

  def test_create_with_road_number
    assert_equal([], Person.find_all_by_name('Jon Knowlson'), 'Knowlson should not be in database')
    
    post(:create, {
      "person"=>{"work_phone"=>"", "date_of_birth(2i)"=>"", "occupation"=>"", "city"=>"Brussels", "cell_fax"=>"", "zip"=>"", 
        "member_from(1i)"=>"2004", "member_from(2i)"=>"2", "member_from(3i)"=>"16", 
        "member_to(1i)"=>"2004", "member_to(2i)"=>"12", "member_to(3i)"=>"31", 
        "date_of_birth(3i)"=>"", "mtb_category"=>"", "dh_category"=>"", "member"=>"1", "gender"=>"", "ccx_category"=>"", 
        "team_name"=>"", "road_category"=>"", "xc_number"=>"", "street"=>"", "track_category"=>"", "home_phone"=>"", "dh_number"=>"", 
        "road_number"=>"", "first_name"=>"Jon", "ccx_number"=>"", "last_name"=>"Knowlson", "date_of_birth(1i)"=>"", "email"=>"", "state"=>""}, 
        "number_issuer_id"=>[number_issuers(:association).to_param, number_issuers(:association).to_param], "number_value"=>["8977", "BBB9"],
        "discipline_id"=>[disciplines(:road).id.to_s, disciplines(:mountain_bike).id.to_s], 
        :number_year => '2007', "official" => "0",
      "commit"=>"Save"})
    
    assert assigns['person'].errors.empty?, assigns['person'].errors.full_messages.join
    
    assert(flash.empty?, "flash empty? #{flash}")
    knowlsons = Person.find_all_by_name('Jon Knowlson')
    assert(!knowlsons.empty?, 'Knowlson should be created')
    assert_redirected_to(edit_admin_person_path(knowlsons.first))
    race_numbers = knowlsons.first.race_numbers
    assert_equal(2, race_numbers.size, 'Knowlson race numbers')
    
    race_number = RaceNumber.find(:first, :conditions => ['discipline_id=? and year=? and person_id=?', Discipline[:road].id, 2007, knowlsons.first.id])
    assert_not_nil(race_number, 'Road number')
    assert_equal(2007, race_number.year, 'Road number year')
    assert_equal('8977', race_number.value, 'Road number value')
    assert_equal(Discipline[:road], race_number.discipline, 'Road number discipline')
    assert_equal(number_issuers(:association), race_number.number_issuer, 'Road number issuer')
    
    race_number = RaceNumber.find(:first, :conditions => ['discipline_id=? and year=? and person_id=?', Discipline[:mountain_bike].id, 2007, knowlsons.first.id])
    assert_not_nil(race_number, 'MTB number')
    assert_equal(2007, race_number.year, 'MTB number year')
    assert_equal('BBB9', race_number.value, 'MTB number value')
    assert_equal(Discipline[:mountain_bike], race_number.discipline, 'MTB number discipline')
    assert_equal(number_issuers(:association), race_number.number_issuer, 'MTB number issuer')

    assert_equal_dates('2004-02-16', knowlsons.first.member_from, 'member_from after update')
    assert_equal_dates('2004-12-31', knowlsons.first.member_to, 'member_to after update')
  end
  
  def test_create_with_duplicate_road_number
    assert_equal([], Person.find_all_by_name('Jon Knowlson'), 'Knowlson should not be in database')
    
    post(:create, {
      "person"=>{"work_phone"=>"", "date_of_birth(2i)"=>"", "occupation"=>"", "city"=>"Brussels", "cell_fax"=>"", "zip"=>"", 
        "member_from(1i)"=>"2004", "member_from(2i)"=>"2", "member_from(3i)"=>"16", 
        "member_to(1i)"=>"2004", "member_to(2i)"=>"12", "member_to(3i)"=>"31", 
        "date_of_birth(3i)"=>"", "mtb_category"=>"", "dh_category"=>"", "member"=>"1", "gender"=>"", "ccx_category"=>"", 
        "team_name"=>"", "road_category"=>"", "xc_number"=>"", "street"=>"", "track_category"=>"", "home_phone"=>"", "dh_number"=>"", 
        "road_number"=>"", "first_name"=>"Jon", "ccx_number"=>"", "last_name"=>"Knowlson", "date_of_birth(1i)"=>"", "email"=>"", "state"=>""}, 
      "number_issuer_id"=>["2", "2"], "number_value"=>["104", "BBB9"], "discipline_id"=>["4", "3"], :number_year => '2004',
      "commit"=>"Save"})
    
    assert_not_nil(assigns['person'], "Should assign person")
    assert(assigns['person'].errors.empty?, "Person should not have errors")
    
    knowlsons = Person.find(:all, :conditions => { :first_name => "Jon", :last_name => "Knowlson" })
    assert_equal(1, knowlsons.size, "Should have two Knowlsons")
    knowlsons.each do |knowlson|
      assert_equal(2, knowlson.race_numbers.size, 'Knowlson race numbers')
    end
  end
  
  def test_create_with_empty_password_and_no_numbers
    post :create,  :person => { :login => "", :password_confirmation => "", :password => "", :team_name => "", 
                                :first_name => "Henry", :last_name => "David", :license => "" }, :number_issuer_id => [ { "1" => nil } ]
    assert_not_nil assigns(:person), "@person"
    assert assigns(:person).errors.empty?, "Did no expect @person errors: #{assigns(:person).errors.full_messages}"
    assert_redirected_to edit_admin_person_path(assigns(:person))
  end
    
  def test_update
    molly = people(:molly)
    put(:update, {"commit"=>"Save", 
                   "number_year" => Date.today.year.to_s,
                   "number_issuer_id"=>number_issuers(:association).to_param, "number_value"=>[""], "discipline_id"=>disciplines(:cyclocross).to_param,
                   "number"=>{race_numbers(:molly_road_number).to_param=>{"value"=>"222"}},
                   "person"=>{
                     "member_from(1i)"=>"2004", "member_from(2i)"=>"2", "member_from(3i)"=>"16", 
                     "member_to(1i)"=>"2004", "member_to(2i)"=>"12", "member_to(3i)"=>"31", 
                     "print_card" => "1", "work_phone"=>"", "date_of_birth(2i)"=>"1", "occupation"=>"engineer", "city"=>"Wilsonville", 
                     "cell_fax"=>"", "zip"=>"97070", "date_of_birth(3i)"=>"1", "mtb_category"=>"Spt", "dh_category"=>"", 
                     "member"=>"1", "gender"=>"M", "notes"=>"rm", "ccx_category"=>"", "team_name"=>"", "road_category"=>"5", 
                     "xc_number"=>"1061", "street"=>"31153 SW Willamette Hwy W", "track_category"=>"", "home_phone"=>"503-582-8823", 
                     "dh_number"=>"917", "road_number"=>"4051", "first_name"=>"Paul", "ccx_number"=>"112", "last_name"=>"Formiller", 
                     "date_of_birth(1i)"=>"1969", "email"=>"paul.formiller@verizon.net", "state"=>"OR", "ccx_only" => "1",
                     "official" => "1"
                    }, 
                   "id"=>molly.to_param}
    )
    assert(flash.empty?, "Expected flash.empty? but was: #{flash[:warn]}")
    assert_redirected_to edit_admin_person_path(molly)
    molly.reload
    assert_equal('222', molly.road_number(true, Date.today.year), 'Road number should be updated')
    assert_equal(true, molly.print_card?, 'print_card?')
    assert_equal_dates('2004-02-16', molly.member_from, 'member_from after update')
    assert_equal_dates('2004-12-31', molly.member_to, 'member_to after update')
    assert_equal(true, molly.ccx_only?, 'ccx_only?')

    assert_equal 1, molly.versions.size, "versions"
    version = molly.versions.last
    admin = people(:administrator)
    assert_equal admin, version.user, "version user"
    changes = version.changes
    assert_equal 25, changes.size, "changes"
    change = changes["team_id"]
    assert_not_nil change, "Should have change for team ID"
    assert_equal teams(:vanilla).id, change.first, "Team ID before"
    assert_equal nil, change.last, "Team ID after"
    assert_equal "Candi Murray", molly.last_updated_by, "last_updated_by"
    # VestalVersions convention
    assert_nil molly.updated_by, "updated_by"
  end
  
  def test_update_bad_member_from_date
    person = people(:weaver)
    put(:update, "commit"=>"Save", "person"=>{
                 "member_from(1i)"=>"","member_from(2i)"=>"10", "member_from(3i)"=>"19",  
                 "member_to(3i)"=>"31", "date_of_birth(2i)"=>"1", "city"=>"Hood River", 
                 "work_phone"=>"541-387-8883 x 213", "occupation"=>"Sales Territory Manager", "cell_fax"=>"541-387-8884",
                 "date_of_birth(3i)"=>"1", "zip"=>"97031", "license"=>"583", "mtb_category"=>"Beg",
                 "dh_category"=>"Beg", "notes"=>"interests: 6\r\nr\r\ninterests: 4\r\nr\r\ninterests: 4\r\n", "gender"=>"M", 
                 "ccx_category"=>"B", "team_name"=>"River City Specialized", "print_card"=>"1", 
                 "street"=>"3541 Avalon Drive", "home_phone"=>"503-367-5193", "road_category"=>"3", 
                 "track_category"=>"5", "first_name"=>"Karsten", "last_name"=>"Hagen", 
                 "member_to(1i)"=>"2008", "member_to(2i)"=>"12", "email"=>"khagen69@hotmail.com", "date_of_birth(1i)"=>"1969",  
                 "state"=>"OR"}, "number"=>{"30532"=>{"value"=>"1453"}, "30533"=>{"value"=>"373"}}, "id"=>person.to_param, 
                 "number_year"=>"2008"
    )
    assert_not_nil(assigns(:person), "@person")
    assert(assigns(:person).errors.empty?, "Should have errors")
    assert(!assigns(:person).errors.on(:member_from), "Should have errors on 'member_from'")
    assert_redirected_to edit_admin_person_path(assigns(:person))
  end

  def test_update_new_number
    molly = people(:molly)
    put(:update, {"commit"=>"Save", 
                   "number_year" => Date.today.year.to_s,
                   "number_issuer_id"=>[number_issuers(:association).to_param], "number_value"=>["AZY"], 
                   "discipline_id" => [disciplines(:mountain_bike).id.to_s],
                   "number"=>{race_numbers(:molly_road_number).to_param =>{"value"=>"202"}},
                   "person"=>{"work_phone"=>"", "date_of_birth(2i)"=>"1", "occupation"=>"engineer", "city"=>"Wilsonville", 
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
    assert_redirected_to edit_admin_person_path(molly)
    assert(flash.empty?, 'flash empty?')
    molly.reload
    assert_equal('202', molly.road_number(true, Date.today.year), 'Road number should not be updated')
    assert_equal('AZY', molly.xc_number(true, Date.today.year), 'MTB number should be updated')
    assert_nil(molly.member_from, 'member_from after update')
    assert_nil(molly.member_to, 'member_to after update')
    assert_nil(RaceNumber.find(race_numbers(:molly_road_number).to_param ).updated_by, "updated_by")
    assert_equal("Candi Murray", RaceNumber.find_by_value("AZY").updated_by, "updated_by")
  end

  def test_number_year_changed
    person = people(:molly)

    post(:number_year_changed, 
         :id => person.to_param.to_s,
         :year => '2010'
    )
    assert_response(:success)
    assert_template("admin/people/_numbers")
    assert_not_nil(assigns["race_numbers"], "Should assign 'race_numbers'")
    assert_not_nil(assigns["year"], "Should assign today's year as 'year'")
    assert_equal('2010', assigns["year"], "Should assign selected year as 'year'")
    assert_not_nil(assigns["years"], "Should assign range of years as 'years'")
    assert(assigns["years"].size >= 2, "Should assign range of years as 'years', but was: #{assigns[:years]}")
  end
  
  def test_preview_import
    assert_recognizes({:controller => "admin/people", :action => "preview_import"}, {:path => "/admin/people/preview_import", :method => :post})

    people_before_import = Person.count

    file = fixture_file_upload("membership/55612_061202_151958.csv, attachment filename=55612_061202_151958.csv", "text/csv")
    post :preview_import, :people_file => file

    assert(!flash.has_key?(:warn), "flash[:warn] should be empty,  but was: #{flash[:warn]}")
    assert_response :success
    assert_template("admin/people/preview_import")
    assert_not_nil(assigns["people_file"], "Should assign 'people_file'")
    assert(session[:people_file_path].include?('55612_061202_151958.csv, attachment filename=55612_061202_151958.csv'), 
      'Should store temp file path in session as :people_file_path')
    
    assert_equal(people_before_import, Person.count, 'Should not have added people')
  end
  
  def test_preview_import_with_no_file
    post(:preview_import, :commit => 'Import', :people_file => "")
  
    assert(flash.has_key?(:warn), "should have flash[:warn]")
    assert_redirected_to admin_people_path
  end
  
  def test_import
    existing_duplicate = Duplicate.new(:new_attributes => Person.new(:name => 'Erik Tonkin'))
    existing_duplicate.people << people(:tonkin)
    existing_duplicate.save!
    assert_recognizes({:controller => "admin/people", :action => "import"}, {:path => "/admin/people/import", :method => :post})
    people_before_import = Person.count
  
    file = fixture_file_upload("membership/55612_061202_151958.csv, attachment filename=55612_061202_151958.csv", "text/csv")
    @request.session[:people_file_path] = File.expand_path("#{RAILS_ROOT}/test/fixtures/membership/55612_061202_151958.csv, attachment filename=55612_061202_151958.csv")
    post(:import, :commit => 'Import', :update_membership => 'true')
  
    assert(!flash.has_key?(:warn), "flash[:warn] should be empty, but was: #{flash[:warn]}")
    assert(flash.has_key?(:notice), "flash[:notice] should not be empty")
    assert_nil(session[:duplicates], 'session[:duplicates]')
    assert_redirected_to admin_people_path
    
    assert_nil(session[:people_file_path], 'Should remove temp file path from session')
    assert(people_before_import < Person.count, 'Should have added people')
    assert_equal(0, Duplicate.count, 'Should have no duplicates')
  end
  
  def test_import_next_year
    existing_duplicate = Duplicate.new(:new_attributes => Person.new(:name => 'Erik Tonkin'))
    existing_duplicate.people << people(:tonkin)
    existing_duplicate.save!
    assert_recognizes({:controller => "admin/people", :action => "import"}, {:path => "/admin/people/import", :method => :post})
    people_before_import = Person.count
  
    file = fixture_file_upload("membership/database.xls", "application/vnd.ms-excel", :binary)
    @request.session[:people_file_path] = File.expand_path("#{RAILS_ROOT}/test/fixtures/membership/database.xls")
    next_year = Date.today.year + 1
    post(:import, :commit => 'Import', :update_membership => 'true', :year => next_year)
  
    assert(!flash.has_key?(:warn), "flash[:warn] should be empty, but was: #{flash[:warn]}")
    assert(flash.has_key?(:notice), "flash[:notice] should not be empty")
    assert_nil(session[:duplicates], 'session[:duplicates]')
    assert_redirected_to admin_people_path
    
    assert_nil(session[:people_file_path], 'Should remove temp file path from session')
    assert(people_before_import < Person.count, 'Should have added people')
    assert_equal(0, Duplicate.count, 'Should have no duplicates')
    
    rene = Person.find_by_name('Rene Babi')
    assert_not_nil(rene, 'Rene Babi should have been imported and created')
    road_number = rene.race_numbers.detect {|n| n.year == next_year && n.discipline == Discipline['road']}
    assert_not_nil(road_number, "Rene should have road number for #{next_year}")

    assert(rene.member?(Date.today), 'Should be a member for this year')
    assert(rene.member?(Date.new(next_year - 1, 12, 31)), 'Should be a member for this year')
    assert(rene.member?(Date.new(next_year, 1, 1)), 'Should be a member for next year')

    heidi = Person.find_by_name('Heidi Babi')
    assert_not_nil(heidi, 'Heidi Babi should have been imported and created')
    assert(heidi.member?(Date.today), 'Should be a member for this year')
    assert(heidi.member?(Date.new(next_year - 1, 12, 31)), 'Should be a member for this year')
    assert(heidi.member?(Date.new(next_year, 1, 1)), 'Should be a member for next year')
  end
  
  def test_import_with_duplicates
    Person.create(:name => 'Erik Tonkin')
    people_before_import = Person.count
  
    file = fixture_file_upload("membership/duplicates.xls", "application/vnd.ms-excel", :binary)
    @request.session[:people_file_path] = File.expand_path("#{RAILS_ROOT}/test/fixtures/membership/duplicates.xls")
    post(:import, :commit => 'Import', :update_membership => 'true')
  
    assert(flash.has_key?(:warn), "flash[:warn] should not be empty")
    assert(flash.has_key?(:notice), "flash[:notice] should not be empty")
    assert_equal(1, Duplicate.count, 'Should have duplicates')
    assert_redirected_to duplicates_admin_people_path
    
    assert_nil(session[:people_file_path], 'Should remove temp file path from session')
    assert(people_before_import < Person.count, 'Should have added people')
  end
  
  def test_import_with_no_file
    post(:import, :commit => 'Import', :update_membership => 'true')
  
    assert(flash.has_key?(:warn), "should have flash[:warn]")
    assert_redirected_to admin_people_path
  end
  
  def test_duplicates
    @request.session[:duplicates] = []
    get(:duplicates)
    assert_response(:success)
    assert_template("admin/people/duplicates")
  end
  
  def test_resolve_duplicates
    Person.create!(:name => 'Erik Tonkin')
    weaver_2 = Person.create!(:name => 'Ryan Weaver', :city => 'Kenton')
    weaver_3 = Person.create!(:name => 'Ryan Weaver', :city => 'Lake Oswego')
    alice_2 = Person.create!(:name => 'Alice Pennington', :road_category => '3')
    people_before_import = Person.count
  
    tonkin_dupe = Duplicate.create!(:new_attributes => {:name => 'Erik Tonkin'}, :people => Person.find(:all, :conditions => ['last_name = ?', 'Tonkin']))
    ryan_dupe = Duplicate.create!(:new_attributes => {:name => 'Ryan Weaver', :city => 'Las Vegas'}, :people => Person.find(:all, :conditions => ['last_name = ?', 'Weaver']))
    alice_dupe = Duplicate.create!(:new_attributes => {:name => 'Alice Pennington', :road_category => '2'}, :people => Person.find(:all, :conditions => ['last_name = ?', 'Pennington']))
    post(:resolve_duplicates, {tonkin_dupe.to_param => 'new', ryan_dupe.to_param => weaver_3.to_param, alice_dupe.to_param => alice_2.to_param})
    assert_redirected_to admin_people_path
    assert_equal(0, Duplicate.count, 'Should have no duplicates')
    
    assert_equal(3, Person.find(:all, :conditions => ['last_name = ?', 'Tonkin']).size, 'Tonkins in database')
    assert_equal(3, Person.find(:all, :conditions => ['last_name = ?', 'Weaver']).size, 'Weaver in database')
    assert_equal(2, Person.find(:all, :conditions => ['last_name = ?', 'Pennington']).size, 'Pennington in database')
    
    weaver_3.reload
    assert_equal('Las Vegas', weaver_3.city, 'Weaver city')
    
    alice_2.reload
    assert_equal('2', alice_2.road_category, 'Alice category')
  end
  
  def test_cancel_import
    post(:import, :commit => 'Cancel', :update_membership => 'false')
    assert_redirected_to admin_people_path
    assert_nil(session[:people_file_path], 'Should remove temp file path from session')
  end
  
  def test_one_print_card
    tonkin = people(:tonkin)

    get(:card, :format => "pdf", :id => tonkin.to_param)

    assert_response(:success)
    assert_equal(tonkin, assigns['person'], 'Should assign person')
    tonkin.reload
    assert(!tonkin.print_card?, 'Tonkin.print_card? after printing')
  end
  
  def test_print_no_cards_pending
    get(:cards, :format => "pdf")
    assert_redirected_to(no_cards_admin_people_path(:format => "html"))
  end
  
  def test_no_cards
    get(:no_cards)
    assert_response(:success)
    assert_template("admin/people/no_cards")
    assert_layout("admin/application")
  end
  
  def test_print_cards
    tonkin = people(:tonkin)
    tonkin.print_card = true
    tonkin.save!
    assert !tonkin.membership_card?, "Tonkin.membership_card? before printing"

    get(:cards, :format => "pdf")

    assert_response(:success)
    assert_template("admin/people/cards")
    assert_layout(nil)
    assert_equal(1, assigns['people'].size, 'Should assign people')
    tonkin.reload
    assert(!tonkin.print_card?, 'Tonkin.print_card? after printing')
    assert tonkin.membership_card?, "Tonkin.has_card? after printing"
  end
  
  def test_many_print_cards
    people = []
    for i in 1..4
      people << Person.create!(:first_name => 'First Name', :last_name => "Last #{i}", :print_card => true)
    end

    get(:cards, :format => "pdf")

    assert_response(:success)
    assert_template("admin/people/cards")
    assert_layout(nil)
    assert_equal(4, assigns['people'].size, 'Should assign people')
    for person in people
      person.reload
      assert(!person.print_card?, 'Person.print_card? after printing')
      assert person.membership_card?, "person.membership_card? after printing"
    end
  end

  def test_export_to_excel
    tonkin = people(:tonkin)
    tonkin.singlespeed_number = "409"
    tonkin.track_number = "765"
    tonkin.save!
    
    RaceNumber.create!(:person => tonkin, :discipline => Discipline[:singlespeed], :value => "410")

    weaver = people(:weaver)
    RaceNumber.create!(:person => weaver, :discipline => Discipline[:road], :value => "888")
    RaceNumber.create!(:person => weaver, :discipline => Discipline[:road], :value => "999")
    assert_equal(4, weaver.race_numbers(true).size, "Weaver numbers")
    
    get(:index, :format => 'xls', :include => 'all')

    assert_response(:success)
    today = RacingAssociation.current.effective_today
    assert_equal("filename=\"people_#{today.year}_#{today.month}_#{today.day}.xls\"", @response.headers['Content-Disposition'], 'Should set disposition')
    assert_equal('application/vnd.ms-excel; charset=utf-8', @response.headers["Content-Type"], 'Should set content to Excel')
    assert_not_nil(@response.headers['Content-Length'], 'Should set content length')
    assert_equal(11, assigns['people'].size, "People export size")
    expected_body = %Q{license	first_name	last_name	team_name	member_from	member_to	ccx_only	print_card	card_printed_at	membership_card	date_of_birth	occupation	street	city	state	zip	wants_mail	email	wants_email	home_phone	work_phone	cell_fax	gender	road_category	track_category	ccx_category	mtb_category	dh_category	ccx_number	dh_number	road_number	singlespeed_number	track_number	xc_number	notes	volunteer_interest	official_interest	race_promotion_interest	team_interest	created_at	updated_at
						0	0		0							0	sixhobsons@comcast.net	0	(503) 223-3343																0	0	0	0	01/13/2010  	01/13/2010
	Molly	Cameron	Vanilla	01/01/1999	12/31/2010	0	0		0							0		0				F								202					0	0	0	0	01/13/2010  	01/13/2010
576	Kevin	Condron	Gentle Lovers	01/01/2000	12/31/2009	0	0		0							0	kc@example.com	0																	0	0	0	0	01/13/2010  	01/13/2010
	Bob	Jones		01/01/2009	12/31/2009	0	0		0							0	member@example.com	0																	0	0	0	0	01/13/2010  	01/13/2010
576	Mark	Matson	Kona	01/01/1999	12/31/2010	0	0		0							0	mcfatson@gentlelovers.com	0				M								340					0	0	0	0	01/13/2010  	01/13/2010
	Candi	Murray				0	0		0							0	admin@example.com	0	(503) 555-1212																0	0	0	0	01/13/2010  	01/13/2010
	Alice	Pennington	Gentle Lovers	01/01/1999	12/31/2010	0	0		0							0		0				F								230					0	0	0	0	01/13/2010  	01/13/2010
	Non	Results				0	0		0							0		0																	0	0	0	0	01/13/2010  	01/13/2010
	Brad	Ross				0	0		0							0		0																	0	0	0	0	01/13/2010  	01/13/2010
7123811	Erik	Tonkin	Kona	01/01/1999	12/31/2010	0	0		0	01/01/1980		127 SE Lambert	Portland	OR	19990	0		0	415 221-3773			M	1	5						102	409				0	0	0	0	01/13/2010  	01/13/2010
	Ryan	Weaver	Gentle Lovers	01/01/1999	12/31/2010	0	0		0							0	hotwheels@yahoo.com	0				M								341			437		0	0	0	0	01/13/2010  	01/13/2010
}
    # assert_equal expected_body, @response.body, "Excel contents"
  end
  
  def test_export_to_excel_with_date
    get(:index, :format => 'xls', :include => 'all', :date => "2008-12-31")

    assert_response(:success)
    today = Date.today
    assert_equal("filename=\"people_2008_12_31.xls\"", @response.headers['Content-Disposition'], 'Should set disposition')
    assert_equal('application/vnd.ms-excel; charset=utf-8', @response.headers["Content-Type"], 'Should set content to Excel')
    assert_not_nil(@response.headers['Content-Length'], 'Should set content length')
    assert_equal(11, assigns['people'].size, "People export size")
  end

  def test_export_members_only_to_excel
    get(:index, :format => 'xls', :include => 'members_only')

    assert_response(:success)
    today = RacingAssociation.current.effective_today
    assert_equal("filename=\"people_#{today.year}_#{today.month}_#{today.day}.xls\"", @response.headers['Content-Disposition'], 'Should set disposition')
    assert_equal('application/vnd.ms-excel; charset=utf-8', @response.headers['Content-Type'], 'Should set content to Excel')
    assert_not_nil(@response.headers['Content-Length'], 'Should set content length')
  end

  def test_export_members_only_to_excel_promoter
    destroy_person_session
    PersonSession.create(people(:promoter))
    
    get(:index, :format => 'xls', :include => 'members_only', :excel_layout => "scoring_sheet")

    assert_response(:success)
    today = RacingAssociation.current.effective_today
    assert_equal("filename=\"scoring_sheet.xls\"", @response.headers['Content-Disposition'], 'Should set disposition')
    assert_equal('application/vnd.ms-excel; charset=utf-8', @response.headers['Content-Type'], 'Should set content to Excel')
    assert_not_nil(@response.headers['Content-Length'], 'Should set content length')
  end
  
  def test_export_to_finish_lynx
    opts = {
      :controller => "admin/people", 
      :action => "index",
      :format => 'ppl'
    }
    assert_routing("/admin/people.ppl", opts)
    get(:index, :format => 'ppl', :include => 'all')

    assert_response(:success)
    assert_equal("filename=\"lynx.ppl\"", @response.headers['Content-Disposition'], 'Should set disposition')
    assert_equal('application/vnd.ms-excel; charset=utf-8', @response.headers['Content-Type'], 'Should set content to Excel')
    assert_not_nil(@response.headers['Content-Length'], 'Should set content length')
  end
  
  def test_export_members_only_to_finish_lynx
    get(:index, :format => 'ppl', :include => 'members_only')

    assert_response(:success)
    assert_equal("filename=\"lynx.ppl\"", @response.headers['Content-Disposition'], 'Should set disposition')
    assert_equal('application/vnd.ms-excel; charset=utf-8', @response.headers['Content-Type'], 'Should set content to Excel')
    assert_not_nil(@response.headers['Content-Length'], 'Should set content length')
  end
  
  def test_export_members_only_to_scoring_sheet
    get(:index, :format => 'xls', :include => 'members_only', :excel_layout => 'scoring_sheet')

    assert_response(:success)
    assert_equal("filename=\"scoring_sheet.xls\"", @response.headers['Content-Disposition'], 'Should set disposition')
    assert_equal('application/vnd.ms-excel; charset=utf-8', @response.headers['Content-Type'], 'Should set content to Excel')
    assert_not_nil(@response.headers['Content-Length'], 'Should set content length')
  end
  
  def test_export_print_cards_to_endicia
    get(:index, :format => "xls", :include => "print_cards", :excel_layout => "endicia")

    assert_response(:success)
    assert_equal("filename=\"print_cards.xls\"", @response.headers['Content-Disposition'], 'Should set disposition')
    assert_equal('application/vnd.ms-excel; charset=utf-8', @response.headers['Content-Type'], 'Should set content to Excel')
    assert_not_nil(@response.headers['Content-Length'], 'Should set content length')
  end
  
  # From PeopleController
  def test_edit_with_event
    kings_valley = events(:kings_valley)
    get(:edit, :id => people(:promoter).to_param, :event_id => kings_valley.to_param.to_s)
    assert_equal(people(:promoter), assigns['person'], "Should assign 'person'")
    assert_equal(kings_valley, assigns['event'], "Should Kings Valley assign 'event'")
    assert_template("admin/people/edit")
  end

  def test_new_with_event
    kings_valley = events(:kings_valley)
    get(:new, :event_id => kings_valley.to_param)
    assert_not_nil(assigns['person'], "Should assign 'person'")
    assert(assigns['person'].new_record?, 'Promoter should be new record')
    assert_equal(kings_valley, assigns['event'], "Should Kings Valley assign 'event'")
    assert_template("admin/people/edit")
  end
  
  def test_save_new_single_day_existing_promoter_different_info_overwrite
    candi_murray = people(:administrator)
    new_email = "scout@scout-promotions.net"
    new_phone = "123123"

    put(:update, :id => candi_murray.id, 
      "person" => {"name" => candi_murray.name, "home_phone" => new_phone, "email" => new_email}, "commit" => "Save")
    
    assert_nil(flash['warn'], "Should not have flash['warn'], but has: #{flash['warn']}")
    assert_not_nil(assigns["person"], "@person")
    assert(assigns["person"].errors.empty?, assigns["person"].errors.full_messages.join)

    assert_redirected_to(edit_admin_person_path(candi_murray))
    
    candi_murray.reload
    assert_equal(candi_murray.name, candi_murray.name, 'promoter old name')
    assert_equal(new_phone, candi_murray.home_phone, 'promoter new home_phone')
    assert_equal(new_email, candi_murray.email, 'promoter new email')
  end
  
  def test_save_new_single_day_existing_promoter_no_name
    nate_hobson = people(:nate_hobson)
    old_name = nate_hobson.name
    old_email = nate_hobson.email
    old_phone = nate_hobson.home_phone

    put(:update, :id => nate_hobson.id, 
      "person" => {"name" => '', "home_phone" => old_phone, "email" => old_email}, "commit" => "Save")
    
    assert_nil(flash['warn'], "Should not have flash['warn'], but has: #{flash['warn']}")
    
    nate_hobson.reload
    assert_equal('', nate_hobson.name, 'promoter name')
    assert_equal(old_phone, nate_hobson.home_phone, 'promoter old phone')
    assert_equal(old_email, nate_hobson.email, 'promoter old email')
    
    assert_redirected_to(edit_admin_person_path(nate_hobson))
  end
  
  def test_remember_event_id_on_update
    promoter = people(:promoter)

    put(:update, :id => promoter.id, 
      "person" => {"name" => "Fred Whatley", "home_phone" => "(510) 410-2201", "email" => "fred@whatley.net"}, 
      "commit" => "Save",
      "event_id" => events(:jack_frost).id)
    
    assert_nil(flash['warn'], "Should not have flash['warn'], but has: #{flash['warn']}")
    
    promoter.reload
    
    assert_redirected_to(edit_admin_person_path(promoter, :event_id => events(:jack_frost)))
  end
  
  def test_remember_event_id_on_create
    post(:create, "person" => {"name" => "Fred Whatley", "home_phone" => "(510) 410-2201", "email" => "fred@whatley.net"}, 
    "commit" => "Save",
    "event_id" => events(:jack_frost).id)
    
    assert_nil(flash['warn'], "Should not have flash['warn'], but has: #{flash['warn']}")
    
    promoter = Person.find_by_name('Fred Whatley')
    assert_redirected_to(edit_admin_person_path(promoter, :event_id => events(:jack_frost)))
  end
end
