require File.dirname(__FILE__) + '/../test_helper'

class MailingListTest < ActiveSupport::TestCase

  def test_save
    mailing_list = MailingList.new
    mailing_list.name = "nwcycling"
    mailing_list.friendly_name = "NW Cycling"
    mailing_list.subject_line_prefix = "NW Cycling"
    mailing_list.save!
  end
  
  def test_dates
    obra = mailing_lists(:obra_chat)
    assert_nil(obra.dates, "Dates")
  
    today = Date.today
    Post.create({
      :mailing_list => obra,
      :subject => "TEST",
      :date => today,
      :from_name => "Scout",
      :from_email_address => "scout@obra.org",
      :body => "This is a test message"
    })

    assert_not_nil(obra.dates, "Dates")
    assert_equal_dates(today, obra.dates.first, "First date")
    assert_equal_dates(today, obra.dates.last, "Last date")

    yesterday = Date.today - 1
    Post.create({
      :mailing_list => obra,
      :subject => "TEST",
      :date => yesterday,
      :from_name => "Scout",
      :from_email_address => "scout@obra.org",
      :body => "This is a test message"
    })

    tomorrow = Date.today + 1
    Post.create({
      :mailing_list => obra,
      :subject => "TEST",
      :date => tomorrow,
      :from_name => "Scout",
      :from_email_address => "scout@obra.org",
      :body => "This is a test message"
    })

    # Cached!
    assert_equal_dates(today, obra.dates.first, "First date")
    assert_equal_dates(today, obra.dates.last, "Last date")

    obra.reload
    assert_not_nil(obra.dates, "Dates")
    assert_equal_dates(yesterday, obra.dates.first, "First date")
    assert_equal_dates(tomorrow, obra.dates.last, "Last date")
  end
end
