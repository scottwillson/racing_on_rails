require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class EditorRequestsControllerTest < ActionController::TestCase
  def setup
    super
    use_ssl
  end

  def test_create
    promoter = FactoryGirl.create(:person_with_login)
    member = FactoryGirl.create(:person, email: "person@example.com")

    login_as promoter
    post :create, id: member.to_param, editor_id: promoter.to_param
    assert_redirected_to edit_person_path(promoter)

    editor_request = EditorRequest.where(person_id: member.id, editor_id: promoter.id).first
    assert_not_nil editor_request, "Should create EditorRequest"
    assert editor_request.token.present?, "Should create token"
  end

  def test_dupes
    promoter = FactoryGirl.create(:person_with_login)
    member = FactoryGirl.create(:person, email: "person@example.com")
    existing_editor_request = member.editor_requests.create!(editor: promoter)

    login_as promoter
    post :create, id: member.to_param, editor_id: promoter.to_param
    assert_redirected_to edit_person_path(promoter)

    editor_requests = EditorRequest.where(person_id: member.id).where(editor_id: promoter.id)
    assert_equal 1, editor_requests.size, "Should only have one request"
    assert existing_editor_request.token != editor_requests.first.token, "Should be different token"
    assert !EditorRequest.exists?(existing_editor_request.id), "Should have destroyed old request"
  end

  def test_already_editor
    promoter = FactoryGirl.create(:person_with_login)
    member = FactoryGirl.create(:person, email: "person@example.com")

    member.editors << promoter
    login_as promoter
    post :create, id: member.to_param, editor_id: promoter.to_param
    assert_redirected_to edit_person_path(promoter)

    editor_request = EditorRequest.where(person_id: member.id, editor_id: promoter.id).first
    assert_nil editor_request, "Should note creat EditorRequest"
  end

  def test_not_found
    promoter = FactoryGirl.create(:person_with_login)
    login_as promoter
    assert_raise(ActiveRecord::RecordNotFound) { post(:create, id: 1231232213133, editor_id: promoter.to_param) }
  end

  def test_must_login
    promoter = FactoryGirl.create(:person)
    member = FactoryGirl.create(:person, email: "person@example.com")
    post :create, id: member.to_param, editor_id: promoter.to_param
    assert_redirected_to new_person_session_url(secure_redirect_options)
  end

  def test_security
    promoter = FactoryGirl.create(:promoter)
    member = FactoryGirl.create(:person, email: "person@example.com")
    past_member = FactoryGirl.create(:person_with_login)

    login_as past_member
    post :create, id: member.to_param, editor_id: promoter.to_param
    assert_redirected_to unauthorized_path
  end

  def test_show
    promoter = FactoryGirl.create(:promoter)
    member = FactoryGirl.create(:person, email: "person@example.com")

    editor_request = member.editor_requests.create!(editor: promoter)
    get :show, person_id: member.to_param, id: editor_request.token
    assert_response :success
    assert member.editors(true).include?(promoter), "Should add editor"
  end

  def test_show_not_found
    promoter = FactoryGirl.create(:promoter)
    member = FactoryGirl.create(:person, email: "person@example.com")

    member.editor_requests.create!(editor: promoter)
    assert_raise(ActiveRecord::RecordNotFound) { get(:show, person_id: member.to_param, id: "12367127836shdgadasd") }
    assert !member.editors(true).include?(promoter), "Should add editor"
  end
end
