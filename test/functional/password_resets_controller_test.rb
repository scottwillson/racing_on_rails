require "test_helper"

class PasswordResetsControllerTest < ActionController::TestCase
  def setup
    super
    use_ssl
  end
  
  def test_forgot_password
    ActionMailer::Base.deliveries.clear
    post :create, :email => "admin@example.com"
    assert_response :redirect
    assert_redirected_to new_person_session_path
    assert_equal 1, ActionMailer::Base.deliveries.count, "Should send one email"
  end
  
  def test_forgot_password_error
    ActionMailer::Base.deliveries.clear
    post :create, :email => "noperson@example.com"
    assert_response :success
    assert_equal 0, ActionMailer::Base.deliveries.count, "Should send one email"
  end
  
  def test_forgot_password_invalid_email
    ActionMailer::Base.deliveries.clear
    post :create, :email => "bob.jones"
    assert_response :success
    assert_equal 0, ActionMailer::Base.deliveries.count, "Should send one email"
  end
  
  def test_forgot_password_blank_email
    ActionMailer::Base.deliveries.clear
    Person.create! :email => ""
    post :create, :email => ""
    assert_response :success
    assert_equal 0, ActionMailer::Base.deliveries.count, "Should send one email"
  end
  
  def test_edit
    get :edit, :id => people(:member).perishable_token
    assert_response :success
    assert_equal(people(:member), assigns["person"], "@person")
  end
  
  def test_update_admin
    password = people(:administrator).crypted_password
    post :update, :id => people(:administrator).perishable_token, :person => { :password => "my new password", :password_confirmation => "my new password" }
    assert_not_nil(assigns["person"], "@person")
    assert_not_nil(assigns["person_session"], "@person_session")
    assert(password != Person.find(people(:administrator).id).crypted_password, "Password should change")
    assert_redirected_to admin_home_path
  end
  
  def test_update_member
    password = people(:administrator).crypted_password
    post :update, :id => people(:member).perishable_token, :person => { :password => "my new password", :password_confirmation => "my new password" }
    assert_not_nil(assigns["person"], "@person")
    assert_not_nil(assigns["person_session"], "@person_session")
    assert(assigns["person"].errors.empty?, assigns["person"].errors.full_messages)
    assert(password != Person.find(people(:member).id).crypted_password, "Password should change")
    assert_redirected_to "/account"
  end
  
  def test_invalid_update
    password = people(:member).crypted_password
    post :update, :id => people(:member).perishable_token, :person => { :password => "my new password", :password_confirmation => "another password that doesn't match" }
    assert_nil(assigns["person_session"], "@person_session")
    assert_not_nil(assigns["person"], "@person")
    assert_not_nil(assigns("person").errors[:password], "Should have error on password")
    assert(password == Person.find(people(:member).id).crypted_password, "Password should not change")
    assert_response :success
  end
  
  def test_blank_update
    password = people(:member).crypted_password
    post :update, :id => people(:member).perishable_token, :person => { :password => "", :password_confirmation => "" }
    assert_nil(assigns["person_session"], "@person_session")
    assert_not_nil(assigns["person"], "@person")
    assert_not_nil(assigns("person").errors[:password], "Should have error on password")
    assert(password == Person.find(people(:member).id).crypted_password, "Password should not change")
    assert_response :success
  end
end
