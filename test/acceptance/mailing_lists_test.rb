require "acceptance/webdriver_test_case"

class MailingListsTest < WebDriverTestCase
  def test_mailing_lists
    open "/mailing_lists"

    open "/posts/obra"
    assert_not_in_page_source "Schedule Changes"

    open "/posts/obra/new"

    type "Scott", :id => "post_from_name"
    type "scott@butlerpress.com", :id => "post_from_email_address"
    type "New Message", :id => "post_subject"
    type "My post message body", :id => "post_body"

    click :id => "post"
    assert_page_source "Your new post is now in the mailing queue"

    open "/posts/obra/2004/12"
    assert_page_source "Schedule Changes"

    click :link_text => "Schedule Changes"
    assert_page_source "This is a test message."

    click :link_text => "Reply Privately"

    type "Don", :id => "post_from_name"
    type "This is a special private reply", :id => "post_body"

    click :name => "commit"
    assert_page_source "From email address can't be blank"

    type "don@butlerpress.com", :id => "post_from_email_address"

    click :name => "commit"
    assert_page_source "Sent private reply"

    open "/posts/obra/new"

    type "scott@butlerpress.com", :id => "post_from_email_address"
    type "New Message 2", :id => "post_subject"
    type "My post message body", :id => "post_body"

    click :name => "commit"
    assert_page_source "From name can't be blank"

    type "Scott", :id => "post_from_name"
    click :name => "commit"
    assert_page_source "Your new post is now in the mailing queue"    
  end
end
