require File.expand_path("../../../test_helper", __FILE__)

# :stopdoc:
class PostTest < ActiveSupport::TestCase
  def test_save
    post = Post.new
    post.subject = "[OBRA Chat] Foo"
    post.from_email_address = "foo@bar.net"
    post.from_name = "Foo"
    post.body = "Test message"
    post.mailing_list = FactoryGirl.create(:mailing_list)
    post.date = Date.today
    post.save!
  end
  
  def test_remove_prefix
    obra = FactoryGirl.create(:mailing_list)
    post = Post.new
    post.subject = "[#{obra.friendly_name}] Foo"
    post.body = "Test message"
    post.mailing_list = obra
    post.from_email_address = "scout@foo.net"
    post.from_name = "Scout"
    post.date = Date.today
    post.save!
    
    post_from_db = Post.find(post.id)
    assert_equal("Foo", post.subject, "Subject")

    post = Post.new
    post.subject = "Re: [#{obra.friendly_name}] Foo"
    post.body = "Test message"
    post.mailing_list = obra
    post.from_email_address = "scout@foo.net"
    post.from_name = "Scout"
    post.date = Date.today
    post.save!
    
    post_from_db = Post.find(post.id)
    assert_equal("Re: Foo", post.subject, "Subject")
  end
  
  def test_sender_obscured
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
  
  def test_from
    post = Post.new
    assert_equal "", post.from_name, "from_name"
    assert_equal "", post.from_email_address, "from_email_address"

    post = Post.new(:sender => "cmurray@obra.org")
    assert_equal "cmurray@obra.org", post.sender, "sender"
    assert_equal nil, post.from_name, "from_name"
    assert_equal "cmurray@obra.org", post.from_email_address, "from_email_address"

    post = Post.new(:sender => "Candi Murray <cmurray@obra.org>")
    assert_equal "Candi Murray", post.from_name, "from_name"
    assert_equal "cmurray@obra.org", post.from_email_address, "from_email_address"
  end
end
