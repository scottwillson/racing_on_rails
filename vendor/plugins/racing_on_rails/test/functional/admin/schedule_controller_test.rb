require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/schedule_controller'

class Admin::ScheduleController
  def rescue_action(e) raise e end
end

# TODO More elegant way to handle this?
module Admin::ScheduleHelper
 include ActionView::Helpers::UrlHelper
 include ERB::Util
end

class AdminScheduleControllerTest < Test::Unit::TestCase
  
  fixtures :promoters, :events, :aliases_disciplines, :disciplines, :users

  include Admin::ScheduleHelper
  
  def setup
    @controller = Admin::ScheduleController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.host = "localhost"
  end

  def test_admin_index
    opts = {:controller => "admin/schedule", :action => "index"}
    assert_routing("/admin", opts)
  end
  
  def test_index
    @request.session[:user] = users(:candi)
    opts = {:controller => "admin/schedule", :action => "index", :year => "2004"}
    assert_routing("/admin/schedule/2004", opts)
    get(:index, :year => "2004")
    assert_response(:success)
    assert_template("admin/schedule/index")
    assert_not_nil(assigns["schedule"], "Should assign schedule")
  end
  
  def test_not_logged_in
    get(:index, :year => "2004")
    assert_response(:redirect)
    assert_redirect_url "http://localhost/admin/account/login"
    assert_nil(@request.session["user"], "No user in session")
  end
  
  def test_links_to_years
    get(:index, :year => "2004")
    html = links_to_years
    assert_match('href="/admin/schedule/2003', html, 'Should link to 2003')
    assert_match('href="/admin/schedule/2004', html, 'Should link to 2004')
    assert_match('href="/admin/schedule/2005', html, 'Should link to 2005')
  end
end
