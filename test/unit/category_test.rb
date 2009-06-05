require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  
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
    # Is an error here really the best thing?
    assert_raise(ActiveRecord::Acts::Tree::CircularAssociation, "Should not be able to add parent as child") { senior_men.valid? }
  end
  
  def test_ages
    cat = Category.create(:name => 'Not a Masters Category')
    assert_equal(0, cat.ages_begin, 'ages_begin')
    assert_equal(999, cat.ages_end, 'ages_end is 999')
    assert_equal(0..999, cat.ages, 'Default age range is 0 to 999')
    
    cat.ages = 12..15
    assert_equal(12, cat.ages_begin, 'ages_begin')
    assert_equal(15, cat.ages_end, 'ages_end')
    assert_equal(12..15, cat.ages, 'Default age range')
    
    cat.save!
    cat.reload
    assert_equal(12, cat.ages_begin, 'ages_begin')
    assert_equal(15, cat.ages_end, 'ages_end')
    assert_equal(12..15, cat.ages, 'Default age range')
  end
  
  def test_set_ages_as_string
    cat = Category.create(:name => 'Not a Masters Category', :ages => "12-15")
    assert_equal(12, cat.ages_begin, 'ages_begin')
    assert_equal(15, cat.ages_end, 'ages_end')
    assert_equal(12..15, cat.ages, 'Default age range')
  end
  
  def test_to_friendly_param
    assert_equal('senior_men', categories(:senior_men).to_friendly_param, 'senior_men friendly_param')
    assert_equal('pro_expert_women', categories(:pro_expert_women).to_friendly_param, 'pro_expert_women friendly_param')
    assert_equal('category_4_5_men', categories(:men_4_5).to_friendly_param, 'men_4 param')
    assert_equal('singlespeed_fixed', categories(:single_speed).to_friendly_param, 'single_speed_fixed friendly_param')
    assert_equal('masters_35_plus', categories(:masters_35_plus).to_friendly_param, 'masters_35_plus friendly_param')
    assert_equal('pro_semi_pro_men', categories(:pro_semi_pro_men).to_friendly_param, 'pro_semi_pro_men friendly_param')
    assert_equal('category_3_200m_tt', Category.new(:name => 'Category 3 - 200m TT').to_friendly_param, 'Category 3 - 200m TT friendly_param')
    assert_equal('jr_varisty_15_18_beginner', Category.new(:name => 'Jr Varisty 15 -18 Beginner').to_friendly_param, 'Jr Varisty 15 -18 Beginner friendly_param')
    assert_equal('tandem_mixed_co_ed', Category.new(:name => 'Tandem - Mixed (Co-Ed)').to_friendly_param, 'Tandem - Mixed (Co-Ed) friendly_param')
    assert_equal('tandem', Category.new(:name => '(Tandem)').to_friendly_param, '(Tandem) friendly_param')
  end
  
  def test_find_by_friendly_param
    for category in Category.find(:all)
      assert_equal(category, Category.find_by_friendly_param(category.friendly_param), "#{category.name} #{category.friendly_param} find_by_friendly_param")
    end
  end
  
  def test_ambiguous_find_by_param
    senior_men_2 = Category.create!(:name => 'Senior/Men')
    senior_men = categories(:senior_men)
    assert_equal('senior_men', senior_men.friendly_param)
    assert_equal('senior_men', senior_men_2.friendly_param)
    assert_raises(AmbiguousParamException) {Category.find_by_friendly_param('senior_men')}
  end
end
