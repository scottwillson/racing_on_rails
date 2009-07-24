require "acceptance/selenium_test_case"

class CategoriesTest < SeleniumTestCase
  def test_popular_pages
    login_as_admin

    open "/admin/categories"

    masters_35_plus_id = Category.find_by_name("Masters 35+").id
    assert_present "css=div#unknown_category_root div#category_#{masters_35_plus_id}"
    assert_not_present "css=div#category_root div#category_#{masters_35_plus_id}"

    drag_and_drop "css=div#unknown_category_root div#category_#{masters_35_plus_id}", "-400,116"
    wait_for_no_element "css=div#unknown_category_root div#category_#{masters_35_plus_id}"
    wait_for_element "css=div#category_root div#category_#{masters_35_plus_id}"
    assert_present "css=div#category_root div#category_#{masters_35_plus_id}"
  end
end