require_relative "../test_helper"

class NotifierTest < ActionMailer::TestCase
  test "password reset instructions" do
    person = FactoryGirl.create(:person_with_login)

    email = Notifier.password_reset_instructions([person])

    assert_equal [ person.email ], email.to
    assert_equal "Password Reset Instructions", email.subject
    assert_match(/reset/, email.encoded)
    assert_not_nil person.reload.perishable_token, "Should set perishable_token"
    assert_match(person.perishable_token, email.encoded, "Perishable token should be in email")
  end

  test "password reset instructions no name" do
    person = FactoryGirl.create(:person_with_login)
    person.update! first_name: "", last_name: ""

    email = Notifier.password_reset_instructions([person])

    assert_equal [ person.email ], email.to
    assert_equal "Password Reset Instructions", email.subject
    assert_match(/reset/, email.encoded)
    assert_not_nil person.reload.perishable_token, "Should set perishable_token"
    assert_match(person.perishable_token, email.encoded, "Perishable token should be in email")
  end
end
