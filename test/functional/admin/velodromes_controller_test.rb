require File.dirname(__FILE__) + '/../../test_helper'

# :stopdoc:
class Admin::VelodromesControllerTest < ActionController::TestCase
  
  def setup
    @request.session[:user] = users(:administrator).id
  end
  
  def test_not_logged_in_index
    @request.session[:user] = nil
    get(:index)
    assert_response(:redirect)
    assert_redirected_to(:controller => '/account', :action => 'login')
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
  
  def test_destroy
    velodrome = velodromes(:trexlertown)
    delete :destroy, :id => velodrome.id
    assert_response(:redirect)
    assert(!Velodrome.exists?(velodrome.id), "Should delete velodrome")
    assert_not_nil(flash[:notice], "Should have flash :notice")
  end

  def test_update_name
    velodrome = velodromes(:alpenrose)
    post(:set_velodrome_name, 
        :id => velodrome.to_param,
        :value => "Paul Allen Velodrome",
        :editorId => "velodrome_#velodrome.id}_name"
    )
    assert_response(:success)
    velodrome.reload
    assert_equal("Paul Allen Velodrome", velodrome.name, "Velodrome name should change after update")
  end

  def test_update_website
    velodrome = velodromes(:alpenrose)
    post(:set_velodrome_website, 
        :id => velodrome.to_param,
        :value => "www.raceatra.com",
        :editorId => "velodrome_#velodrome.id}_website"
    )
    assert_response(:success)
    velodrome.reload
    assert_equal("www.raceatra.com", velodrome.website, "Velodrome website should change after update")
  end
end
