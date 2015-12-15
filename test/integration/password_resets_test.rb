require_relative "racing_on_rails/integration_test"

# :stopdoc:
class PasswordResetsTest < RacingOnRails::IntegrationTest
  test "shared email address" do
    person = FactoryGirl.create(:person_with_login)

    same_email = Person.create!(login: "jane.jones", email: "member@example.com")
    same_email.password = "wolfie"
    same_email.password_confirmation = "wolfie"
    same_email.save!

    no_login = Person.create!(email: "member@example.com")

    get new_password_reset_path
    assert_response :success

    post password_resets_path(email: "member@example.com")
    assert_response :redirect
    follow_redirect!
    assert_response :success

    assert_not_nil person.reload.perishable_token, "bob.jones should have a password reset token"
    assert_not_nil same_email.reload.perishable_token, "jane.jones should have a password reset token"
    assert_nil no_login.reload.perishable_token, "person with same email but no login should not have a password reset token"

    get edit_password_reset_path(same_email.perishable_token)
    assert_response :success

    put password_reset_path(id: same_email.perishable_token, person: { password: "scouter", password_confirmation: "scouter" })
    assert_response :redirect
    assert_redirected_to account_path
    follow_redirect!
    assert_response :redirect

    get logout_path
    assert_response :redirect
    follow_redirect!
    assert_response :success

    get edit_password_reset_path(person.perishable_token)
    assert_response :success

    put password_reset_path(id: person.perishable_token, person: { password: "mamba", password_confirmation: "mamba" })
    assert_response :redirect
    assert_redirected_to account_path
    follow_redirect!
    assert_response :redirect
  end
end
