require File.expand_path("../../../test_helper", __FILE__)

# :stopdoc:
class Admin::VelodromesControllerTest < ActionController::TestCase
  def setup
    super
    create_administrator_session
    use_ssl
  end
  
  def test_not_logged_in_index
    destroy_person_session
    get(:index)
    assert_redirected_to new_person_session_url(secure_redirect_options)
    assert_nil(@request.session["person"], "No person in session")
  end

  def test_index
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
    assert(!Velodrome.exists?(velodrome.id), "Should delete velodrome")
    assert_not_nil(flash[:notice], "Should have flash :notice")
  end

  def test_update_name
    velodrome = velodromes(:alpenrose)
    xhr(:put,
        :update_attribute,
        :id => velodrome.to_param,
        :value => "Paul Allen Velodrome",
        :name => "name"
    )
    assert_response(:success)
    velodrome.reload
    assert_equal("Paul Allen Velodrome", velodrome.name, "Velodrome name should change after update")
  end

  def test_update_website
    velodrome = velodromes(:alpenrose)
    xhr(:put,
        :update_attribute,
        :id => velodrome.to_param,
        :value => "www.raceatra.com",
        :name => "website"
    )
    assert_response(:success)
    velodrome.reload
    assert_equal("www.raceatra.com", velodrome.website, "Velodrome website should change after update")
  end
end
