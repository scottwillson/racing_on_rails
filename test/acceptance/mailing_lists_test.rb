require "acceptance/selenium_test_case"

class MailingListsTest < SeleniumTestCase
  def test_mailing_lists
    open "/mailing_lists"

    open "/posts/obra"
    assert_no_text "Schedule Changes"

    open "/posts/obra/new"

    type "post_from_name", "Scott"
    type "post_from_email_address", "scott@butlerpress.com"
    type "post_subject", "New Message"
    type "post_body", "My post message body"

    click "post", :wait_for => :page
    assert_text "Your new post is now in the mailing queue"

    open "/posts/obra/2004/12"
    assert_text "Schedule Changes"

    click "link=Schedule Changes", :wait_for => :page
    assert_text "This is a test message."

    click "link=Reply Privately", :wait_for => :page

    type "post_from_name", "Don"
    type "post_body", "This is a special private reply"

    click "commit", :wait_for => :page
    assert_text "From email address can't be blank"

    type "post_from_email_address", "don@butlerpress.com"

    click "commit", :wait_for => :page
    assert_text "Sent private reply"

    open "/posts/obra/new"

    type "post_from_email_address", "scott@butlerpress.com"
    type "post_subject", "New Message 2"
    type "post_body", "My post message body"

    click "commit", :wait_for => :page
    assert_text "From name can't be blank"

    type "post_from_name", "Scott"
    click "commit", :wait_for => :page
    assert_text "Your new post is now in the mailing queue"    
  end
end
