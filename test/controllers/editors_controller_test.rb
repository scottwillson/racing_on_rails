# frozen_string_literal: true

require File.expand_path("../test_helper", __dir__)

# :stopdoc:
class EditorsControllerTest < ActionController::TestCase
  def setup
    super
    use_ssl
  end

  test "create" do
    promoter = FactoryBot.create(:promoter)
    member = FactoryBot.create(:person_with_login)

    login_as member
    post :create, params: { id: member.to_param, editor_id: promoter.to_param }
    assert_redirected_to edit_person_path(member)

    assert member.editors.include?(promoter), "Should add promoter as editor of member"
  end

  test "create by get" do
    promoter = FactoryBot.create(:promoter)
    member = FactoryBot.create(:person_with_login)

    login_as member
    get :create, params: { id: member.to_param, editor_id: promoter.to_param }
    assert_redirected_to edit_person_path(member)

    assert member.editors.include?(promoter), "Should add promoter as editor of member"
  end

  test "create as admin" do
    administrator = FactoryBot.create(:administrator)
    promoter = FactoryBot.create(:promoter)
    member = FactoryBot.create(:person_with_login)

    login_as administrator
    post :create, params: { id: member.to_param, editor_id: promoter.to_param }
    assert_redirected_to edit_person_path(member)

    assert member.editors.include?(promoter), "Should add promoter as editor of member"
  end

  test "login required" do
    promoter = FactoryBot.create(:promoter)
    member = FactoryBot.create(:person)
    post :create, params: { id: member.to_param, editor_id: promoter.to_param }
    assert_redirected_to new_person_session_url
  end

  test "security" do
    promoter = FactoryBot.create(:promoter)
    member = FactoryBot.create(:person_with_login)

    login_as promoter
    post :create, params: { id: member.to_param, editor_id: promoter.to_param }
    assert_redirected_to unauthorized_path

    assert_not member.editors.include?(promoter), "Should not add promoter as editor of member"
  end

  test "already exists" do
    promoter = FactoryBot.create(:promoter)
    member = FactoryBot.create(:person_with_login)

    member.editors << promoter

    login_as member
    post :create, params: { id: member.to_param, editor_id: promoter.to_param }
    assert_redirected_to edit_person_path(member)

    assert member.editors.include?(promoter), "Should add promoter as editor of member"
  end

  test "admin" do
    administrator = FactoryBot.create(:administrator)
    promoter = FactoryBot.create(:promoter)
    member = FactoryBot.create(:person_with_login)

    login_as administrator
    post :create, params: { id: member.to_param, editor_id: promoter.to_param, return_to: "admin" }
    assert_redirected_to edit_admin_person_path(member)

    assert member.editors.include?(promoter), "Should add promoter as editor of member"
  end

  test "person not found" do
    member = FactoryBot.create(:person_with_login)

    login_as member
    assert_raise(ActiveRecord::RecordNotFound) { post :create, params: { editor_id: "37812361287", id: member.to_param } }
  end

  test "editor not found" do
    member = FactoryBot.create(:person_with_login)

    login_as member
    assert_raise(ActiveRecord::RecordNotFound) { post :create, params: { editor_id: member.to_param, id: "2312631872343" } }
  end

  test "deny access" do
    promoter = FactoryBot.create(:promoter)
    member = FactoryBot.create(:person_with_login)

    member.editors << promoter

    login_as member
    delete :destroy, params: { id: member.to_param, editor_id: promoter.to_param }
    assert_redirected_to edit_person_path(member)

    assert_not member.editors.include?(promoter), "Should remove promoter as editor of member"
  end

  test "deny access by get" do
    promoter = FactoryBot.create(:promoter)
    member = FactoryBot.create(:person_with_login)

    member.editors << promoter

    login_as member
    get :destroy, params: { id: member.to_param, editor_id: promoter.to_param }
    assert_redirected_to edit_person_path(member)

    assert_not member.editors.include?(promoter), "Should remove promoter as editor of member"
  end
end
