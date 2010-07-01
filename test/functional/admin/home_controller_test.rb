# :stopdoc:
require File.expand_path("../../../test_helper", __FILE__)

class Admin::HomeControllerTest < ActionController::TestCase
  def setup
    super
    create_administrator_session
    use_ssl
  end

  def test_index
    opts = {:controller => "admin/home", :action => "index"}
    assert_recognizes(opts, "/admin")
  end
end
