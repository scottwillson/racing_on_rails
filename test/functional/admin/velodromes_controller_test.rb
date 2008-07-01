require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/velodromes_controller'

# :stopdoc:
class Admin::VelodromesController; def rescue_action(e) raise e end; end

class Admin::VelodromesControllerTest < ActiveSupport::TestCase
  
  def setup
    @controller = Admin::VelodromesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.host = "localhost"
    @request.session[:user] = users(:candi)
  end
  
  def test_not_logged_in_index
    @request.session[:user] = nil
    get(:index)
    assert_response(:redirect)
    assert_redirected_to(:controller => '/admin/account', :action => 'login')
    assert_nil(@request.session["user"], "No user in session")
  end

  def test_index
    opts = {:controller => "admin/velodromes", :action => "index"}
    assert_routing("/admin/velodromes", opts)
    
    get(:index)
    assert_response(:success)
    assert_template("admin/velodromes/index")
    assert_not_nil(assigns["velodromes"], "Should assign velodromes")
    assert(!assigns["velodromes"].empty?, "Should have no velodromes")
  end
  
  def test_new
    get(:new)
    assert_response(:success)
    assert_not_nil(assigns["velodrome"], "Should assign velodrome")
  end
  
  def test_create
    post(:create, :velodrome => { :name => "Hellyer", :website => "www.hellyer.org" })
    velodrome = Velodrome.find_by_name("Hellyer")
    assert_not_nil(velodrome, "Should create new Velodrome")
    assert_equal("www.hellyer.org", velodrome.website, "website")
    assert_redirected_to(new_admin_velodrome_path)
    assert_not_nil(flash[:notice], "Should have flash :notice")
    assert_nil(flash[:warn], "Should have flash :warn")
  end
  
  def test_edit
    velodrome = velodromes(:trexlertown)
    get(:edit, :id => velodrome.id)
    assert_response(:success)
    assert_equal(velodrome, assigns["velodrome"], "Should assign velodrome")
  end
  
  def test_update
    velodrome = velodromes(:trexlertown)
    put(:update, :id => velodrome.id, :velodrome => { :name => "T Town", :website => "www" })
    assert_redirected_to(edit_admin_velodrome_path(velodrome))
    velodrome.reload
    assert_equal("T Town", velodrome.name, "Name should be updated")
    assert_equal("www", velodrome.website, "Websit should be updated")
  end
  
  def test_remote_destroy
    velodrome = velodromes(:trexlertown)
    delete :destroy, :id => velodrome.id, :format => "js"
    assert_response(:success)
    assert(!Velodrome.exists?(velodrome.id), "Should delete velodrome")
  end
  
  def test_destroy
    velodrome = velodromes(:trexlertown)
    delete :destroy, :id => velodrome.id
    assert_response(:redirect)
    assert(!Velodrome.exists?(velodrome.id), "Should delete velodrome")
    assert_not_nil(flash[:notice], "Should have flash :notice")
  end

  def test_edit_name
    velodrome = velodromes(:alpenrose)
    get(:edit_name, :id => velodrome.to_param)
    assert_response(:success)
    assert_template("admin/velodromes/_edit_name")
    assert_equal(velodrome, assigns["velodrome"], "Should assign velodrome")
  end

  def test_cancel_edit_name
    velodrome = velodromes(:alpenrose)
    original_name = velodrome.name
    get(:test_cancel_edit_name, :id => velodrome.to_param, :name => velodrome.name)
    assert_response(:success)
    assert_template("admin/velodromes/_name")
    assert_not_nil(assigns["velodrome"], "Should assign velodrome")
    assert_equal(velodrome, assigns['velodrome'], "Velodrome")
    velodrome.reload
    assert_equal(original_name, velodrome.name, "Velodrome name after cancel should not change")
  end

  def test_update_name
    velodrome = velodromes(:alpenrose)
    post(:update_name, :id => velodrome.to_param, :name => "Paul Allen Velodrome")
    assert_response(:success)
    assert_template("admin/velodromes/_name")
    assert_not_nil(assigns["velodrome"], "Should assign velodrome")
    assert_equal(velodrome, assigns['velodrome'], "Velodrome")
    velodrome.reload
    assert_equal("Paul Allen Velodrome", velodrome.name, "Velodrome name should change after update")
  end

  def test_edit_website
    velodrome = velodromes(:alpenrose)
    get(:edit_website, :id => velodrome.to_param)
    assert_response(:success)
    assert_template("admin/velodromes/_edit_website")
    assert_equal(velodrome, assigns["velodrome"], "Should assign velodrome")
  end

  def test_cancel_edit_website
    velodrome = velodromes(:alpenrose)
    original_website = velodrome.website
    get(:test_cancel_edit_website, :id => velodrome.to_param, :website => velodrome.website)
    assert_response(:success)
    assert_template("admin/velodromes/_website")
    assert_not_nil(assigns["velodrome"], "Should assign velodrome")
    assert_equal(velodrome, assigns['velodrome'], "Velodrome")
    velodrome.reload
    assert_equal(original_website, velodrome.website, "Velodrome website after cancel should not change")
  end

  def test_update_website
    velodrome = velodromes(:alpenrose)
    post(:update_website, :id => velodrome.to_param, :website => "www.raceatra.com")
    assert_response(:success)
    assert_template("admin/velodromes/_website")
    assert_not_nil(assigns["velodrome"], "Should assign velodrome")
    assert_equal(velodrome, assigns['velodrome'], "Velodrome")
    velodrome.reload
    assert_equal("www.raceatra.com", velodrome.website, "Velodrome website should change after update")
  end
end
