require "acceptance/webdriver_test_case"

class PagesTest < WebDriverTestCase
  def test_pages
    # Check public page render OK with default static templates
    open "/schedule"
    assert_page_source(/Schedule|Calendar/)
    assert_not_in_page_source "This year is cancelled"
    assert_title(/Schedule|Calendar/)

    # Now change the page
    login_as :administrator

    open "/admin/pages"

    click :xpath => "//a[@href='/admin/pages/new']"

    type "Schedule", "page_title"
    type "This year is cancelled", "page_body"

    click "save"

    open "/schedule"
    assert_page_source "This year is cancelled"

    open "/admin/pages"

    assert_table("pages_table", 2, 0, /^Schedule/)

    # Create new page
    # 404 first
    open "/officials", true
    assert_page_source "ActiveRecord::RecordNotFound"

    open "/admin/pages"

    click :xpath => "//a[@href='/admin/pages/new']"

    type "Officials Home Phone Numbers", "page_title"
    type "officials", "page_slug"
    type "411 911", "page_body"

    click "save"

    open "/officials"
    assert_page_source "411 911"
  end
end