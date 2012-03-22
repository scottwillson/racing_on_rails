require File.expand_path(File.dirname(__FILE__) + "/../acceptance_test")

# :stopdoc:
class CategoriesTest < AcceptanceTest
  def test_edit
    association = FactoryGirl.create(:category, :name => "CBRA")
    masters_35_plus = FactoryGirl.create(:category, :name => "Masters 35+")
    women_4 = FactoryGirl.create(:category, :name => "Women 4", :parent => association)
    login_as FactoryGirl.create(:administrator)

    visit "/admin/categories"

    assert page.has_selector? ".unknown_category_root #category_#{masters_35_plus.id}"
    assert page.has_no_selector? ".association_category_root #category_#{masters_35_plus.id}"

    find("#category_#{masters_35_plus.id}").drag_to(find(".association_category_root"))
    assert page.has_selector? ".association_category_root #category_#{masters_35_plus.id}"
    assert page.has_no_selector? ".unknown_category_root #category_#{masters_35_plus.id}"

    assert page.has_selector? ".association_category_root #category_#{women_4.id}"
    assert page.has_no_selector? ".unknown_category_root #category_#{women_4.id}"

    find("#category_#{women_4.id}").drag_to(find(".unknown_category_root"))
    assert page.has_selector? ".unknown_category_root #category_#{women_4.id}"
    assert page.has_no_selector? ".association_category_root #category_#{women_4.id}"
  end
end
