# frozen_string_literal: true

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

  test "depth" do
    page = FactoryBot.create(:page)
    assert_equal(0, page.depth, "depth")

    child = page.children.create!(body: "<h2>Child</h2>", title: "Child")
    assert_equal(1, child.depth, "depth")

    child_child = child.children.create!(body: "<h2>Child</h2>", title: "Child")
    assert_equal(2, child_child.depth, "depth")
  end

  test "Do not update path or slug when title changes" do
    page = FactoryBot.create(:page)
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

  test "update updated at if child changes" do
    parent = FactoryBot.create(:page)
    updated_at = parent.updated_at

    child = nil
    Timecop.freeze(Time.zone.now.tomorrow) do
      admin = FactoryBot.create(:administrator)
      Person.current = admin
      child = parent.children.create!(title: "New Page", body: "Original content")
      assert parent.reload.updated_at > updated_at, "New child should updated updated_at"
      updated_at = parent.updated_at

      child.title = "New Title"
      child.save!
      assert_equal(updated_at, parent.reload.updated_at, "New child update title should not updated updated_at")

      # Go down to the SQL to avoid all the magic
      Page.connection.execute("update pages set updated_at='2009-01-01' where id=#{parent.id}")
      parent.reload
      updated_at = parent.updated_at
    end

    Timecop.freeze(3.days.from_now) do
      assert child.destroy, "Child destroy returned false. #{child.errors.full_messages.join(', ')}"
      assert child.destroyed?, "Should have destroyed page. #{child.errors.full_messages.join(', ')}"
      assert(parent.reload.updated_at > updated_at, "Parent should updated updated_at after child destroyed")
    end
  end
end
