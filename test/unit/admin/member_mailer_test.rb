require File.dirname(__FILE__) + '/../../test_helper'

class Admin::MemberMailerTest < ActionMailer::TestCase
  tests Admin::MemberMailer
  def test_email
    @expected.subject = 'Admin::MemberMailer#email'
    @expected.body    = read_fixture('email')
    @expected.date    = Time.now

    assert_equal @expected.encoded, Admin::MemberMailer.create_email(@expected.date).encoded
  end

end
