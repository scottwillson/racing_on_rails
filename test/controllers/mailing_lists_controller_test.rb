# frozen_string_literal: true

require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class MailingListsControllerTest < ActionController::TestCase
  test "index" do
    get :index
    assert_response(:success)
    assert_template("mailing_lists/index")
    assert_not_nil(assigns["mailing_lists"], "Should assign mailing_lists")
  end
end
