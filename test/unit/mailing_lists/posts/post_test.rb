require_relative "../../../test_helper"

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
end
