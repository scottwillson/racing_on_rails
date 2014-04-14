require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class PageTest < ActiveSupport::TestCase
  test "create" do
    page = Page.create!(title: "Simple", body: "This is a simple page")
    assert_equal("simple", page.path, "path")
    assert_equal("simple", page.slug, "slug")
  end

  test "set nested path for child pages" do
    root = Page.create!(body: "<h1>Welcome</h1>", title: "")

    child = root.children.create!(body: "<h2>Child</h2>", title: "women")
    assert_equal("women", child.path, "path")

    child_child = child.children.create!(body: "<h3>Nested</h3>", title: "FAQ")
    assert_equal("women/faq", child_child.path, "path")

    child_child_child = child_child.children.create!(body: "<h3>Russian Dolls</h3>", title: "Cat4")
    assert_equal("women/faq/cat4", child_child_child.path, "path")
  end

  test "not allow circular relationships" do
    parent = Page.create!(body: "<h1>Welcome</h1>", title: "")
    child = parent.children.create!(body: "<h2>Child</h2>", title: "Child")
    assert !(parent.children << parent)
    assert parent.errors.present?
    assert(!child.children(true).include?(parent), "Should not be able to add parent as child")
  end

  test "depth" do
    page = FactoryGirl.create(:page)
    assert_equal(0, page.depth, "depth")

    child = page.children.create!(body: "<h2>Child</h2>", title: "Child")
    assert_equal(1, child.depth, "depth")

    child_child = child.children.create!(body: "<h2>Child</h2>", title: "Child")
    assert_equal(2, child_child.depth, "depth")
  end

  test "updated_by_person" do
    administrator = FactoryGirl.create(:administrator)
    Person.current = administrator
    page = Page.create!(body: "<h1>Welcome</h1>", title: "")
    page.versions(true)
    assert_equal(administrator, page.created_by, "created_by")
    assert_equal(administrator, page.updated_by_person, "updated_by_person")
  end

  test "Root page valid_parents" do
    page = FactoryGirl.create(:page)
    assert_equal([], page.valid_parents, "valid_parents")
  end

  test "Parent-child pages valid_parents" do
    parent = FactoryGirl.create(:page)
    child = parent.children.create!(title: "child")
    assert_equal([], parent.valid_parents, "parent valid_parents")
    assert_equal([parent], child.valid_parents, "child valid_parents")
  end

  test "Many roots valid_parents" do
    parent = FactoryGirl.create(:page)
    child = parent.children.create!(title: "child")
    another_root = Page.create!(title: "Another root")

    assert_same_elements([another_root], parent.valid_parents, "parent valid_parents")
    assert_same_elements([parent, another_root], child.valid_parents, "child valid_parents")
    assert_same_elements([parent, child], another_root.valid_parents, "another_root valid_parents")
  end

  test "Do not update path or slug when title changes" do
    page = FactoryGirl.create(:page)
    page.title = "Super Fun"
    page.save!
    assert_equal("plain", page.path, "title")
    assert_equal("plain", page.slug, "slug")
  end

  test "do not override slug" do
    page = Page.create!(title: "Title", slug: "slug")
    assert_equal("Title", page.title, "title")
    assert_equal("slug", page.slug, "slug")
  end

  test "Versions updated on create and save" do
    admin = FactoryGirl.create(:administrator)
    Person.current = admin
    parent = FactoryGirl.create(:page)
    page = parent.children.create!(title: "New Page", body: "Original content")

    assert_equal("New Page", page.title, "title")
    assert_equal("new_page", page.slug, "slug")
    assert_equal("plain/new_page", page.path, "path")
    assert_equal("Original content", page.body, "body")
    assert_equal(admin, page.created_by, "created_by")
    assert_equal(admin, page.updated_by_person, "updated_by_person")
    assert_equal(1, page.version, "version")

    page.body = "New content"
    page.save!

    assert_equal("New Page", page.title, "title")
    assert_equal("new_page", page.slug, "slug")
    assert_equal("plain/new_page", page.path, "path")
    assert_equal("New content", page.body, "body")
    assert_equal(admin, page.updated_by_person, "updated_by_person")
    assert_equal(2, page.version, "version")

    original = page.versions.first
    assert(original.changes.empty?, "original should have no changes")
    assert_equal(admin, original.user, "updated_by_person")

    last_version = page.versions.last
    assert_equal("Original content", last_version.changes["body"].first, "body in #{last_version.changes.inspect}")
    assert_equal("New content", last_version.changes["body"].last, "body in #{last_version.changes.inspect}")
    assert_equal admin, last_version.user, "version updated"
  end

  test "Versions updated on update_attributes" do
    parent = FactoryGirl.create(:page)
    admin = FactoryGirl.create(:administrator)
    Person.current = admin
    page = parent.children.create!(title: "New Page", body: "Original content")

    new_person = Person.create!(name: "New Person", password: "foobar123", password_confirmation: "foobar123", email: "person@example.com")
    new_parent = Page.create!(title: "Root")
    page.updated_by = nil
    Person.current = new_person
    assert_equal(1, page.versions.count, "versions")
    page.update_attributes! parent_id: new_parent.id, title: "Revised Title", body: "Revised content"

    assert_equal(2, page.versions.count, "versions")
    assert_equal(new_parent.id, page.parent_id, "parent_id")
    assert_equal("Revised Title", page.title, "title")
    assert_equal("new_page", page.slug, "slug")
    assert_equal("root/new_page", page.path, "path")
    assert_equal("Revised content", page.body, "body")
    assert_equal(new_person, page.updated_by_person, "updated_by_person")

    original = page.versions.second
    assert_equal(parent.id, original.changes["parent_id"].first, "parent_id in #{original.changes.inspect}, #{page.versions.last.changes.inspect}")
    assert_equal(new_parent.id, original.changes["parent_id"].last, "parent_id in #{original.changes.inspect}")
    assert_equal("New Page", original.changes["title"].first, "title")
    assert_equal("Original content", original.changes["body"].first, "body")
    assert_equal(admin, page.created_by, "created_by")
    assert_equal(new_person, page.updated_by_person, "updated_by_person")
  end

  test "update updated at if child changes" do
    parent = FactoryGirl.create(:page)
    updated_at = parent.updated_at

    child = nil
    Timecop.freeze(Time.zone.now.tomorrow) do
      admin = FactoryGirl.create(:administrator)
      Person.current = admin
      child = parent.children.create!(title: "New Page", body: "Original content")
      assert_equal(1, parent.versions.size, "versions")
      assert parent.reload.updated_at > updated_at, "New child should updated updated_at"
      updated_at = parent.updated_at

      child.title = "New Title"
      child.save!
      assert_equal(1, parent.versions.size, "versions")
      assert_equal(updated_at, parent.reload.updated_at, "New child update title should not updated updated_at")

      # Go down to the SQL to avoid all the magic
      Page.connection.execute("update pages set updated_at='2009-01-01' where id=#{parent.id}")
      parent.reload
      updated_at = parent.updated_at
    end

    Timecop.freeze(3.days.from_now) do
      assert child.destroy, "Child destroy returned false. #{child.errors.full_messages.join(", ")}"
      assert child.destroyed?, "Should have destroyed page. #{child.errors.full_messages.join(", ")}"
      assert_equal(1, parent.versions.size, "versions")
      assert(parent.reload.updated_at > updated_at, "Parent should updated updated_at after child destroyed")
    end
  end
end
