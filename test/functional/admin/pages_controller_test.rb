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
    assert_redirected_to(new_person_session_url(secure_redirect_options))
  end
  
  def test_view_pages_as_tree
    get(:index)
    assert_response(:success)
  end
  
  def test_update_title_inplace
    page = pages(:plain)
    post(:set_page_title, 
        :id => page.to_param,
        :value => "OBRA Banquet",
        :editorId => "page_#{page.id}_name"
    )
    assert_response(:success)
    assert_template(nil)
    assert_equal(page, assigns("item"), "@page")
    page.reload
    assert_equal("OBRA Banquet", page.title, "Page title")
    assert_equal(people(:administrator), page.author, "author")
  end
  
  def test_edit_page
    page = pages(:plain)
    get(:edit, :id => page.id)
  end
  
  def test_update_page
    page = pages(:plain)
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
    assert_equal(people(:administrator), page.author, "author")
  end
  
  def test_update_page_parent
    parent_page = Page.create!(:title => "Root")
    page = pages(:plain)
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
    assert_equal(people(:administrator), page.author, "author")
    assert_equal(parent_page, page.parent, "Page parent")
    assert_redirected_to(edit_admin_page_path(page))
  end
  
  def test_new_page
    get(:new)
  end
  
  def test_new_page_parent
    parent_page = pages(:plain)
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
    assert_equal(people(:administrator), page.author, "author")
  end
  
  def test_create_child_page
    parent_page = pages(:plain)
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
    assert_equal(people(:administrator), page.author, "author")
    assert_equal(parent_page, page.parent, "Page parent")
  end
  
  def test_delete_page
    page = pages(:plain)
    delete(:destroy, :id => page.to_param)
    assert_redirected_to(admin_pages_path)
    assert(!Page.exists?(page.id), "Page should be deleted")
  end
  
  def test_delete_parent_page
    page = pages(:plain)
    page.children.create!
    page.reload
    delete(:destroy, :id => page.to_param)
    assert_redirected_to(admin_pages_path)
    assert(!Page.exists?(page.id), "Page should be deleted")
  end
  
  def test_delete_child_page
    page = pages(:plain).children.create!
    delete(:destroy, :id => page.to_param)
    assert_redirected_to(admin_pages_path)
    assert(!Page.exists?(page.id), "Page should be deleted")
  end
end
