require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/schedule_controller'

# :stopdoc:
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
    assert_recognizes(opts, "/admin")
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

  def test_upload_schedule
    @request.session[:user] = users(:candi)
        
    file = uploaded_file("schedule.xls", "application/vnd.ms-excel")
    opts = {
      :controller => "admin/schedule", 
      :action => "upload"
    }
    assert_routing("/admin/schedule/upload", opts)

    before_import_after_schedule_start_date = Event.count("date > '2005-01-01'")
    assert_equal(7, before_import_after_schedule_start_date, "2005 events count before import")
    before_import_all = Event.count
    assert_equal(14, before_import_all, "All events count before import")

    post :upload, :schedule_file => file

    assert(!flash.has_key?(:warn), "flash[:warn] should be empty,  but was: #{flash[:warn]}")
    assert_response :redirect
    assert_redirected_to(:action => :index, :year => 2006)
    assert(flash.has_key?(:notice))

    after_import_after_schedule_start_date = Event.count("date > '2005-01-01'")
    assert_equal(83, after_import_after_schedule_start_date, "2005 events count after import")
    after_import_all = Event.count
    assert_equal(90, after_import_all, "All events count after import")
  end
  
  # TODO dupe methods
  private

  def uploaded_file(filename, content_type)
    t = Tempfile.new(filename);
    t.binmode
    path = RAILS_ROOT + "/vendor/plugins/racing_on_rails/test/fixtures/" + filename
    FileUtils.copy_file(path, t.path)
    (class << t; self; end).class_eval do
      alias local_path path
      define_method(:original_filename) {filename}
      define_method(:content_type) {content_type}
    end
    return t
  end
end
