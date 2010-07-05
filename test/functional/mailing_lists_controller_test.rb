require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class MailingListsControllerTest < ActionController::TestCase
  def test_index
    opts = {:controller => "mailing_lists", :action => "index"}
    assert_routing("/mailing_lists", opts)

    get(:index)
    assert_response(:success)
    assert_template("mailing_lists/index")
    assert_not_nil(assigns["mailing_lists"], "Should assign mailing_lists")
  end
end
