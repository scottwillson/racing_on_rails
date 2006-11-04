require File.dirname(__FILE__) + '/../test_helper'
require 'mailing_lists_controller'

# Re-raise errors caught by the controller.
class MailingListsController; def rescue_action(e) raise e end; end

class MailingListsControllerTest < Test::Unit::TestCase

  def setup
    @controller = MailingListsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_index
    opts = {:controller => "mailing_lists", :action => "index"}
    assert_routing("/mailing_lists", opts)

    get(:index)
    assert_response(:success)
    assert_template("mailing_lists/index")
    assert_not_nil(assigns["mailing_lists"], "Should assign mailing_lists")
  end
  
  def test_app_index
    opts = {:controller => "mailing_lists", :action => "app_index"}
    assert_recognizes(opts, '/')

    get(:app_index)
    assert_response(:redirect)
    assert_redirected_to(:controller => "mailing_lists", :action => "index")
  end
  
end
