require "test_helper"

class Admin::MemberMailerTest < ActionMailer::TestCase
  tests Admin::MemberMailer
  def test_email
    @expected.body    = read_fixture('email')
    @expected.to = ["training_wheels@yahoo.com"]

    assert_equal @expected.encoded, Admin::MemberMailer.create_email("training_wheels@yahoo.com").encoded
  end

end
