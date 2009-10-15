# :stopdoc:
require "test_helper"

class Admin::HomeControllerTest < ActionController::TestCase
  setup :create_administrator_session, :use_ssl

  def test_index
    opts = {:controller => "admin/home", :action => "index"}
    assert_recognizes(opts, "/admin")
  end
end