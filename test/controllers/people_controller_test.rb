# coding: utf-8

require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class PeopleControllerTest < ActionController::TestCase
  test "edit" do
    member = FactoryGirl.create(:person_with_login)
    use_ssl
    login_as member
    get :edit, id: member.to_param
    assert_response :success
    assert_equal member, assigns(:person), "@person"
    assert_select ".nav.tabs", count: 0
  end

  test "edit promoter" do
    promoter = FactoryGirl.create(:promoter)
    use_ssl
    login_as promoter
    get :edit, id: promoter.to_param
    assert_response :success
    assert_equal promoter, assigns(:person), "@person"
  end

  test "edit as editor" do
    member = FactoryGirl.create(:person_with_login)
    molly = FactoryGirl.create(:person)
    molly.editors << member
    use_ssl
    login_as member
    get :edit, id: molly.to_param
    assert_response :success
    assert_equal molly, assigns(:person), "@person"
    assert_select ".nav.tabs", count: 0
  end

  test "must be logged in" do
    member = FactoryGirl.create(:person_with_login)
    use_ssl
    get :edit, id: member.to_param
    assert_redirected_to new_person_session_url(secure_redirect_options)
  end

  test "cant see other people info" do
    member = FactoryGirl.create(:person_with_login)
    weaver = FactoryGirl.create(:person)
    use_ssl
    login_as member
    get :edit, id: weaver.to_param
    assert_redirected_to unauthorized_path
  end

  test "admins can see people info" do
    member = FactoryGirl.create(:person_with_login)
    administrator = FactoryGirl.create(:administrator)
    use_ssl
    login_as administrator
    get :edit, id: member.to_param
    assert_response :success
    assert_equal member, assigns(:person), "@person"
  end

  test "update" do
    use_ssl
    person = FactoryGirl.create(:person_with_login, first_name: "Bob", last_name: "Jones")
    gentle_lovers = FactoryGirl.create(:team, name: "Gentle Lovers")
    login_as person
    put :update, id: person.to_param, person: { team_name: "Gentle Lovers" }
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
    assert_equal person, person.updated_by_person, "updated_by_person"
  end

  test "update no name" do
    use_ssl
    editor = FactoryGirl.create(:administrator, login: "my_login", first_name: "", last_name: "")
    gentle_lovers = FactoryGirl.create(:team, name: "Gentle Lovers")

    login_as editor

    person = FactoryGirl.create(:person)
    put :update, id: person.to_param, person: { team_name: "Gentle Lovers" }
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
    assert_equal editor, person.updated_by_person, "updated_by_person"
  end

  test "update by editor" do
    person = FactoryGirl.create(:person)
    molly = FactoryGirl.create(:person)
    person.editors << molly
    gentle_lovers = FactoryGirl.create(:team, name: "Gentle Lovers")

    use_ssl
    login_as molly
    put :update, id: person.to_param, person: { team_name: "Gentle Lovers" }
    assert_redirected_to edit_person_path(person)
    assert_equal gentle_lovers, person.reload.team(true), "Team should be updated"
  end

  test "account" do
    use_ssl
    member = FactoryGirl.create(:person_with_login)
    login_as member
    get :account
    assert_redirected_to edit_person_path(member)
  end

  test "account with person" do
    use_ssl
    member = FactoryGirl.create(:person_with_login)
    login_as member
    get :account, id: member.to_param
    assert_redirected_to edit_person_path(member)
  end

  test "account with another person" do
    use_ssl
    member = FactoryGirl.create(:person_with_login)
    login_as member
    another_person = Person.create!
    get :account, id: another_person.to_param
    assert_redirected_to edit_person_path(another_person)
  end

  test "account not logged in" do
    use_ssl
    get :account
    assert_redirected_to new_person_session_url(secure_redirect_options)
  end

  test "account with person not logged in" do
    use_ssl
    member = FactoryGirl.create(:person_with_login)
    get :account, id: member.to_param
    assert_redirected_to edit_person_path(member)
  end

  test "new when logged in" do
    member = FactoryGirl.create(:person_with_login)
    login_as member
    use_ssl
    get :new_login
    assert_redirected_to edit_person_path(member)
    assert_not_nil flash[:notice], "flash[:notice]"
  end

  test "index as json" do
    get :index, format: "json", name: "ron"
    assert_response :success
    assert_equal "application/json", @response.content_type
  end

  test "find by name as xml" do
    FactoryGirl.create(:person, first_name: "Molly", last_name: "Cameron")
    FactoryGirl.create(:person, first_name: "Kevin", last_name: "Condron")

    get :index, name: "ron", format: "xml"
    assert_response :success
    assert_select "first-name", "Molly"
    assert_select "first-name", "Kevin"
  end

  test "find by license as xml" do
    FactoryGirl.create(:person, first_name: "Mark", last_name: "Matson", license: "576")
    get :index, name: "m", license: 576, format: "xml"
    assert_response :success
    assert_select "first-name", "Mark"
  end
end
