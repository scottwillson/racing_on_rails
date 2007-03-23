require File.dirname(__FILE__) + '/../test_helper'

class CategoryTest < Test::Unit::TestCase
  
  def test_find
    category = Category.find_bar('Category 4 Women')
    assert_kind_of(Category, category)
    assert_equal("Category 4 Women", category.name, "name")
    assert_equal("BAR", category.scheme, "name")
    assert(category.is_overall?, "overall")
    category = Category.find_bar("Category 4 Women")
    assert_equal(category, category.overall, "Overall BAR cat for Women 4")
  end
  
  def test_bar_category
    category = Category.find_with_bar("Men A")
    assert_kind_of(Category, category)
    assert_equal("Men A", category.name, "name")
    assert_equal(ASSOCIATION.short_name, category.scheme, "name")
    assert(!category.is_overall?, "overall")
    bar_category = category.bar_category
    assert_not_nil(bar_category, "BAR category")
  end
  
  def test_include
    category = Category.create(:name => 'Sandbaggers')
    assert(category.include?(category), 'category should include itself')
    assert(!category.include?(nil), 'category should not include nil')
    assert(!category.include?(categories(:senior_men)), 'category should not include Senior Men')
    
    competition_category = competition_categories.create(:source_category => senior_men)
    assert(category.include?(category), 'category should still include itself')
    assert(category.include?(competition_category), 'category should include senior men')
  end
end
