require File.dirname(__FILE__) + '/../test_helper'

class CategoryTest < Test::Unit::TestCase
  
  def test_include
    category = Category.create(:name => 'Sandbaggers')
    assert(category.include?(category), 'category should include itself')
    assert(!category.include?(nil), 'category should not include nil')
    assert(!category.include?(categories(:senior_men)), 'category should not include Senior Men')
    
    competition_category = category.competition_categories.create(:source_category => categories(:senior_men))
    assert(category.include?(category), 'category should still include itself')
    assert(category.include?(categories(:senior_men)), 'category should include senior men')
  end
  
  def test_acts_as_tree
    senior_men = Category.find_by_name('Senior Men')
    assert_equal(2, senior_men.children.size, 'Senior Men children')
  end
  
  def test_find_or_create_by_name
    existing_category = Category.create(:name => 'Pro Women')
    assert_not_nil(existing_category, 'Pro Women should exist')
    assert(!existing_category.new_record?, '!existing_category.new_record?')
    new_category = Category.find_or_create_by_name('Pro Women')
    assert_equal(existing_category, new_category, 'Should not create new category')

    category = Category.find_or_create_by_name('Clydesdale')
    assert_not_nil(category, 'category')
    assert(category.errors.empty?, category.errors.full_messages)
    assert_equal('Clydesdale', category.name, 'category.name')
  end
end
