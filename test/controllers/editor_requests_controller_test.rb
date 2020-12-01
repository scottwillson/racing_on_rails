# frozen_string_literal: true

require File.expand_path("../test_helper", __dir__)

# :stopdoc:
class EditorRequestsControllerTest < ActionController::TestCase
  def setup
    super
    use_ssl
  end

  test "create" do
    promoter = FactoryBot.create(:person_with_login)
    member = FactoryBot.create(:person, email: "person@example.com")

    login_as promoter
    post :create, params: { id: member.to_param, editor_id: promoter.to_param }
    assert_redirected_to edit_person_path(promoter)

    editor_request = EditorRequest.where(person_id: member.id, editor_id: promoter.id).first
    assert_not_nil editor_request, "Should create EditorRequest"
    assert editor_request.token.present?, "Should create token"
  end

  test "dupes" do
    promoter = FactoryBot.create(:person_with_login)
    member = FactoryBot.create(:person, email: "person@example.com")
    existing_editor_request = member.editor_requests.create!(editor: promoter)

    login_as promoter
    post :create, params: { id: member.to_param, editor_id: promoter.to_param }
    assert_redirected_to edit_person_path(promoter)

    editor_requests = EditorRequest.where(person_id: member.id).where(editor_id: promoter.id)
    assert_equal 1, editor_requests.size, "Should only have one request"
    assert existing_editor_request.token != editor_requests.first.token, "Should be different token"
    assert_not EditorRequest.exists?(existing_editor_request.id), "Should have destroyed old request"
  end

  test "already editor" do
    promoter = FactoryBot.create(:person_with_login)
    member = FactoryBot.create(:person, email: "person@example.com")

    member.editors << promoter
    login_as promoter
    post :create, params: { id: member.to_param, editor_id: promoter.to_param }
    assert_redirected_to edit_person_path(promoter)

    editor_request = EditorRequest.where(person_id: member.id, editor_id: promoter.id).first
    assert_nil editor_request, "Should note creat EditorRequest"
  end

  test "not found" do
    promoter = FactoryBot.create(:person_with_login)
    login_as promoter
    assert_raise(ActiveRecord::RecordNotFound) { post(:create, params: { id: 1_231_232_213_133, editor_id: promoter.to_param }) }
  end

  test "must login" do
    promoter = FactoryBot.create(:person)
    member = FactoryBot.create(:person, email: "person@example.com")
    post :create, params: { id: member.to_param, editor_id: promoter.to_param }
    assert_redirected_to new_person_session_url
  end

  test "security" do
    promoter = FactoryBot.create(:promoter)
    member = FactoryBot.create(:person, email: "person@example.com")
    past_member = FactoryBot.create(:person_with_login)

    login_as past_member
    post :create, params: { id: member.to_param, editor_id: promoter.to_param }
    assert_redirected_to unauthorized_path
  end

  test "show" do
    promoter = FactoryBot.create(:promoter)
    member = FactoryBot.create(:person, email: "person@example.com")

    editor_request = member.editor_requests.create!(editor: promoter)
    get :show, params: { person_id: member.to_param, id: editor_request.token }
    assert_response :success
    assert member.editors.reload.include?(promoter), "Should add editor"
  end

  test "show not found" do
    promoter = FactoryBot.create(:promoter)
    member = FactoryBot.create(:person, email: "person@example.com")

    member.editor_requests.create!(editor: promoter)

    assert_raise(ActiveRecord::RecordNotFound) do
      get(:show, params: { person_id: member.to_param, id: "12367127836shdgadasd" })
    end

    assert_not member.editors.reload.include?(promoter), "Should add editor"
  end
end
