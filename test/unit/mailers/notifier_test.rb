require File.expand_path("../../../test_helper", __FILE__)

class NotifierTest < ActionMailer::TestCase
  def test_password_reset_instructions
    person = FactoryGirl.create(:person_with_login)

    email = Notifier.password_reset_instructions([person])

    assert_equal [ person.email ], email.to
    assert_equal "Password Reset Instructions", email.subject
    assert_match(/reset/, email.encoded)
    assert_not_nil person.reload.perishable_token, "Should set perishable_token"
    assert_match(person.perishable_token, email.encoded, "Perishable token should be in email")
  end

  def test_password_reset_instructions_no_name
    person = FactoryGirl.create(:person_with_login)
    person.update_attributes! :first_name => "", :last_name => ""

    email = Notifier.password_reset_instructions([person])

    assert_equal [ person.email ], email.to
    assert_equal "Password Reset Instructions", email.subject
    assert_match(/reset/, email.encoded)
    assert_not_nil person.reload.perishable_token, "Should set perishable_token"
    assert_match(person.perishable_token, email.encoded, "Perishable token should be in email")
  end
end
