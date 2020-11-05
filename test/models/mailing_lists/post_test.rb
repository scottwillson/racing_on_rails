# frozen_string_literal: true

require_relative "../../test_helper"

# :stopdoc:
class PostTest < ActiveSupport::TestCase
  test "strip list prefix from subject" do
    assert_equal "Foo", Post.remove_list_prefix("[OBRA Chat] Foo", "OBRA Chat")
    assert_equal "Re: Foo", Post.remove_list_prefix("[OBRA Chat] Re: Foo", "OBRA Chat")
    assert_equal "Re: Foo", Post.remove_list_prefix("Re: [OBRA Chat] Foo", "OBRA Chat")
  end

  test "from email obscured" do
    post = Post.new
    post.from_email = "scout@foo.net"
    assert_equal("sco..@foo.net", post.from_email_obscured, "from_email obscured")

    post = Post.new
    post.from_email = "s@foo.net"
    assert_equal("..@foo.net", post.from_email_obscured, "from_email obscured")

    post = Post.new
    post.from_email = "scott_willson@foo.net"
    assert_equal("scott_wills..@foo.net", post.from_email_obscured, "from_email obscured")

    post = Post.new
    post.from_email = "scott.willson@foo.net"
    assert_equal("scott.wills..@foo.net", post.from_email_obscured, "from_email obscured")

    post = Post.new
    post.from_email = "Barney Rubble"
    assert_equal("", post.from_email_obscured, "from_email obscured")

    post = Post.new
    post.from_email = "EM"
    assert_equal("", post.from_email_obscured, "from_email obscured")

    post = Post.new
    post.from_email = "Robert Downey, Jr."
    assert_equal("", post.from_email_obscured, "from_email obscured")
  end

  test "from" do
    post = Post.new
    assert_nil post.from_name, "from_name"
    assert_nil post.from_email, "from_email"
    assert !post.valid?

    post = Post.new(from_email: "cmurray@obra.org")
    assert_equal "cmurray@obra.org", post.from_email, "from_email"
    assert_nil post.from_name, "from_name"
    assert_equal "cmurray@obra.org", post.from_email, "from_email"

    post = Post.new(from_email: "cmurray@obra.org", from_name: "Candi Murray", mailing_list: MailingList.new, subject: "Subject")
    assert_equal "Candi Murray", post.from_name, "from_name"
    assert_equal "cmurray@obra.org", post.from_email, "from_email"
    assert post.valid?, post.errors.full_messages.to_s
  end

  test "newer should get next lowest original and older should get next highest original" do
    mailing_list = FactoryBot.create(:mailing_list)
    original = FactoryBot.create(:post, mailing_list: mailing_list, last_reply_at: 1.day.ago, position: 3)
    second_post = FactoryBot.create(:post, mailing_list: mailing_list, last_reply_at: 4.days.ago, position: 1)
    reply_to_original = FactoryBot.create(:post, mailing_list: mailing_list, last_reply_at: 1.day.ago, original_id: original.id, position: 2)

    original.reload
    second_post.reload
    reply_to_original.reload

    assert_nil original.newer, "original newer"
    assert_equal second_post, original.older, "original older"

    assert_equal original, second_post.newer, "second_post newer"
    assert_nil second_post.older, "second_post older"

    assert_equal original, reply_to_original.newer, "reply_to_original newer"
    assert_equal second_post, reply_to_original.older, "reply_to_original older"
  end

  test "save with no original" do
    mailing_list = FactoryBot.build(:mailing_list)
    post = FactoryBot.build(:post, mailing_list: mailing_list)

    Post.save post, mailing_list

    assert !post.new_record?
    assert_equal_dates post.date, post.last_reply_at, "last_reply_at"
    assert_nil post.original, "no original"
    assert post.replies.empty?, "no replies"
    assert_equal 0, post.replies_count, "replies_count"
  end

  test "save should update original and add reply" do
    mailing_list = FactoryBot.create(:mailing_list, subject_line_prefix: "Juniors")
    original = FactoryBot.create(:post, mailing_list: mailing_list, last_reply_at: 3.days.ago, date: 3.days.ago, subject: "My bike")
    reply = FactoryBot.build(:post, mailing_list: mailing_list, subject: "Re: My bike", date: 10.minutes.ago)

    ApplicationController.expects :expire_cache
    Post.save reply, mailing_list

    assert !reply.new_record?
    reply.reload
    assert_equal_dates reply.date, reply.last_reply_at, "last_reply_at"
    assert_equal original, reply.original, "original"
    assert reply.replies.empty?, "no replies"
    assert_equal 0, reply.replies_count, "replies_count"
    assert_equal 1, reply.position, "reply position"

    original.reload
    assert_equal_dates reply.date, original.last_reply_at, "last_reply_at"
    assert_nil original.original, "no original"
    assert_equal [reply], original.replies, "should add reply"
    assert_equal 1, original.replies.reload.size, "replies_count"
    assert_equal 1, original.replies_count, "replies_count"
    assert_equal 2, original.position, "original position"
  end

  test "find original" do
    mailing_list = FactoryBot.create(:mailing_list, subject_line_prefix: "Juniors")
    original = FactoryBot.create(:post, mailing_list: mailing_list, last_reply_at: 1.day.ago, date: 1.day.ago, subject: "My bike")
    reply = FactoryBot.build(:post, mailing_list: mailing_list, subject: "[Juniors] Re: My bike")
    second_reply = FactoryBot.build(:post, mailing_list: mailing_list, subject: "Re: My bike")
    post_on_different_subject = FactoryBot.create(:post, mailing_list: mailing_list, subject: "Something else")

    assert_nil Post.find_original(original)
    assert_equal original, Post.find_original(reply)
    assert_equal original, Post.find_original(second_reply)
    assert_nil Post.find_original(post_on_different_subject)
  end

  test "normalize subject" do
    Post.expects(:strip_subject)
    Post.expects(:remove_list_prefix)
    Post.normalize_subject "", ""
  end

  test "require valid email" do
    post = FactoryBot.build(:post, from_email: "silversuitesresidences.com/?id=167")
    assert !post.valid?
    assert post.errors[:from_email], "Expected error on :from_email. Had: #{post.errors.full_messages}"
  end

  test "recent should only show public lists" do
    public_list = FactoryBot.create(:mailing_list, public: true)
    public_post = FactoryBot.create(:post, mailing_list: public_list)

    private_list = FactoryBot.create(:mailing_list, public: false)
    private_post = FactoryBot.create(:post, mailing_list: private_list)

    assert Post.recent.include?(public_post)
    assert !Post.recent.include?(private_post)
  end
end
