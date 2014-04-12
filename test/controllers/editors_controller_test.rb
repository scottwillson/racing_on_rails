require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class EditorsControllerTest < ActionController::TestCase
  def setup
    super
    use_ssl
  end
  
  def test_create
    promoter = FactoryGirl.create(:promoter)
    member = FactoryGirl.create(:person_with_login)

    login_as member
    post :create, :id => member.to_param, :editor_id => promoter.to_param
    assert_redirected_to edit_person_path(member)
    
    assert member.editors.include?(promoter), "Should add promoter as editor of member"
  end
  
  def test_create_by_get
    promoter = FactoryGirl.create(:promoter)
    member = FactoryGirl.create(:person_with_login)

    login_as member
    get :create, :id => member.to_param, :editor_id => promoter.to_param
    assert_redirected_to edit_person_path(member)
    
    assert member.editors.include?(promoter), "Should add promoter as editor of member"
  end
  
  def test_create_as_admin
    administrator = FactoryGirl.create(:administrator)
    promoter = FactoryGirl.create(:promoter)
    member = FactoryGirl.create(:person_with_login)

    login_as administrator
    post :create, :id => member.to_param, :editor_id => promoter.to_param
    assert_redirected_to edit_person_path(member)
    
    assert member.editors.include?(promoter), "Should add promoter as editor of member"
  end
  
  def test_login_required
    promoter = FactoryGirl.create(:promoter)
    member = FactoryGirl.create(:person)
    post :create, :id => member.to_param, :editor_id => promoter.to_param
    assert_redirected_to new_person_session_url(secure_redirect_options)
  end
  
  def test_security
    promoter = FactoryGirl.create(:promoter)
    member = FactoryGirl.create(:person_with_login)

    login_as promoter
    post :create, :id => member.to_param, :editor_id => promoter.to_param
    assert_redirected_to unauthorized_path
    
    assert !member.editors.include?(promoter), "Should not add promoter as editor of member"
  end
  
  def test_already_exists
    promoter = FactoryGirl.create(:promoter)
    member = FactoryGirl.create(:person_with_login)

    member.editors << promoter
    
    login_as member
    post :create, :id => member.to_param, :editor_id => promoter.to_param
    assert_redirected_to edit_person_path(member)
    
    assert member.editors.include?(promoter), "Should add promoter as editor of member"
  end
  
  def test_admin
    administrator = FactoryGirl.create(:administrator)
    promoter = FactoryGirl.create(:promoter)
    member = FactoryGirl.create(:person_with_login)

    login_as administrator
    post :create, :id => member.to_param, :editor_id => promoter.to_param, :return_to => "admin"
    assert_redirected_to edit_admin_person_path(member)
    
    assert member.editors.include?(promoter), "Should add promoter as editor of member"
  end
  
  def test_person_not_found
    member = FactoryGirl.create(:person_with_login)

    login_as member
    assert_raise(ActiveRecord::RecordNotFound) { post :create, :editor_id => "37812361287", :id => member.to_param }
  end
  
  def test_editor_not_found
    member = FactoryGirl.create(:person_with_login)

    login_as member
    assert_raise(ActiveRecord::RecordNotFound) { post :create, :editor_id => member.to_param, :id => "2312631872343" }
  end
  
  def test_deny_access
    promoter = FactoryGirl.create(:promoter)
    member = FactoryGirl.create(:person_with_login)

    member.editors << promoter
    
    login_as member
    delete :destroy, :id => member.to_param, :editor_id => promoter.to_param
    assert_redirected_to edit_person_path(member)
    
    assert !member.editors.include?(promoter), "Should remove promoter as editor of member"
  end
  
  def test_deny_access_by_get
    promoter = FactoryGirl.create(:promoter)
    member = FactoryGirl.create(:person_with_login)

    member.editors << promoter
    
    login_as member
    get :destroy, :id => member.to_param, :editor_id => promoter.to_param
    assert_redirected_to edit_person_path(member)
    
    assert !member.editors.include?(promoter), "Should remove promoter as editor of member"
  end
end
