require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class CategoryTest < ActiveSupport::TestCase  
  def test_find_all_unknowns
    unknown = Category.create(:name => 'Canine')
    assoc_category = Category.find_or_create_by_name(RacingAssociation.current.short_name)

    unknowns = Category.find_all_unknowns
    assert_not_nil(unknowns, 'Orphans should not be nil')
    assert(unknowns.include?(unknown), "Orphans should include 'Canine' category")
    assert(!unknowns.include?(assoc_category), "Orphans should not include '#{RacingAssociation.current.short_name}' category")
  end
  
  # Relies on ActiveRecord ==
  def test_sort
    [ FactoryGirl.build(:category, :id => 2), FactoryGirl.build(:category, :id => 1), FactoryGirl.build(:category)].sort
  end

  def test_equal
    senior_men = FactoryGirl.build(:category, :name => "Senior Men", :id => 1)
    senior_men_2 = FactoryGirl.build(:category, :name => "Senior Men", :id => 1)
    assert_equal(senior_men, senior_men_2, 'Senior Men instances')
    assert_equal(senior_men_2, senior_men, 'Senior Men instances')

    senior_men_2.name = ''
    assert_equal(senior_men, senior_men_2, 'Senior Men instances with different names')
    assert_equal(senior_men_2, senior_men, 'Senior Men instances with different names')
  end
  
  def test_no_circular_parents
    category = FactoryGirl.build(:category, :name => "Senior Men", :id => 1)
    category.parent = category
    assert !category.valid?
  end
  
  def test_ages_default
    cat = FactoryGirl.build(:category)
    assert_equal(0, cat.ages_begin, 'ages_begin')
    assert_equal(999, cat.ages_end, 'ages_end is 999')
    assert_equal(0..999, cat.ages, 'Default age range is 0 to 999')
  end
  
  def test_to_friendly_param
    assert_equal('senior_men', FactoryGirl.build(:category, :name => "Senior Men").to_friendly_param, 'senior_men friendly_param')
    assert_equal('pro_expert_women', FactoryGirl.build(:category, :name => "Pro, Expert Women").to_friendly_param, 'pro_expert_women friendly_param')
    assert_equal('category_4_5_men', FactoryGirl.build(:category, :name => "Category 4/5 Men").to_friendly_param, 'men_4 param')
    assert_equal('singlespeed_fixed', FactoryGirl.build(:category, :name => "Singlespeed/Fixed").to_friendly_param, 'single_speed_fixed friendly_param')
    assert_equal('masters_35_plus', FactoryGirl.build(:category, :name => "Masters 35+").to_friendly_param, 'masters_35_plus friendly_param')
    assert_equal('pro_semi_pro_men', FactoryGirl.build(:category, :name => "Pro, Semi-Pro Men").to_friendly_param, 'pro_semi_pro_men friendly_param')
    assert_equal('category_3_200m_tt', FactoryGirl.build(:category, :name => 'Category 3 - 200m TT').to_friendly_param, 'Category 3 - 200m TT friendly_param')
    assert_equal('jr_varisty_15_18_beginner', FactoryGirl.build(:category, :name => 'Jr Varisty 15 -18 Beginner').to_friendly_param, 'Jr Varisty 15 -18 Beginner friendly_param')
    assert_equal('tandem_mixed_co_ed', FactoryGirl.build(:category, :name => 'Tandem - Mixed (Co-Ed)').to_friendly_param, 'Tandem - Mixed (Co-Ed) friendly_param')
    assert_equal('tandem', FactoryGirl.build(:category, :name => '(Tandem)').to_friendly_param, '(Tandem) friendly_param')
  end
  
  def test_find_by_friendly_param
    category = FactoryGirl.create(:category, :name => "Pro, Semi-Pro Men")
    assert_equal category, Category.find_by_friendly_param("pro_semi_pro_men")
  end
  
  def test_ambiguous_find_by_param
    senior_men = FactoryGirl.create(:category, :name => "Senior Men")
    senior_men_2 = FactoryGirl.create(:category, :name => "Senior/Men")
    assert_equal('senior_men', senior_men.friendly_param)
    assert_equal('senior_men', senior_men_2.friendly_param)
    assert_raises(Concerns::Category::AmbiguousParamException) { Category.find_by_friendly_param('senior_men') }
  end
end
