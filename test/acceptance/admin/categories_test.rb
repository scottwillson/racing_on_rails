require "acceptance/webdriver_test_case"

# :stopdoc:
class CategoriesTest < WebDriverTestCase
  def test_edit
    login_as :administrator

    open "/admin/categories"

    masters_35_plus_id = Category.find_by_name("Masters 35+").id
    assert_element    :css => "#unknown_category_root #category_#{masters_35_plus_id}"
    assert_no_element :css => "#association_category_root #category_#{masters_35_plus_id}"

    drag_and_drop_on "category_#{masters_35_plus_id}", "association_category_root"
    wait_for_element  :css => "#association_category_root #category_#{masters_35_plus_id}"
    assert_no_element :css => "#unknown_category_root #category_#{masters_35_plus_id}"

    women_4_id = Category.find_by_name("Women 4").id
    assert_element    :css => "#association_category_root #category_#{women_4_id}"
    assert_no_element :css => "#unknown_category_root #category_#{women_4_id}"

    drag_and_drop_by 400, 0, "category_#{women_4_id}"
    wait_for_element  :css => "#unknown_category_root #category_#{women_4_id}"
    assert_no_element :css => "#association_category_root #category_#{women_4_id}"
  end
end
