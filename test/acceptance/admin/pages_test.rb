require "acceptance/selenium_test_case"

class PagesTest < SeleniumTestCase
  def test_pages
    # Check public page render OK with default static templates
    open "/schedule"
    assert_text "regex:Schedule|Calendar"
    assert_no_text "This year is cancelled"
    assert_title "regex:Schedule|Calendar"

    # Now change the page
    login_as :administrator

    open "/admin/pages"

    click "css=a[href='/admin/pages/new']", :wait_for => :page

    type "page_title", "Schedule"
    type "page_body", "This year is cancelled"

    click "save", :wait_for => :page

    open "/schedule"
    assert_text "This year is cancelled"

    open "/admin/pages"

    assert_table "pages_table", 2, 0, "glob:Schedule*"

    # Create new page
    # 404 first
    open "/officials", :assert => :error
    assert_text "ActiveRecord::RecordNotFound"

    open "/admin/pages"

    click "css=a[href='/admin/pages/new']", :wait_for => :page

    type "page_title", "Officials Home Phone Numbers"
    type "page_slug", "officials"
    type "page_body", "411 911"

    click "save", :wait_for => :page

    open "/officials"
    assert_text "411 911"
  end
end