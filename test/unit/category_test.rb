require File.dirname(__FILE__) + '/../test_helper'

class CategoryTest < Test::Unit::TestCase
  
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
  
  def test_sort
    categories = Category.find(:all)
    categories.sort
  end
  
  def test_find_all_unknowns
    unknown = Category.create(:name => 'Canine')
    assoc_category = Category.find_or_create_by_name(ASSOCIATION.short_name)

    unknowns = Category.find_all_unknowns
    assert_not_nil(unknowns, 'Orphans should not be nil')
    assert(unknowns.include?(unknown), "Orphans should include 'Canine' category")
    assert(!unknowns.include?(assoc_category), "Orphans should not include '#{ASSOCIATION.short_name}' category")
  end
  
  def test_equal
    senior_men = Category.find_by_name('Senior Men')
    senior_men_2 = Category.find_by_name('Senior Men')
    assert_equal(senior_men, senior_men_2, 'Senior Men instances')
    assert_equal(senior_men_2, senior_men, 'Senior Men instances')

    senior_men_2.name = ''
    assert_equal(senior_men, senior_men_2, 'Senior Men instances with different names')
    assert_equal(senior_men_2, senior_men, 'Senior Men instances with different names')
  end
  
  def test_no_circular_parents
    senior_men = Category.find_by_name('Senior Men')
    senior_men.parent = senior_men
    assert(!senior_men.valid?, 'Category with itself as parent should not be valid')
  end
end
