require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class EditorsControllerTest < ActionController::TestCase
  def setup
    super
    use_ssl
  end
  
  def test_create
    login_as :member
    post :create, :id => people(:member).to_param, :editor_id => people(:promoter).to_param
    assert_redirected_to edit_person_path(people(:member))
    
    assert people(:member).editors.include?(people(:promoter)), "Should add promoter as editor of member"
  end
  
  def test_create_by_get
    login_as :member
    get :create, :id => people(:member).to_param, :editor_id => people(:promoter).to_param
    assert_redirected_to edit_person_path(people(:member))
    
    assert people(:member).editors.include?(people(:promoter)), "Should add promoter as editor of member"
  end
  
  def test_create_as_admin
    login_as :administrator
    post :create, :id => people(:member).to_param, :editor_id => people(:promoter).to_param
    assert_redirected_to edit_person_path(people(:member))
    
    assert people(:member).editors.include?(people(:promoter)), "Should add promoter as editor of member"
  end
  
  def test_login_required
    post :create, :id => people(:member).to_param, :editor_id => people(:promoter).to_param
    assert_redirected_to new_person_session_url(secure_redirect_options)
  end
  
  def test_security
    login_as :promoter
    post :create, :id => people(:member).to_param, :editor_id => people(:promoter).to_param
    assert_redirected_to unauthorized_path
    
    assert !people(:member).editors.include?(people(:promoter)), "Should not add promoter as editor of member"
  end
  
  def test_already_exists
    people(:member).editors << people(:promoter)
    
    login_as :member
    post :create, :id => people(:member).to_param, :editor_id => people(:promoter).to_param
    assert_redirected_to edit_person_path(people(:member))
    
    assert people(:member).editors.include?(people(:promoter)), "Should add promoter as editor of member"
  end
  
  def test_admin
    login_as :administrator
    post :create, :id => people(:member).to_param, :editor_id => people(:promoter).to_param, :return_to => "admin"
    assert_redirected_to edit_admin_person_path(people(:member))
    
    assert people(:member).editors.include?(people(:promoter)), "Should add promoter as editor of member"
  end
  
  def test_person_not_found
    login_as :member
    assert_raise(ActiveRecord::RecordNotFound) { post :create, :editor_id => "37812361287", :id => people(:member).to_param }
  end
  
  def test_editor_not_found
    login_as :member
    assert_raise(ActiveRecord::RecordNotFound) { post :create, :editor_id => people(:member).to_param, :id => "2312631872343" }
  end
  
  def test_deny_access
    people(:member).editors << people(:promoter)
    
    login_as :member
    delete :destroy, :id => people(:member).to_param, :editor_id => people(:promoter).to_param
    assert_redirected_to edit_person_path(people(:member))
    
    assert !people(:member).editors.include?(people(:promoter)), "Should remove promoter as editor of member"
  end
  
  def test_deny_access_by_get
    people(:member).editors << people(:promoter)
    
    login_as :member
    get :destroy, :id => people(:member).to_param, :editor_id => people(:promoter).to_param
    assert_redirected_to edit_person_path(people(:member))
    
    assert !people(:member).editors.include?(people(:promoter)), "Should remove promoter as editor of member"
  end
end
