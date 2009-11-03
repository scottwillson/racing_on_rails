require "acceptance/selenium_test_case"

class PasswordResetsTest < SeleniumTestCase
  def test_reset_not_logged_in
    open "/person_sessions/new"
    click "forgot", :wait_for => :page
    type "email", "member@example.com"
    click "commit", :wait_for => :page

    assert_text "Instructions to reset your password have been emailed to you"
    perishable_token = Person.find_by_email("member@example.com").perishable_token
    open "/password_resets/#{perishable_token}/edit"

    type "person_password", "new_password"
    type "person_password_confirmation", "new_password"
    click "save", :wait_for => :page

    assert_location "glob:*/people/*/edit"
    assert_text "Password changed"
    
    open "/logout"
    
    type "person_session_login", "bob.jones"
    type "person_session_password", "new_password"
    click "login_button", :wait_for => :page
    assert_no_errors
    
    assert_location "glob:*/people/*/edit"
  end
  
  # Try bad email address in password reset
  # Try bad passwords, then reset
  # Login, then reset
  # Bad new passwords
  # Email address that doesn't exists
end
