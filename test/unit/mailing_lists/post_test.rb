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

  test "from_email_obscured" do
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
    assert_equal nil, post.from_name, "from_name"
    assert_equal nil, post.from_email, "from_email"
    assert !post.valid?

    post = Post.new(:from_email => "cmurray@obra.org")
    assert_equal "cmurray@obra.org", post.from_email, "from_email"
    assert_equal nil, post.from_name, "from_name"
    assert_equal "cmurray@obra.org", post.from_email, "from_email"

    post = Post.new(:from_email => "cmurray@obra.org", :from_name => "Candi Murray", :mailing_list => MailingList.new, :subject => "Subject")
    assert_equal "Candi Murray", post.from_name, "from_name"
    assert_equal "cmurray@obra.org", post.from_email, "from_email"
    assert post.valid?, post.errors.full_messages.to_s
  end

  test "full text search index" do
    post = FactoryGirl.create(:post, :subject => "Vintage Vanilla cap")
    assert PostText.exists?(:text => "Vintage Vanilla cap"), "Should create matching PostText"
    assert_not_nil post.post_text, "Should create matching PostText"
  end

  test "reposition! empty mailing list" do
    mailing_list = FactoryGirl.create(:mailing_list)
    Post.reposition! mailing_list
  end

  test "reposition!" do
    mailing_list = FactoryGirl.create(:mailing_list)
    last_post = FactoryGirl.create(:post, :mailing_list => mailing_list, :subject => "For Sale: Trek Madrone", :date => 1.day.ago, :position => 0)
    first_post = FactoryGirl.create(:post, :mailing_list => mailing_list, :subject => "Autographed TDF Jersey", :date => 3.days.ago, :position => 2)

    Post.reposition! mailing_list

    assert_equal 1, first_post.reload.position, "first post should be repositioned to position 1"
    assert_equal 2, last_post.reload.position, "last post should be repositioned to position 2"
  end

  test "add_replies! empty database" do
    mailing_list = FactoryGirl.create(:mailing_list)
    Post.add_replies! mailing_list
    assert_equal 0, Post.count
  end

  test "add_replies!" do
    mailing_list = FactoryGirl.create(:mailing_list)
    FactoryGirl.create(:post, :mailing_list => mailing_list, :subject => "For Sale: Trek Madrone", :from_name => "Lance")
    FactoryGirl.create(:post, :mailing_list => mailing_list, :subject => "Autographed TDF Jersey")

    Post.add_replies! mailing_list
    assert_equal 2, Post.original.count
  end

  test "add_replies! should consolidate similar posts" do
    mailing_list = FactoryGirl.create(:mailing_list)
    original = FactoryGirl.create(:post, :mailing_list => mailing_list, :subject => "FS: Trek Madrone", date: 3.days.ago)
    first_reply = FactoryGirl.create(:post, :mailing_list => mailing_list, :subject => "Re: FS: Trek Madrone", date: 2.days.ago)
    second_reply = FactoryGirl.create(:post, :mailing_list => mailing_list, :subject => "fs: trek madrone", date: 1.day.ago)

    Post.add_replies! mailing_list

    assert_equal original, first_reply.reload.original, "should set original post"
    assert_equal original, second_reply.reload.original, "should set original post"
    assert_equal [ first_reply, second_reply ].sort, original.replies(true).sort, "replies"
    assert_equal second_reply.date, original.reload.last_reply_at, "original last_reply_at"
    assert_equal second_reply.from_name, original.reload.last_reply_from_name, "original last_reply_from_name"
  end

end
