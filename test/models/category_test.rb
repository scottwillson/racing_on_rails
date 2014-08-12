require "test_helper"

# :stopdoc:
class CategoryTest < ActiveSupport::TestCase
  test "find all unknowns" do
    unknown = Category.create(name: 'Canine')
    assoc_category = Category.find_or_create_by(name: (RacingAssociation.current.short_name))

    unknowns = Category.find_all_unknowns
    assert_not_nil(unknowns, 'Orphans should not be nil')
    assert(unknowns.include?(unknown), "Orphans should include 'Canine' category")
    assert(!unknowns.include?(assoc_category), "Orphans should not include '#{RacingAssociation.current.short_name}' category")
  end

  # Relies on ActiveRecord ==
  test "sort" do
    [ FactoryGirl.build(:category, id: 2), FactoryGirl.build(:category, id: 1), FactoryGirl.build(:category)].sort
  end

  test "equal" do
    senior_men = FactoryGirl.build(:category, name: "Senior Men", id: 1)
    senior_men_2 = FactoryGirl.build(:category, name: "Senior Men", id: 1)
    assert_equal(senior_men, senior_men_2, 'Senior Men instances')
    assert_equal(senior_men_2, senior_men, 'Senior Men instances')

    senior_men_2.name = ''
    assert_equal(senior_men, senior_men_2, 'Senior Men instances with different names')
    assert_equal(senior_men_2, senior_men, 'Senior Men instances with different names')
  end

  test "no circular parents" do
    category = FactoryGirl.build(:category, name: "Senior Men", id: 1)
    category.parent = category
    assert !category.valid?
  end

  test "no circular parents <<" do
    category = FactoryGirl.build(:category, name: "Senior Men", id: 1)
    category.children << category
    assert !category.valid?
  end

  test "ages default" do
    cat = FactoryGirl.build(:category)
    assert_equal(0, cat.ages_begin, 'ages_begin')
    assert_equal(999, cat.ages_end, 'ages_end is 999')
    assert_equal(0..999, cat.ages, 'Default age range is 0 to 999')
  end

  test "to friendly param" do
    assert_equal('', Category.new.to_friendly_param, 'nil friendly_param')
    assert_equal('senior_men', FactoryGirl.build(:category, name: "Senior Men").to_friendly_param, 'senior_men friendly_param')
    assert_equal('pro_expert_women', FactoryGirl.build(:category, name: "Pro, Expert Women").to_friendly_param, 'pro_expert_women friendly_param')
    assert_equal('category_4_5_men', FactoryGirl.build(:category, name: "Category 4/5 Men").to_friendly_param, 'men_4 param')
    assert_equal('singlespeed_fixed', FactoryGirl.build(:category, name: "Singlespeed/Fixed").to_friendly_param, 'single_speed_fixed friendly_param')
    assert_equal('masters_35_plus', FactoryGirl.build(:category, name: "Masters 35+").to_friendly_param, 'masters_35_plus friendly_param')
    assert_equal('pro_semi_pro_men', FactoryGirl.build(:category, name: "Pro, Semi-Pro Men").to_friendly_param, 'pro_semi_pro_men friendly_param')
    assert_equal('category_3_200m_tt', FactoryGirl.build(:category, name: 'Category 3 - 200m TT').to_friendly_param, 'Category 3 - 200m TT friendly_param')
    assert_equal('junior_varisty_15_18_beginner', FactoryGirl.build(:category, name: 'Jr Varisty 15 -18 Beginner').to_friendly_param, 'Jr Varisty 15 -18 Beginner friendly_param')
    assert_equal('tandem_mixed_co_ed', FactoryGirl.build(:category, name: 'Tandem - Mixed (Co-Ed)').to_friendly_param, 'Tandem - Mixed (Co-Ed) friendly_param')
    assert_equal('tandem', FactoryGirl.build(:category, name: '(Tandem)').to_friendly_param, '(Tandem) friendly_param')
  end

  test "find by friendly param" do
    category = FactoryGirl.create(:category, name: "Pro, Semi-Pro Men")
    assert_equal category, Category.find_by_friendly_param("pro_semi_pro_men")
  end

  test "ambiguous find by param" do
    senior_men = FactoryGirl.create(:category, name: "Senior Men")
    senior_men_2 = FactoryGirl.create(:category, name: "Senior/Men")
    assert_equal('senior_men', senior_men.friendly_param)
    assert_equal('senior_men', senior_men_2.friendly_param)
    assert_raises(Categories::AmbiguousParamException) { Category.find_by_friendly_param('senior_men') }
  end

  test "add ages from name" do
    category = Category.create!(name: "Masters Men 60+")
    assert_equal 60..999, category.ages

    category = Category.create!(name: "Masters Men 50-59")
    assert_equal 50..59, category.ages
  end

  test "add gender from name" do
    category = Category.create!(name: "Masters Men 60+")
    assert_equal "M", category.gender, "Masters Men 60+ gender"

    category = Category.create!(name: "Junior Women")
    assert_equal "F", category.gender, "Junior Women gender"

    category = Category.create!(name: "Category 3")
    assert_equal "M", category.gender, "Category 3 gender"
  end

  test "age_group?" do
    assert !Category.new(name: "Senior Men").age_group?, "Senior Men age_group?"
    assert Category.new(name: "Masters 60+", ages: 60..999).age_group?, "Masters 60+ age_group?"
    assert Category.new(name: "Juniors 10-18", ages: 10..18).age_group?, "Juniors 10-18 age_group?"
  end
end
