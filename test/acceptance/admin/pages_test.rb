require File.expand_path(File.dirname(__FILE__) + "/../acceptance_test")

# :stopdoc:
class PagesTest < AcceptanceTest
  def test_pages
    # Check public page render OK with default static templates
    visit "/schedule"
    assert_page_has_content("Schedule")
    
    assert_page_has_no_content "This year is cancelled"
    assert_page_has_content("Schedule")

    # Now change the page
    login_as FactoryGirl.create(:administrator)

    visit "/admin/pages"

    find(:xpath, "//a[@href='/admin/pages/new']").click

    fill_in "page_title", :with => "Schedule"
    fill_in "page_body", :with => "This year is cancelled"

    click_button "Save"

    visit "/schedule"
    assert_page_has_content "This year is cancelled"

    visit "/admin/pages"

    assert_table("pages_table", 1, 0, /^Schedule/)

    # Create new page
    # 404 first
    visit "/officials"
    assert_page_has_content "Couldn't find Page"

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