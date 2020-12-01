# frozen_string_literal: true

require File.expand_path("../../test_helper", __dir__)

# :stopdoc:
class MailingListTest < ActiveSupport::TestCase
  test "save" do
    mailing_list = MailingList.new
    mailing_list.name = "nwcycling"
    mailing_list.friendly_name = "NW Cycling"
    mailing_list.subject_line_prefix = "NW Cycling"
    mailing_list.save!
  end
end
