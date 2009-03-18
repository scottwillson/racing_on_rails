# :stopdoc:
require "test_helper"

class Admin::HomeControllerTest < ActionController::TestCase
  def setup
    super
    @request.session[:user_id] = users(:administrator).id
  end

  def test_index
    opts = {:controller => "admin/home", :action => "index"}
    assert_recognizes(opts, "/admin")
  end
end