require "acceptance/webdriver_test_case"

class CategoriesTest < WebDriverTestCase
  def test_edit
    login_as :administrator

    open "/admin/categories"

    masters_35_plus_id = Category.find_by_name("Masters 35+").id
    assert_element :tag_name => "div"
    assert_element :css => "div#unknown_category_root div#category_#{masters_35_plus_id}"
    assert_no_element :css => "div#category_root div#category_#{masters_35_plus_id}"

    drag_and_drop_by(-400, 116, :css => "div#unknown_category_root div#category_#{masters_35_plus_id}")
    wait_for_no_element :css => "div#unknown_category_root div#category_#{masters_35_plus_id}"
    wait_for_element :css => "div#category_root div#category_#{masters_35_plus_id}"
    assert_element :css => "div#category_root div#category_#{masters_35_plus_id}"
  end
end