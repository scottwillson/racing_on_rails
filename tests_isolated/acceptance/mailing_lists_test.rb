# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + "/acceptance_test")

# :stopdoc:
class MailingListsTest < AcceptanceTest
  test "mailing lists" do
    mailing_list = FactoryBot.create(:mailing_list, name: "obra")
    mailing_list.posts.create!(
      subject: "Schedule Changes",
      date: "2004-12-31",
      from_name: "Scout",
      from_email: "scout@obra.org",
      body: "This is a test message."
    )

    visit "/mailing_lists"

    visit "/mailing_lists/#{mailing_list.id}/posts"
    assert_no_text "Cervelo for sale"


    click_link "Schedule Changes"
    assert_page_has_content "This is a test message."

    visit "/mailing_lists/#{mailing_list.id}/posts?subject=Schedule"
    visit "/mailing_lists/#{mailing_list.id}/posts?subject=xy"
    visit "/mailing_lists/#{mailing_list.id}/posts?subject=foobar"
  end
end
