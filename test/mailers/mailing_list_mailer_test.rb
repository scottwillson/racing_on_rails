# frozen_string_literal: true

require_relative "../test_helper"

# :stopdoc:
class MailingListMailerTest < ActionMailer::TestCase
  test "post" do
    post = FactoryBot.create(:mailing_list).posts.create!(
      from_name: "Molly",
      from_email: "molly@veloshop.com",
      subject: "For Sale",
      body: "Lots of singlespeeds for sale."
    )

    post_email = MailingListMailer.post(post)
    assert_equal ["molly@veloshop.com"], post_email.from
    assert_equal "For Sale", post_email.subject
  end

  test "post private reply" do
    post = FactoryBot.create(:mailing_list).posts.create!(
      from_name: "Molly",
      from_email: "molly@veloshop.com",
      subject: "For Sale",
      body: "Lots of singlespeeds for sale."
    )

    post_email = MailingListMailer.private_reply(post, "Scout <scout@butlerpress.com>")
    assert_equal ["molly@veloshop.com"], post_email.from
    assert_equal "For Sale", post_email.subject
    assert_equal ["scout@butlerpress.com"], post_email.to
  end
end
