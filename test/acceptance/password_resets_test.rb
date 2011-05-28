require "acceptance/webdriver_test_case"

# :stopdoc:
class PasswordResetsTest < WebDriverTestCase
  def test_reset_not_logged_in
    open "/person_session/new"
    click :id => "forgot"
    type "member@example.com", :id => "email"
    click :name => "commit"

    assert_page_source "Please check your email. We've sent you password reset instructions"
    perishable_token = Person.find_by_email("member@example.com").perishable_token
    open "/password_resets/#{perishable_token}/edit"

    type "new_password", :id => "person_password"
    type "new_password", :id => "person_password_confirmation"
    click :id => "save"

    assert_current_url(/.*\/people\/.*\/edit/)
    assert_page_source "Password changed"
    
    open "/logout"
    
    type "bob.jones", :id => "person_session_login"
    type "new_password", :id => "person_session_password"
    click :id => "login_button"
    
    assert_current_url(/.*\/people\/.*\/edit/)
  end

  def test_reset_logged_in
    open "/login"
    type "bob.jones", :id => "person_session_login"
    type "secret", :id => "person_session_password"
    click :id => "login_button"
    
    assert_current_url(/.*\/people\/.*\/edit/)

    open "/password_resets/new"
    type "member@example.com", :id => "email"
    click :name => "commit"

    assert_page_source "Please check your email. We've sent you password reset instructions"
    perishable_token = Person.find_by_email("member@example.com").perishable_token
    open "/password_resets/#{perishable_token}/edit"

    type "new_password", :id => "person_password"
    type "new_password", :id => "person_password_confirmation"
    click :id => "save"

    assert_current_url(/.*\/people\/.*\/edit/)
    assert_page_source "Password changed"
    
    open "/logout"
    
    type "bob.jones", :id => "person_session_login"
    type "new_password", :id => "person_session_password"
    click :id => "login_button"
    
    assert_current_url(/.*\/people\/.*\/edit/)
  end
end
