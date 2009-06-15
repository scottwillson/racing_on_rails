require "test_helper"

class PasswordResetsControllerTest < ActionController::TestCase
  def test_forgot_password
    post :create, :email => "admin@example.com"
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end
  
  def test_forgot_password_error
    post :create, :email => "nouser@example.com"
    assert_response :success
  end
  
  def test_edit
    get :edit, :id => users(:member).perishable_token
    assert_response :success
    assert_equal(users(:member), assigns["user"], "@user")
  end
  
  def test_update_admin
    password = users(:administrator).crypted_password
    post :update, :id => users(:administrator).perishable_token, :user => { :password => "my new password", :password_confirmation => "my new password" }
    assert_not_nil(assigns["user"], "@user")
    assert_not_nil(assigns["user_session"], "@user_session")
    assert(password != User.find(users(:administrator).id).crypted_password, "Password should change")
    assert_redirected_to admin_home_path
  end
  
  def test_update_member
    password = users(:administrator).crypted_password
    post :update, :id => users(:member).perishable_token, :user => { :password => "my new password", :password_confirmation => "my new password" }
    assert_not_nil(assigns["user"], "@user")
    assert_not_nil(assigns["user_session"], "@user_session")
    assert(assigns["user"].errors.empty?, assigns["user"].errors.full_messages)
    assert(password != User.find(users(:member).id).crypted_password, "Password should change")
    assert_redirected_to root_path
  end
  
  def test_invalid_update
    password = users(:member).crypted_password
    post :update, :id => users(:member).perishable_token, :user => { :password => "my new password", :password_confirmation => "another password that doesn't match" }
    assert_nil(assigns["user_session"], "@user_session")
    assert_not_nil(assigns["user"], "@user")
    assert_not_nil(assigns("user").errors[:password], "Should have error on password")
    assert(password == User.find(users(:member).id).crypted_password, "Password should not change")
    assert_response :success
  end
end
