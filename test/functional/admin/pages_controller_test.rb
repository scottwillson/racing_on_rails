require File.expand_path("../../../test_helper", __FILE__)

# :stopdoc:
class Admin::PagesControllerTest < ActionController::TestCase
  def setup
    super
    create_administrator_session
    use_ssl
  end
  
  assert_no_angle_brackets :except => [ :test_edit_page ]

  def test_only_admins_can_edit_pages
    destroy_person_session
    get(:index)
    assert_redirected_to new_person_session_url(secure_redirect_options)
  end
  
  def test_view_pages_as_tree
    get(:index)
    assert_response(:success)
  end
  
  def test_update_title_inplace
    page = FactoryGirl.create(:page)
    xhr(:put, :update_attribute, 
        :id => page.to_param,
        :value => "OBRA Banquet",
        :name => "title"
    )
    assert_response(:success)
    assert_template(nil)
    assert_equal(page, assigns("page"), "@page")
    page.reload
    assert_equal("OBRA Banquet", page.title, "Page title")
    assert_equal(@administrator, page.last_updated_by, "updated_by")
  end
  
  def test_edit_page
    page = FactoryGirl.create(:page)
    get(:edit, :id => page.id)
  end
  
  def test_update_page
    page = FactoryGirl.create(:page)
    put(:update, 
        :id => page.to_param,
        :page => {
          :title => "My Awesome Bike Racing Page",
          :body => "<blink>Race</blink>",
          :parent_id => nil
        }
    )
    assert_redirected_to(edit_admin_page_path(page))
    page.reload
    assert_equal("My Awesome Bike Racing Page", page.title, "title")
    assert_equal("<blink>Race</blink>", page.body, "body")
    assert_equal(@administrator, page.last_updated_by, "updated_by")
  end
  
  def test_update_page_parent
    parent_page = Page.create!(:title => "Root")
    page = FactoryGirl.create(:page)
    put(:update,
        :id => page.to_param,
        :page => {
          :title => "My Awesome Bike Racing Page",
          :body => "<blink>Race</blink>",
          :parent_id => parent_page.to_param
        }
    )
    page.reload
    assert_equal("My Awesome Bike Racing Page", page.title, "title")
    assert_equal("<blink>Race</blink>", page.body, "body")
    assert_equal(@administrator, page.last_updated_by, "updated_by")
    assert_equal(parent_page, page.parent, "Page parent")
    assert_redirected_to(edit_admin_page_path(page))
  end
  
  def test_new_page
    get(:new)
  end
  
  def test_new_page_parent
    parent_page = FactoryGirl.create(:page)
    get(:new, :page => { :parent_id => parent_page.to_param })
    page = assigns(:page)
    assert_not_nil(page, "@page")
    assert_equal(parent_page, page.parent, "New page parent")
  end
  
  def test_create_page
    put(:create, 
        :page => {
          :title => "My Awesome Bike Racing Page",
          :body => "<blink>Race</blink>"          
        }
    )
    page = Page.find_by_title("My Awesome Bike Racing Page")
    assert_redirected_to(edit_admin_page_path(page))
    page.reload
    assert_equal("My Awesome Bike Racing Page", page.title, "title")
    assert_equal("<blink>Race</blink>", page.body, "body")
    assert_equal(@administrator, page.last_updated_by, "updated_by")
  end
  
  def test_create_child_page
    parent_page = FactoryGirl.create(:page)
    post(:create, 
        :page => {
          :title => "My Awesome Bike Racing Page",
          :body => "<blink>Race</blink>",
          :parent_id => parent_page.to_param
        }
    )
    page = Page.find_by_title("My Awesome Bike Racing Page")
    assert_redirected_to(edit_admin_page_path(page))
    page.reload
    assert_equal("My Awesome Bike Racing Page", page.title, "title")
    assert_equal("<blink>Race</blink>", page.body, "body")
    assert_equal(@administrator, page.last_updated_by, "updated_by")
    assert_equal(parent_page, page.parent, "Page parent")
  end
  
  def test_delete_page
    page = FactoryGirl.create(:page)
    delete(:destroy, :id => page.to_param)
    assert_redirected_to(admin_pages_path)
    assert(!Page.exists?(page.id), "Page should be deleted")
  end
  
  def test_delete_parent_page
    page = FactoryGirl.create(:page)
    page.children.create!
    page.reload
    delete(:destroy, :id => page.to_param)
    assert_redirected_to(admin_pages_path)
    assert(!Page.exists?(page.id), "Page should be deleted")
  end
  
  def test_delete_child_page
    page = FactoryGirl.create(:page).children.create!
    delete(:destroy, :id => page.to_param)
    assert_redirected_to(admin_pages_path)
    assert(!Page.exists?(page.id), "Page should be deleted")
  end
end
