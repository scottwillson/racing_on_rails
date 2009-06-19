require "test_helper"

class Admin::PeopleControllerTest < ActionController::TestCase
  setup :create_administrator_session

  def test_not_logged_in_index
    destroy_user_session
    get(:index)
    assert_response(:redirect)
    assert_redirected_to(new_user_session_path)
    assert_nil(@request.session["user"], "No user in session")
  end
  
  def test_not_logged_in_edit
    destroy_user_session
    weaver = people(:weaver)
    get(:edit_name, :id => weaver.to_param)
    assert_response(:redirect)
    assert_redirected_to(new_user_session_path)
    assert_nil(@request.session["user"], "No user in session")
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
    for i in 0..Admin::PeopleController::RESULTS_LIMIT
      Person.create(:name => "Test Person #{i}")
    end
    get(:index, :name => 'Test')
    assert_response(:success)
    assert_template("admin/people/index")
    assert_not_nil(assigns["people"], "Should assign people")
    assert_equal(Admin::PeopleController::RESULTS_LIMIT, assigns['people'].size, "Search for '' should find all people")
    assert_not_nil(assigns["name"], "Should assign name")
    assert(!flash.empty?, 'flash not empty?')
    assert_equal('Test', assigns['name'], "'name' assigns")
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
    assert_response(:redirect)
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
    
    opts = {:controller => "admin/people", :action => "destroy_number", :id => race_number.to_param}
    assert_routing("/admin/people/destroy_number/#{race_number.to_param}", opts)

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
    assert(Person.find_all_by_name('Erik Tonkin'), 'Tonkin should be in database')

    get(:merge, :id => tonkin.to_param, :target_id => molly.id)
    assert_response(:success)
    assert_template("admin/people/merge")

    assert(Person.find_all_by_name('Molly Cameron'), 'Molly should be in database')
    assert_equal([], Person.find_all_by_name('Erik Tonkin'), 'Tonkin should not be in database')
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
    opts = {:controller => "admin/people", :action => "new"}
    assert_routing("/admin/people/new", opts)
  
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
    
    if assigns['person']
      assert(assigns['person'].errors.empty?, assigns['person'].errors.full_messages)
    end
    
    assert(flash.empty?, "Flash should be empty, but was: #{flash}")
    assert_response(:redirect)
    knowlsons = Person.find_all_by_name('Jon Knowlson')
    assert(!knowlsons.empty?, 'Knowlson should be created')
    assert_redirected_to(edit_admin_person_path(knowlsons.first))
    assert_nil(knowlsons.first.member_from, 'member_from after update')
    assert_nil(knowlsons.first.member_to, 'member_to after update')
    assert_equal(users(:administrator), knowlsons.first.created_by, "created by")
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
        "discipline_id"=>[disciplines(:road).id, disciplines(:mountain_bike).id], :number_year => '2007',
      "commit"=>"Save"})
    
    if assigns['person']
      assert(assigns['person'].errors.empty?, assigns['person'].errors.full_messages)
    end
    
    assert(flash.empty?, "flash empty? #{flash}")
    knowlsons = Person.find_all_by_name('Jon Knowlson')
    assert(!knowlsons.empty?, 'Knowlson should be created')
    assert_response(:redirect)
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
    
    assert_response(:redirect)
    assert_not_nil(assigns['person'], "Should assign person")
    assert(assigns['person'].errors.empty?, "Person should not have errors")
    
    knowlsons = Person.find(:all, :conditions => { :first_name => "Jon", :last_name => "Knowlson" })
    assert_equal(1, knowlsons.size, "Should have two Knowlsons")
    knowlsons.each do |knowlson|
      assert_equal(2, knowlson.race_numbers.size, 'Knowlson race numbers')
    end
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
                     "dh_number"=>"917", "road_number"=>"2051", "first_name"=>"Paul", "ccx_number"=>"112", "last_name"=>"Formiller", 
                     "date_of_birth(1i)"=>"1969", "email"=>"paul.formiller@verizon.net", "state"=>"OR", "ccx_only" => "1"
                    }, 
                   "id"=>molly.to_param}
    )
    assert(flash.empty?, "Expected flash.empty? but was: #{flash[:warn]}")
    assert_response(:redirect)
    molly.reload
    assert_equal('222', molly.road_number(true, Date.today.year), 'Road number should be updated')
    assert_equal(true, molly.print_card?, 'print_card?')
    assert_equal_dates('2004-02-16', molly.member_from, 'member_from after update')
    assert_equal_dates('2004-12-31', molly.member_to, 'member_to after update')
    assert_equal(true, molly.ccx_only?, 'ccx_only?')
  end
  
  def test_update_bad_member_from_date
    person = people(:weaver)
    put(:update, "commit"=>"Save", "person"=>{
                 "member_from(1i)"=>"","member_from(2i)"=>"10", "member_from(3i)"=>"19",  
                 "member_to(3i)"=>"31", "date_of_birth(2i)"=>"1", "city"=>"Hood River", 
                 "work_phone"=>"541-387-8883 x 213", "occupation"=>"Sales Territory Manager", "cell_fax"=>"541-387-8884",
                 "date_of_birth(3i)"=>"1", "zip"=>"97031", "license"=>"583", "mtb_category"=>"Beg", "print_mailing_label"=>"1", 
                 "dh_category"=>"Beg", "notes"=>"interests: 6\r\nr\r\ninterests: 4\r\nr\r\ninterests: 4\r\n", "gender"=>"M", 
                 "ccx_category"=>"B", "team_name"=>"River City Specialized", "print_card"=>"1", 
                 "street"=>"3541 Avalon Drive", "home_phone"=>"503-367-5193", "road_category"=>"3", 
                 "track_category"=>"5", "first_name"=>"Karsten", "last_name"=>"Hagen", 
                 "member_to(1i)"=>"2008", "member_to(2i)"=>"12", "email"=>"khagen69@hotmail.com", "date_of_birth(1i)"=>"1969",  
                 "state"=>"OR"}, "number"=>{"30532"=>{"value"=>"1453"}, "30533"=>{"value"=>"373"}}, "id"=>person.to_param, 
                 "number_year"=>"2008"
    )
    assert_not_nil(assigns(:person), "@person")
    assert(!assigns(:person).errors.empty?, "Should have errors")
    assert(assigns(:person).errors.on(:member_from), "Should have errors on 'member_from'")
    assert(flash.empty?, "Expected flash.empty?")
    assert_response :success
  end

  def test_update_new_number
    molly = people(:molly)
    put(:update, {"commit"=>"Save", 
                   "number_year" => Date.today.year.to_s,
                   "number_issuer_id"=>[number_issuers(:association).to_param], "number_value"=>["AZY"], "discipline_id" => [disciplines(:mountain_bike).id],
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
    assert_response(:redirect)
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
    
    opts = {:controller => "admin/people", :action => "number_year_changed", :id => person.to_param.to_s}
    assert_routing("/admin/people/number_year_changed/#{person.to_param}", opts)

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
    assert_response(:redirect)
    assert_redirected_to(:action => 'index')
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
    assert_response(:redirect)
    assert_redirected_to(:action => 'index')
    
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
    assert_response(:redirect)
    assert_redirected_to(:action => 'index')
    
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
    assert_response(:redirect)
    assert_redirected_to(:action => 'duplicates')
    
    assert_nil(session[:people_file_path], 'Should remove temp file path from session')
    assert(people_before_import < Person.count, 'Should have added people')
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
    assert_response(:redirect)
    assert_redirected_to(:action => 'index')
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
    assert_response(:redirect)
    assert_redirected_to(:action => 'index')
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

    get(:cards, :format => "pdf")

    assert_response(:success)
    assert_template("admin/people/cards")
    assert_layout(nil)
    assert_equal(1, assigns['people'].size, 'Should assign people')
    tonkin.reload
    assert(!tonkin.print_card?, 'Tonkin.print_card? after printing')
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
    end
  end
  
  def test_print_no_mailing_labels_pending
    get(:mailing_labels, :format => "pdf")
    assert_redirected_to(no_mailing_labels_admin_people_path(:format => "html"))
  end
  
  def test_print_no_mailing_labels
    get(:no_mailing_labels)
    assert_response(:success)
    assert_template("admin/people/no_mailing_labels")
    assert_layout("admin/application")
  end
  
  def test_print_mailing_labels
    tonkin = people(:tonkin)
    tonkin.print_mailing_label = true
    tonkin.save!

    get(:mailing_labels, :format => "pdf")

    assert_response(:success)
    assert_template("admin/people/mailing_labels")
    assert_layout(nil)
    assert_equal(1, assigns['people'].size, 'Should assign people')
    tonkin.reload
    assert(!tonkin.print_mailing_label?, 'Tonkin.mailing_label? after printing')
  end

  def test_many_mailing_labels
    people = []
    for i in 1..31
      people << Person.create(:first_name => 'First Name', :last_name => "Last #{i}", :print_mailing_label => true)
    end

    get(:mailing_labels, :format => "pdf")

    assert_response(:success)
    assert_template("admin/people/mailing_labels")
    assert_equal(31, assigns['people'].size, 'Should assign people')
    for person in people
      person.reload
      assert(!person.print_mailing_label?, 'Person.print_mailing_label? after printing')
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
    today = Date.today
    assert_equal("filename=\"people_#{today.year}_#{today.month}_#{today.day}.xls\"", @response.headers['Content-Disposition'], 'Should set disposition')
    assert_equal('application/vnd.ms-excel; charset=utf-8', @response.headers["Content-Type"], 'Should set content to Excel')
    assert_not_nil(@response.headers['Content-Length'], 'Should set content length')
    assert_equal(6, assigns['people'].size, "People export size")
  end
  
  def test_export_to_excel_with_date
    get(:index, :format => 'xls', :include => 'all', :date => "12/31/2008")

    assert_response(:success)
    today = Date.today
    assert_equal("filename=\"people_2008_12_31.xls\"", @response.headers['Content-Disposition'], 'Should set disposition')
    assert_equal('application/vnd.ms-excel; charset=utf-8', @response.headers["Content-Type"], 'Should set content to Excel')
    assert_not_nil(@response.headers['Content-Length'], 'Should set content length')
    assert_equal(6, assigns['people'].size, "People export size")
  end

  def test_export_members_only_to_excel
    get(:index, :format => 'xls', :include => 'members_only')

    assert_response(:success)
    today = Date.today
    assert_equal("filename=\"people_#{today.year}_#{today.month}_#{today.day}.xls\"", @response.headers['Content-Disposition'], 'Should set disposition')
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
    today = Date.today
    assert_equal("filename=\"lynx.ppl\"", @response.headers['Content-Disposition'], 'Should set disposition')
    assert_equal('application/vnd.ms-excel; charset=utf-8', @response.headers['Content-Type'], 'Should set content to Excel')
    assert_not_nil(@response.headers['Content-Length'], 'Should set content length')
  end
  
  def test_export_members_only_to_finish_lynx
    get(:index, :format => 'ppl', :include => 'members_only')

    assert_response(:success)
    today = Date.today
    assert_equal("filename=\"lynx.ppl\"", @response.headers['Content-Disposition'], 'Should set disposition')
    assert_equal('application/vnd.ms-excel; charset=utf-8', @response.headers['Content-Type'], 'Should set content to Excel')
    assert_not_nil(@response.headers['Content-Length'], 'Should set content length')
  end
  
  def test_export_members_only_to_scoring_sheet
    get(:index, :format => 'xls', :include => 'members_only', :excel_layout => 'scoring_sheet')

    assert_response(:success)
    today = Date.today
    assert_equal("filename=\"scoring_sheet.xls\"", @response.headers['Content-Disposition'], 'Should set disposition')
    assert_equal('application/vnd.ms-excel; charset=utf-8', @response.headers['Content-Type'], 'Should set content to Excel')
    assert_not_nil(@response.headers['Content-Length'], 'Should set content length')
  end
  
  # From UsersController
  def test_index
    path = {:controller => "admin/users", :action => 'index'}
    assert_routing("/admin/users", path)
    assert_recognizes(path, "/admin/users/")

    get(:index)
    assert_equal(4, assigns['users'].size, "Should assign all promoters to 'users'")
    assert_template("admin/users/index")
  end
  
  def test_edit
    get(:edit, :id => users(:promoter).to_param)
    assert_equal(users(:promoter), assigns['user'], "Should assign 'user'")
    assert_nil(assigns['event'], "Should not assign 'event'")
    assert_template("admin/users/edit")
  end

  def test_edit_with_event
    kings_valley = events(:kings_valley)
    get(:edit, :id => users(:promoter).to_param, :event_id => kings_valley.to_param.to_s)
    assert_equal(users(:promoter), assigns['user'], "Should assign 'user'")
    assert_equal(kings_valley, assigns['event'], "Should Kings Valley assign 'event'")
    assert_template("admin/users/edit")
  end
  
  def test_new
    path = {:controller => "admin/users", :action => 'new'}
    assert_routing("/admin/users/new", path)
    
    get(:new)
    assert_not_nil(assigns['user'], "Should assign 'user'")
    assert(assigns['user'].new_record?, 'Promoter should be new record')
    assert_template("admin/users/edit")
  end

  def test_new_with_event
    kings_valley = events(:kings_valley)
    get(:new, :event_id => kings_valley.to_param)
    assert_not_nil(assigns['user'], "Should assign 'user'")
    assert(assigns['user'].new_record?, 'Promoter should be new record')
    assert_equal(kings_valley, assigns['event'], "Should Kings Valley assign 'event'")
    assert_template("admin/users/edit")
  end
  
  def test_create
    assert_nil(User.find_by_name("Fred Whatley"), 'Fred Whatley should not be in database')
    post(:create, "user" => {"name" => "Fred Whatley", "phone" => "(510) 410-2201", "email" => "fred@whatley.net"}, "commit" => "Save")
    
    assert_nil(flash['warn'], "Should not have flash['warn'], but has: #{flash['warn']}")
    
    promoter = User.find_by_name("Fred Whatley")
    assert_not_nil(promoter, 'New promoter should be database')
    assert_equal('Fred Whatley', promoter.name, 'new promoter name')
    assert_equal('(510) 410-2201', promoter.phone, 'new promoter name')
    assert_equal('fred@whatley.net', promoter.email, 'new promoter email')
    
    assert_response(:redirect)
    assert_redirected_to(edit_admin_user_path(promoter))
  end
  
  def test_update
    promoter = users(:promoter)
    
    assert_not_equal('Fred Whatley', promoter.name, 'existing promoter name')
    assert_not_equal('(510) 410-2201', promoter.phone, 'existing promoter name')
    assert_not_equal('fred@whatley.net', promoter.email, 'existing promoter email')

    put(:update, :id => promoter.id, 
      "user" => {"name" => "Fred Whatley", "phone" => "(510) 410-2201", "email" => "fred@whatley.net"}, "commit" => "Save")
    
    assert_nil(flash['warn'], "Should not have flash['warn'], but has: #{flash['warn']}")
    
    promoter.reload
    assert_equal('Fred Whatley', promoter.name, 'new promoter name')
    assert_equal('(510) 410-2201', promoter.phone, 'new promoter phone')
    assert_equal('fred@whatley.net', promoter.email, 'new promoter email')
    
    assert_response(:redirect)
    assert_redirected_to(edit_admin_user_path(promoter))
  end

  def test_save_new_single_day_existing_promoter_different_info_overwrite
    candi_murray = users(:administrator)
    new_email = "scout@scout-promotions.net"
    new_phone = "123123"

    put(:update, :id => candi_murray.id, 
      "user" => {"name" => candi_murray.name, "phone" => new_phone, "email" => new_email}, "commit" => "Save")
    
    assert_nil(flash['warn'], "Should not have flash['warn'], but has: #{flash['warn']}")
    assert_not_nil(assigns["user"], "@user")
    assert(assigns["user"].errors.empty?, assigns["user"].errors.full_messages)

    assert_response(:redirect)
    assert_redirected_to(edit_admin_user_path(candi_murray))
    
    candi_murray.reload
    assert_equal(candi_murray.name, candi_murray.name, 'promoter old name')
    assert_equal(new_phone, candi_murray.phone, 'promoter new phone')
    assert_equal(new_email, candi_murray.email, 'promoter new email')
  end
  
  def test_save_new_single_day_existing_promoter_no_name
    nate_hobson = users(:nate_hobson)
    old_name = nate_hobson.name
    old_email = nate_hobson.email
    old_phone = nate_hobson.phone

    put(:update, :id => nate_hobson.id, 
      "user" => {"name" => '', "phone" => old_phone, "email" => old_email}, "commit" => "Save")
    
    assert_nil(flash['warn'], "Should not have flash['warn'], but has: #{flash['warn']}")
    
    nate_hobson.reload
    assert_equal('', nate_hobson.name, 'promoter name')
    assert_equal(old_phone, nate_hobson.phone, 'promoter old phone')
    assert_equal(old_email, nate_hobson.email, 'promoter old email')
    
    assert_response(:redirect)
    assert_redirected_to(edit_admin_user_path(nate_hobson))
  end
  
  def test_remember_event_id_on_update
    promoter = users(:promoter)

    put(:update, :id => promoter.id, 
      "user" => {"name" => "Fred Whatley", "phone" => "(510) 410-2201", "email" => "fred@whatley.net"}, 
      "commit" => "Save",
      "event_id" => events(:jack_frost).id)
    
    assert_nil(flash['warn'], "Should not have flash['warn'], but has: #{flash['warn']}")
    
    promoter.reload
    
    assert_response(:redirect)
    assert_redirected_to(edit_admin_event_user_path(promoter, events(:jack_frost)))
  end
  
  def test_remember_event_id_on_create
    post(:create, "user" => {"name" => "Fred Whatley", "phone" => "(510) 410-2201", "email" => "fred@whatley.net"}, 
    "commit" => "Save",
    "event_id" => events(:jack_frost).id)
    
    assert_nil(flash['warn'], "Should not have flash['warn'], but has: #{flash['warn']}")
    
    promoter = User.find_by_name('Fred Whatley')
    assert_response(:redirect)
    assert_redirected_to(edit_admin_event_user_path(promoter, events(:jack_frost)))
  end
end
