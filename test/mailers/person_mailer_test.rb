# frozen_string_literal: true

require_relative "../test_helper"

# :stopdoc:
class PersonMailerTest < ActionMailer::TestCase
  test "new login confirmation" do
    person = FactoryBot.create(:person, email: "rr@example.com")
    email = PersonMailer.new_login_confirmation(person)
    assert_equal ["rr@example.com"], email.to
    assert_equal "New #{RacingAssociation.current.short_name} Login", email.subject
    assert_match(/new #{RacingAssociation.current.short_name} login/, email.encoded)
  end
end
