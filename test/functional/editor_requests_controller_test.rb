require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class EditorRequestsControllerTest < ActionController::TestCase
  def setup
    super
    use_ssl
  end
  
  def test_create
    login_as :promoter
    post :create, :id => people(:member).to_param, :editor_id => people(:promoter).to_param
    assert_redirected_to edit_person_path(people(:promoter))
    
    editor_request = EditorRequest.first(:conditions => { :person_id => people(:member).id, :editor_id => people(:promoter).id })
    assert_not_nil editor_request, "Should created EditorRequest"
    assert editor_request.token.present?, "Should create token"
  end
  
  def test_dupes
    existing_editor_request = people(:member).editor_requests.create!(:editor => people(:promoter))

    login_as :promoter
    post :create, :id => people(:member).to_param, :editor_id => people(:promoter).to_param
    assert_redirected_to edit_person_path(people(:promoter))
    
    editor_requests = EditorRequest.all(:conditions => { :person_id => people(:member).id, :editor_id => people(:promoter).id })
    assert_equal 1, editor_requests.size, "Should only have one request"
    assert existing_editor_request.token != editor_requests.first.token, "Should be different token"
    assert !EditorRequest.exists?(existing_editor_request.id), "Should have destroyed old request"
  end
  
  def test_already_editor
    people(:member).editors << people(:promoter)
    login_as :promoter
    post :create, :id => people(:member).to_param, :editor_id => people(:promoter).to_param
    assert_redirected_to edit_person_path(people(:promoter))
    
    editor_request = EditorRequest.first(:conditions => { :person_id => people(:member).id, :editor_id => people(:promoter).id })
    assert_nil editor_request, "Should note creat EditorRequest"
  end
  
  def test_not_found
    login_as :promoter
    assert_raise(ActiveRecord::RecordNotFound) { post(:create, :id => 1231232213133, :editor_id => people(:promoter).to_param) }
  end
  
  def test_must_login
    post :create, :id => people(:member).to_param, :editor_id => people(:promoter).to_param
    assert_redirected_to new_person_session_url(secure_redirect_options)
  end
  
  def test_security
    login_as :past_member
    post :create, :id => people(:member).to_param, :editor_id => people(:promoter).to_param
    assert_redirected_to unauthorized_path
  end
  
  def test_show
    use_http
    editor_request = people(:member).editor_requests.create!(:editor => people(:promoter))
    get :show, :id => people(:member).to_param, :id => editor_request.token
    assert_response :success
    assert people(:member).editors(true).include?(people(:promoter)), "Should add editor"
  end
  
  def test_show_not_found
    use_http
    editor_request = people(:member).editor_requests.create!(:editor => people(:promoter))
    assert_raise(ActiveRecord::RecordNotFound) { get(:show, :id => people(:member).to_param, :id => "12367127836shdgadasd") }
    assert !people(:member).editors(true).include?(people(:promoter)), "Should add editor"
  end
end
