require File.expand_path(File.dirname(__FILE__) + "/acceptance_test")

# :stopdoc:
class PasswordResetsTest < AcceptanceTest
  def test_reset_not_logged_in
    FactoryGirl.create(:person_with_login, :email => "member@example.com")
    visit "/person_session/new"
    click_link "forgot"
    fill_in "email", :with => "member@example.com"
    click_button "Reset My Password"

    assert_page_has_content "Please check your email. We've sent you password reset instructions"
    perishable_token = Person.find_by_email("member@example.com").perishable_token
    visit "/password_resets/#{perishable_token}/edit"

    fill_in "person_password", :with => "new_password"
    fill_in "person_password_confirmation", :with => "new_password"
    click_button "Save"

    assert_page_has_content "Password changed"

    visit "/logout"

    fill_in "person_session_login", :with => "bob.jones"
    fill_in "person_session_password", :with => "new_password"
    click_button "Login"
  end

  def test_reset_logged_in
    FactoryGirl.create(:person_with_login, :email => "member@example.com")
    visit "/login"
    fill_in "person_session_login", :with => "bob.jones"
    fill_in "person_session_password", :with => "secret"
    click_button "Login"

    visit "/password_resets/new"
    fill_in "email", :with =>  "member@example.com"
    click_button "Reset My Password"

    assert_page_has_content "Please check your email. We've sent you password reset instructions"
    perishable_token = Person.find_by_email("member@example.com").perishable_token
    visit "/password_resets/#{perishable_token}/edit"

    fill_in "person_password", :with => "new_password"
    fill_in "person_password_confirmation", :with => "new_password"
    click_button "Save"

    assert_page_has_content "Password changed"

    visit "/logout"

    fill_in "person_session_login", :with => "bob.jones"
    fill_in "person_session_password", :with => "new_password"
    click_button "Login"
  end
end
