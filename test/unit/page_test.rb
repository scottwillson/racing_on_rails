File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class PageTest < ActiveSupport::TestCase
  test "create" do
    page = Page.create!(:title => "Simple", :body => "This is a simple page")
    assert_equal("Simple", page.title, "title")
    assert_equal("This is a simple page", page.body, "body")
    assert_equal("simple", page.path, "path")
    assert_equal("simple", page.slug, "slug")
  end
  
  test "set nested path for child pages" do
    root = Page.create!(:body => "<h1>Welcome</h1>", :title => "")
  
    child = root.children.create!(:body => "<h2>Child</h2>", :title => "women")
    assert_equal("women", child.path, "path")
  
    child_child = child.children.create!(:body => "<h3>Nested</h3>", :title => "FAQ")
    assert_equal("women/faq", child_child.path, "path")
  
    child_child_child = child_child.children.create!(:body => "<h3>Russian Dolls</h3>", :title => "Cat4")
    assert_equal("women/faq/cat4", child_child_child.path, "path")
  end
  
  test "not allow circular relationships" do
    parent = Page.create!(:body => "<h1>Welcome</h1>", :title => "")
    child = parent.children.create!(:body => "<h2>Child</h2>", :title => "Child")
    assert_raise(ActiveRecord::Acts::Tree::CircularAssociation, "Should not be able to add parent as child") { child.children << parent }
    assert(!child.children(true).include?(parent), "Should not be able to add parent as child")
  end
  
  test "depth" do
    assert_equal(0, pages(:plain).depth, "depth")
  
    child = pages(:plain).children.create!(:body => "<h2>Child</h2>", :title => "Child")
    assert_equal(1, child.depth, "depth")
  
    child_child = child.children.create!(:body => "<h2>Child</h2>", :title => "Child")
    assert_equal(2, child_child.depth, "depth")
  end
  
  test "author" do
    page = Page.create!(:body => "<h1>Welcome</h1>", :title => "", :author => people(:administrator))
    assert_equal(people(:administrator), page.author, "author")
  end
  
  test "Root page valid_parents" do
    assert_equal([], pages(:plain).valid_parents, "valid_parents")
  end
  
  test "Parent-child pages valid_parents" do
    parent = pages(:plain)
    child = parent.children.create!(:title => "child")
    assert_equal([], parent.valid_parents, "parent valid_parents")
    assert_equal([parent], child.valid_parents, "child valid_parents")
  end
  
  test "Many roots valid_parents" do
    parent = pages(:plain)
    child = parent.children.create!(:title => "child")
    another_root = Page.create!(:title => "Another root")
    
    assert_same_elements([another_root], parent.valid_parents, "parent valid_parents")
    assert_same_elements([parent, another_root], child.valid_parents, "child valid_parents")
    assert_same_elements([parent, child], another_root.valid_parents, "another_root valid_parents")
  end
  
  test "Do not update path or slug when title changes" do
    page = pages(:plain)
    page.title = "Super Fun"
    page.save!
    assert_equal("plain", page.path, "title")
    assert_equal("plain", page.slug, "slug")
  end
  
  def test_do_not_override_slug
    page = Page.create!(:title => "Title", :slug => "slug")
    assert_equal("Title", page.title, "title")
    assert_equal("slug", page.slug, "slug")
  end
  
  test "Versions updated on create and save" do
    parent = pages(:plain)
    admin = people(:administrator)
    page = parent.children.create!(:title => "New Page", :body => "Original content", :author => admin)
    
    assert_equal("New Page", page.title, "title")
    assert_equal("new_page", page.slug, "slug")
    assert_equal("plain/new_page", page.path, "path")
    assert_equal("Original content", page.body, "body")
    assert_equal(admin, page.author, "author")
    assert_equal(1, page.version, "version")
    
    page.body = "New content"
    page.save!
  
    assert_equal("New Page", page.title, "title")
    assert_equal("new_page", page.slug, "slug")
    assert_equal("plain/new_page", page.path, "path")
    assert_equal("New content", page.body, "body")
    assert_equal(admin, page.author, "author")
    assert_equal(2, page.version, "version")
    
    original = page.versions.earliest
    assert_equal("New Page", original.title, "title")
    assert_equal("new_page", original.slug, "slug")
    assert_equal("plain/new_page", original.path, "path")
    assert_equal("Original content", original.body, "body")
    assert_equal(admin.id, original.author_id, "author")
    assert_equal(1, original.lock_version, "version")
    
    latest = page.versions.latest
    assert_equal("New Page", latest.title, "title")
    assert_equal("new_page", latest.slug, "slug")
    assert_equal("plain/new_page", latest.path, "path")
    assert_equal("New content", latest.body, "body")
    assert_equal(admin.id, latest.author_id, "author")
    assert_equal(2, latest.lock_version, "version")
  end
  
  test "Versions updated on update_attributes" do
    parent = pages(:plain)
    admin = people(:administrator)
    page = parent.children.create!(:title => "New Page", :body => "Original content", :author => admin)

    new_person = Person.create!(:name => "New Person", :password => "foobar123", :password_confirmation => "foobar123", :email => "person@example.com")
    new_parent = Page.create!(:title => "Root")
    page.author = new_person
    assert(page.update_attributes(:parent_id => new_parent.id, :title => "Revised Title", :body => "Revised content"), "Updated")
    
    assert_equal(new_parent.id, page.parent_id, "parent_id")
    assert_equal("Revised Title", page.title, "title")
    assert_equal("new_page", page.slug, "slug")
    assert_equal("root/new_page", page.path, "path")
    assert_equal("Revised content", page.body, "body")
    assert_equal(new_person.id, page.author_id, "author")
    assert_equal(2, page.lock_version, "version")
    
    original = page.versions.earliest
    assert_equal(parent.id, original.parent_id, "parent_id")
    assert_equal("New Page", original.title, "title")
    assert_equal("new_page", original.slug, "slug")
    assert_equal("plain/new_page", original.path, "path")
    assert_equal("Original content", original.body, "body")
    assert_equal(admin.id, original.author_id, "author")
    assert_equal(1, original.lock_version, "version")
  end
  
  def test_update_updated_at_if_child_changes
    parent = pages(:plain)
    updated_at = parent.updated_at
    
    child = parent.children.create!(:title => "New Page", :body => "Original content", :author => people(:administrator))
    assert_equal(1, parent.versions.size, "versions")
    assert(parent.reload.updated_at > updated_at, "New child should updated updated_at")
    updated_at = parent.updated_at
    
    child.title = "New Title"
    child.save!
    assert_equal(1, parent.versions.size, "versions")
    assert_equal(updated_at, parent.reload.updated_at, "New child update title should not updated updated_at")

    # Go down to the SQL to avoid all the magic
    Page.connection.execute("update pages set updated_at='2009-01-01' where id=#{parent.id}")
    parent.reload
    updated_at = parent.updated_at

    child.destroy
    assert_equal(1, parent.versions.size, "versions")
    assert(parent.reload.updated_at > updated_at, "Parent should updated updated_at after child destroyed")
  end
end
