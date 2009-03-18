require "test_helper"

class PostTest < ActiveSupport::TestCase

  def test_save
    post = Post.new
    post.subject = "[OBRA Chat] Foo"
    post.from_email_address = "foo@bar.net"
    post.from_name = "Foo"
    post.body = "Test message"
    post.mailing_list = mailing_lists(:obra_chat)
    post.date = Date.today
    post.save!
  end
  
  def test_remove_prefix
    obra = mailing_lists(:obra_chat)
    post = Post.new
    post.subject = "[OBRA Chat] Foo"
    post.body = "Test message"
    post.mailing_list = obra
    post.from_email_address = "scout@foo.net"
    post.from_name = "Scout"
    post.date = Date.today
    post.save!
    
    post_from_db = Post.find(post.id)
    assert_equal("Foo", post.subject, "Subject")

    post = Post.new
    post.subject = "Re: [OBRA Chat] Foo"
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

  def test_add_time
    post = Post.new
    id = 90
    post.id = id
    post.date = Time.local(2003, 5, 13, 12, 0, 0, 0)
    assert_equal_dates("2003-05-13 12:00:00", post.date, "date before adding time", "%Y-%m-%d %H:%M:%S")
    post.add_time
    assert_equal_dates("2003-05-13 12:01:30", post.date, "date with time", "%Y-%m-%d %H:%M:%S")
    post.add_time
    assert_equal_dates("2003-05-13 12:01:30", post.date, "date with time", "%Y-%m-%d %H:%M:%S")
  end
  
  def test_remove_topica_header
    post = Post.new
    post.body = %q{

            <font face='Geneva,Verdana,Sans-Serif' size='-2'>To post things to the obra list the new addess is ob-@topica.com
</font>	<pre>
	</pre>

	<map name='unsubbed_gray_map'>
		<area href='/lists/obra/subscribe' shape='rect' coords='0,0,81,17'>
		<area href='/lists/obra/' shape='rect' coords='89,0,170,17'>
	</map>

	<img src='http://lists.topica.com/lists/read/images/buttons_unsubbed_gray.gif' border='0' height='18' usemap='#unsubbed_gray_map' width='171'>

		}
    assert(post.body["unsubbed_gray_map"], "Body before remove")
    post.remove_topica_footer
    assert(!post.body["unsubbed_gray_map"], "Body after remove")
  end

end
