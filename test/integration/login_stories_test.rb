require "test_helper"

class LoginStoriesTest < ActionController::IntegrationTest
  def test_valid_admin_login
    get admin_racers_path
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_template 'account/login'
    assert_equal "Please login", flash[:notice]

    login :email => 'admin@example.com', :user_password => 'secret'
    assert_redirected_to admin_racers_path
  end
  
  def test_should_redirect_to_admin_home_after_admin_login
    go_to_login
    
    login :email => 'admin@example.com', :user_password => 'secret'
    assert_redirected_to "/admin"
  end
  
  def test_valid_member_login
    go_to_login
    
    login :email => 'member@example.com', :user_password => 'membersecret'
    
    get '/admin/events'
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_template 'account/login'
    assert flash.has_key?(:warn)
  end
  
  private
  
  def go_to_login
    get '/account/login'
    assert_response :success
    assert_template 'account/login'
  end
  
  def login(options)
    post 'account/authenticate', options
    assert_response :redirect
  end
end