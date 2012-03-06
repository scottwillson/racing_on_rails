# coding: utf-8

require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class PeopleControllerTest < ActionController::TestCase
  def test_edit
    member = FactoryGirl.create(:person_with_login)
    use_ssl
    login_as member
    get :edit, :id => member.to_param
    assert_response :success
    assert_equal member, assigns(:person), "@person"
    assert_select ".tabs", :count => 0
  end

  def test_edit_promoter
    promoter = FactoryGirl.create(:promoter)
    use_ssl
    login_as promoter
    get :edit, :id => promoter.to_param
    assert_response :success
    assert_equal promoter, assigns(:person), "@person"
  end
  
  def test_edit_as_editor
    member = FactoryGirl.create(:person_with_login)
    molly = FactoryGirl.create(:person)
    molly.editors << member
    use_ssl
    login_as member
    get :edit, :id => molly.to_param
    assert_response :success
    assert_equal molly, assigns(:person), "@person"
    assert_select ".tabs", :count => 0
  end

  def test_edit_as_editor
    member = FactoryGirl.create(:person_with_login)
    molly = FactoryGirl.create(:person)
    molly.editors << member
    use_ssl
    login_as member
    get :edit, :id => molly.to_param
    assert_response :success
    assert_equal molly, assigns(:person), "@person"
    assert_select ".tabs", :count => 0
  end

  def test_must_be_logged_in
    member = FactoryGirl.create(:person_with_login)
    use_ssl
    get :edit, :id => member.to_param
    assert_redirected_to new_person_session_url(secure_redirect_options)
  end

  def test_cant_see_other_people_info
    member = FactoryGirl.create(:person_with_login)
    weaver = FactoryGirl.create(:person)
    use_ssl
    login_as member
    get :edit, :id => weaver.to_param
    assert_redirected_to unauthorized_path
  end

  def test_admins_can_see_people_info
    member = FactoryGirl.create(:person_with_login)
    administrator = FactoryGirl.create(:administrator)
    use_ssl
    login_as administrator
    get :edit, :id => member.to_param
    assert_response :success
    assert_equal member, assigns(:person), "@person"
  end
  
  def test_update
    use_ssl
    person = FactoryGirl.create(:person_with_login, :first_name => "Bob", :last_name => "Jones")
    gentle_lovers = FactoryGirl.create(:team, :name => "Gentle Lovers")
    login_as person
    put :update, :id => person.to_param, :person => { :team_name => "Gentle Lovers" }
    assert_redirected_to edit_person_path(person)
    person = Person.find(person.id)
    assert_equal gentle_lovers, person.reload.team, "Team should be updated"
    assert_equal 2, person.versions.size, "versions"
    version = person.versions.last
    assert_equal person, version.user, "version user"
    changes = version.changes
    assert_equal 1, changes.size, "changes"
    change = changes["team_id"]
    assert_not_nil change, "Should have change for team ID"
    assert_equal nil, change.first, "Team ID before"
    assert_equal Team.find_by_name("Gentle Lovers").id, change.last, "Team ID after"
    assert_equal person, person.updated_by, "updated_by"
  end
  
  def test_update_no_name
    use_ssl
    editor = FactoryGirl.create(:administrator, :login => "my_login", :first_name => "", :last_name => "")
    gentle_lovers = FactoryGirl.create(:team, :name => "Gentle Lovers")
    
    login_as editor
    
    person = FactoryGirl.create(:person)
    put :update, :id => person.to_param, :person => { :team_name => "Gentle Lovers" }
    assert_redirected_to edit_person_path(person)
    person = Person.find(person.id)
    assert_equal gentle_lovers, person.reload.team, "Team should be updated"
    assert_equal 2, person.versions.size, "versions"
    version = person.versions.last
    assert_equal "my_login", version.user.name_or_login, "version user"
    changes = version.changes
    assert_equal 1, changes.size, "changes"
    change = changes["team_id"]
    assert_not_nil change, "Should have change for team ID"
    assert_equal nil, change.first, "Team ID before"
    assert_equal Team.find_by_name("Gentle Lovers").id, change.last, "Team ID after"
    assert_equal editor, person.updated_by, "updated_by"
  end
  
  def test_update_by_editor
    person = FactoryGirl.create(:person)
    molly = FactoryGirl.create(:person)
    person.editors << molly
    gentle_lovers = FactoryGirl.create(:team, :name => "Gentle Lovers")

    use_ssl
    login_as molly
    put :update, :id => person.to_param, :person => { :team_name => "Gentle Lovers" }
    assert_redirected_to edit_person_path(person)
    assert_equal gentle_lovers, person.reload.team(true), "Team should be updated"
  end
  
  def test_account
    use_ssl
    member = FactoryGirl.create(:person_with_login)
    login_as member
    get :account
    assert_redirected_to edit_person_path(member)
  end
  
  def test_account_with_person
    use_ssl
    member = FactoryGirl.create(:person_with_login)
    login_as member
    get :account, :id => member.to_param
    assert_redirected_to edit_person_path(member)
  end
  
  def test_account_with_another_person
    use_ssl
    member = FactoryGirl.create(:person_with_login)
    login_as member
    another_person = Person.create!
    get :account, :id => another_person.to_param
    assert_redirected_to edit_person_path(another_person)
  end
  
  def test_account_not_logged_in
    use_ssl
    get :account
    assert_redirected_to new_person_session_url(secure_redirect_options)
  end
  
  def test_account_with_person_not_logged_in
    use_ssl
    member = FactoryGirl.create(:person_with_login)
    get :account, :id => member.to_param
    assert_redirected_to edit_person_path(member)
  end

  def test_new_when_logged_in
    member = FactoryGirl.create(:person_with_login)
    login_as member
    use_ssl
    get :new_login
    assert_redirected_to edit_person_path(member)
    assert_not_nil flash[:notice], "flash[:notice]"
  end

  def test_index_as_xml
    FactoryGirl.create(:discipline)
    FactoryGirl.create(:number_issuer)
    FactoryGirl.create(:person, :license => 7123811, :team => FactoryGirl.create(:team), :road_number => "333").
      aliases.create!(:name => "Erik")
    get :index, :license => 7123811, :format => "xml"
    assert_response :success
    assert_equal "application/xml", @response.content_type
    [
      "person > first-name",
      "person > last-name",
      "person > date-of-birth",
      "person > license",
      "person > gender",
      "person > team",
      "person > race-numbers",
      "person > aliases",
      "team > city",
      "team > state",
      "team > website",
      "race-numbers > race-number",
      "race-number > value",
      "race-number > year",
      "race-number > discipline",
      "discipline > name",
      "aliases > alias",
      "alias > name",
      "alias > alias"
    ].each do |key|
      assert_select key
    end
  end

  def test_index_as_json
    get :index, :format => "json", :name => "ron"
    assert_response :success
    assert_equal "application/json", @response.content_type
  end
  
  def test_find_by_name_as_xml
    FactoryGirl.create(:person, :first_name => "Molly", :last_name => "Cameron")
    FactoryGirl.create(:person, :first_name => "Kevin", :last_name => "Condron")
    
    get :index, :name => "ron", :format => "xml"
    assert_response :success
    assert_select "first-name", "Molly"
    assert_select "first-name", "Kevin"
  end
  
  def test_find_by_license_as_xml
    FactoryGirl.create(:person, :first_name => "Mark", :last_name => "Matson", :license => "576")
    get :index, :name => "m", :license => 576, :format => "xml"
    assert_response :success
    assert_select "first-name", "Mark"
  end

  def test_show_as_xml
    molly = FactoryGirl.create(:person, :first_name => "Molly", :last_name => "Cameron")
    get :show, :id => molly.id, :format => "xml"
    assert_response :success
    assert_select "first-name", "Molly"
    assert_select "last-name", "Cameron"
  end

  def test_show_as_json
    molly = FactoryGirl.create(:person, :first_name => "Molly", :last_name => "Cameron")
    get :show, :id => molly.id, :format => "json"
    assert_response :success
  end
end
