# :stopdoc:
require File.dirname(__FILE__) + '/../../test_helper'

class Admin::HomeControllerTest < ActionController::TestCase
  def setup
    super
    @request.session[:user] = users(:administrator).id
  end

  def test_index
    opts = {:controller => "admin/home", :action => "index"}
    assert_recognizes(opts, "/admin")
  end
end