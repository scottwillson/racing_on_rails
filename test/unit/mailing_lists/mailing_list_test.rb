require File.expand_path("../../../test_helper", __FILE__)

# :stopdoc:
class MailingListTest < ActiveSupport::TestCase
  def test_save
    mailing_list = MailingList.new
    mailing_list.name = "nwcycling"
    mailing_list.friendly_name = "NW Cycling"
    mailing_list.subject_line_prefix = "NW Cycling"
    mailing_list.save!
  end
  
  def test_dates
    Post.delete_all
    
    obra = FactoryGirl.create(:mailing_list)
    assert_nil(obra.dates, "Dates")
  
    today = Time.zone.today
    Post.create!(
      :mailing_list => obra,
      :subject => "TEST",
      :date => today,
      :from_name => "Scout",
      :from_email_address => "scout@obra.org",
      :body => "This is a test message"
    )

    assert_not_nil(obra.dates, "Dates")
    assert_equal_dates(today, obra.dates.first, "First date")
    assert_equal_dates(today, obra.dates.last, "Last date")

    yesterday = Time.zone.today - 1
    Post.create!(
      :mailing_list => obra,
      :subject => "TEST",
      :date => yesterday,
      :from_name => "Scout",
      :from_email_address => "scout@obra.org",
      :body => "This is a test message"
    )

    tomorrow = Time.zone.today + 1
    Post.create!(
      :mailing_list => obra,
      :subject => "TEST",
      :date => tomorrow,
      :from_name => "Scout",
      :from_email_address => "scout@obra.org",
      :body => "This is a test message"
    )

    # Cached!
    assert_equal_dates(today, obra.dates.first, "First date")
    assert_equal_dates(today, obra.dates.last, "Last date")

    obra.reload
    assert_not_nil(obra.dates, "Dates")
    assert_equal_dates(yesterday, obra.dates.first, "First date")
    assert_equal_dates(tomorrow, obra.dates.last, "Last date")
  end
end
