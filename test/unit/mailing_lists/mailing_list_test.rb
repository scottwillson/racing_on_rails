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
end
