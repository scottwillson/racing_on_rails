require File.dirname(__FILE__) + '/../test_helper'

class CategoryTest < Test::Unit::TestCase
  fixtures :teams, :aliases, :promoters, :categories
  
  def test_find
    category = Category.find_bar("Women 4")
    assert_kind_of(Category, category)
    assert_equal("Women 4", category.name, "name")
    assert_equal("BAR", category.scheme, "name")
    assert(category.is_overall?, "overall")
    category = Category.find_bar("Women 4")
    assert_equal(category, category.overall, "Overall BAR cat for Women 4")
  end
  
  def test_bar_category
    category = Category.find_obra_with_bar("Men A")
    assert_kind_of(Category, category)
    assert_equal("Men A", category.name, "name")
    assert_equal("OBRA", category.scheme, "name")
    assert(!category.is_overall?, "overall")
    bar_category = category.bar_category
    assert_not_nil(bar_category, "BAR category")
  end
end
