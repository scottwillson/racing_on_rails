require File.expand_path(File.dirname(__FILE__) + "/acceptance_test")

# :stopdoc:
class MailingListsTest < AcceptanceTest
  def test_mailing_lists
    mailing_list = FactoryGirl.create(:mailing_list, name: "obra")
    mailing_list.posts.create!(
      subject: "Schedule Changes",
      date: "2004-12-31",
      from_name: "Scout",
      from_email: "scout@obra.org",
      body: "This is a test message."
    )

    visit "/mailing_lists"

    visit "/mailing_lists/#{mailing_list.id}/posts"
    assert_page_has_no_content "Cervelo for sale"

    visit "/mailing_lists/#{mailing_list.id}/posts/new"

    fill_in "post_from_name", with: "Scott"
    fill_in "post_from_email", with: "scott.willson@gmail.com"
    fill_in "post_subject", with: "Cervelo for sale"
    fill_in "post_body", with: "My post message body"

    click_button "Post"
    assert_page_has_content "Your new post is now in the mailing queue"

    visit "/mailing_lists/#{mailing_list.id}/posts"

    click_link "Schedule Changes"
    assert_page_has_content "This is a test message."

    click_link "Reply Privately"

    fill_in "post_from_name", with: "Don"
    fill_in "post_body", with: "This is a special private reply"

    click_button "Send"
    assert_page_has_content "From email can't be blank"

    fill_in "post_from_email", with: "don@butlerpress.com"

    click_button "Send"
    assert_page_has_content "Sent private reply"

    visit "/mailing_lists/#{mailing_list.id}/posts/new"

    fill_in "post_from_email", with: "scott.willson@gmail.com"
    fill_in "post_subject", with: "New Message 2"
    fill_in "post_body", with: "My post message body"

    click_button "Post"
    assert_page_has_content "From name can't be blank"

    fill_in "post_from_name", with: "Scott"
    click_button "Post"
    assert_page_has_content "Your new post is now in the mailing queue"

    visit "/mailing_lists/#{mailing_list.id}/posts?subject=Schedule"
    visit "/mailing_lists/#{mailing_list.id}/posts?subject=xy"
    visit "/mailing_lists/#{mailing_list.id}/posts?subject=foobar"
  end
end
