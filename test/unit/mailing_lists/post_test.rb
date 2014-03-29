require_relative "../../test_helper"

# :stopdoc:
class PostTest < ActiveSupport::TestCase
  test "strip list prefix from subject" do
    mailing_list = FactoryGirl.build(:mailing_list, :subject_line_prefix => "OBRA Chat")
    post = Post.new(:subject => "[OBRA Chat] Foo", :mailing_list => mailing_list)
    post.remove_list_prefix
    assert_equal "Foo", post.subject, "Subject"

    post = Post.new(:subject => "Re: [OBRA Chat] Foo", :mailing_list => mailing_list)
    post.remove_list_prefix
    assert_equal "Re: Foo", post.subject, "Subject"
  end

  test "sender_obscured" do
    post = Post.new
    post.sender = "scout@foo.net"
    assert_equal("sco..@foo.net", post.sender_obscured, "Sender obscured")

    post = Post.new
    post.sender = "s@foo.net"
    assert_equal("..@foo.net", post.sender_obscured, "Sender obscured")

    post = Post.new
    post.sender = "scott_willson@foo.net"
    assert_equal("scott_wills..@foo.net", post.sender_obscured, "Sender obscured")

    post = Post.new
    post.sender = "scott.willson@foo.net"
    assert_equal("scott.wills..@foo.net", post.sender_obscured, "Sender obscured")

    post = Post.new
    post.sender = "Barney Rubble"
    assert_equal("Barney Rubble", post.sender_obscured, "Sender obscured")

    post = Post.new
    post.sender = "EM"
    assert_equal("EM", post.sender_obscured, "Sender obscured")

    post = Post.new
    post.sender = "Robert Downey, Jr."
    assert_equal("Robert Downey, Jr.", post.sender_obscured, "Sender obscured")

    post = Post.new
    post.sender = "scott_will-@foo.net"
    post.topica_message_id = 125633
    assert_equal("scott_will-@foo.net", post.sender_obscured, "Sender obscured")
  end

  test "from" do
    post = Post.new
    assert_equal "", post.from_name, "from_name"
    assert_equal "", post.from_email_address, "from_email_address"
    assert !post.valid?

    post = Post.new(:sender => "cmurray@obra.org")
    assert_equal "cmurray@obra.org", post.sender, "sender"
    assert_equal nil, post.from_name, "from_name"
    assert_equal "cmurray@obra.org", post.from_email_address, "from_email_address"

    post = Post.new(:sender => "Candi Murray <cmurray@obra.org>", :mailing_list => MailingList.new, :subject => "Subject")
    assert_equal "Candi Murray", post.from_name, "from_name"
    assert_equal "cmurray@obra.org", post.from_email_address, "from_email_address"
    assert post.valid?, post.errors.full_messages.to_s
  end

  test "full text search index" do
    post = FactoryGirl.create(:post, :subject => "Vintage Vanilla cap")
    assert PostText.exists?(:text => "Vintage Vanilla cap"), "Should create matching PostText"
    assert_not_nil post.post_text, "Should create matching PostText"
  end
end
