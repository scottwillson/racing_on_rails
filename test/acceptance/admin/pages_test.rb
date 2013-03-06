require File.expand_path(File.dirname(__FILE__) + "/../acceptance_test")

# :stopdoc:
class PagesTest < AcceptanceTest
  setup :javascript!

  def test_pages
    login_as FactoryGirl.create(:administrator)

    visit "/admin/pages"

    find(:xpath, "//a[@href='/admin/pages/new']").click

    fill_in "page_title", :with => "Schedule"
    fill_in "page_body", :with => "This year is cancelled"

    click_button "Save"
    page = Page.last
    assert_equal "Schedule", page.title, "New page title"
    assert_equal "schedule", page.path, "New page path"
    assert_equal "schedule", page.slug, "New page slug"

    visit "/schedule"
    assert_page_has_content "This year is cancelled"

    visit "/admin/pages"

    assert_table "pages_table", 2, 1, "Schedule"

    # Create new page
    # 404 first
    visit "/officials"
    assert_page_has_content "No route matches"

    visit "/admin/pages"

    find(:xpath, "//a[@href='/admin/pages/new']").click

    fill_in "page_title", :with => "Officials Home Phone Numbers"
    fill_in "page_slug", :with => "officials"
    fill_in "page_body", :with => "411 911"

    click_button "Save"

    visit "/officials"
    assert_page_has_content "411 911"
  end
end