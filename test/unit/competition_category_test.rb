require File.dirname(__FILE__) + '/../test_helper'

class CompetitionCategoryTest < Test::Unit::TestCase

  def test_create
    competition = Competition.create
    senior_men = Category.find_or_create_by_name('Senior Men')
    competition_category = competition.competition_categories.create(:category => senior_men)
    assert(competition_category.errors.empty?, "Should have no errors #{competition_category.errors.full_messages}")
    competition_category = CompetitionCategory.find(:first, :conditions => ['category_id = ?', senior_men.id])
    assert_equal(competition, competition_category.competition, 'competition_category.competition')
    assert_equal(senior_men, competition_category.category, 'competition_category.category')
    assert_equal(senior_men, competition_category.source_category, 'competition_category.source_category')
    
    senior_women = Category.find_or_create_by_name('Senior Women')
    women_1_2_3 = Category.find_or_create_by_name('Women 1/2/3')
    competition_category = competition.competition_categories.create(:category => senior_women, :source_category => women_1_2_3)
    assert(competition_category.errors.empty?, "Should have no errors #{competition_category.errors.full_messages}")
    competition_category = CompetitionCategory.find(:first, :conditions => ['category_id = ?', senior_women.id])
    assert_equal(competition, competition_category.competition, 'competition_category.competition')
    assert_equal(senior_women, competition_category.category, 'competition_category.category')
    assert_equal(women_1_2_3, competition_category.source_category, 'competition_category.source_category')
    
    assert_raise(ActiveRecord::StatementInvalid, 'Should throw exception for duplicate CompetitionCategory') {competition.competition_categories.create(:category => senior_women, :source_category => women_1_2_3)}
  end
  
  def test_create_unless_exists
    competition = Competition.create
    senior_men = Category.find_or_create_by_name('Senior Men')
    competition_category = competition.competition_categories.create_unless_exists(:category => senior_men)
    assert(competition_category.errors.empty?, "Should have no errors #{competition_category.errors.full_messages}")
    competition_category = CompetitionCategory.find(:first, :conditions => ['category_id = ?', senior_men.id])
    assert_equal(competition, competition_category.competition, 'competition_category.competition')
    assert_equal(senior_men, competition_category.category, 'competition_category.category')
    assert_equal(senior_men, competition_category.source_category, 'competition_category.source_category')
    
    senior_women = Category.find_or_create_by_name('Senior Women')
    women_1_2_3 = Category.find_or_create_by_name('Women 1/2/3')
    competition_category = competition.competition_categories.create_unless_exists(:category => senior_women, :source_category => women_1_2_3)
    assert(competition_category.errors.empty?, "Should have no errors #{competition_category.errors.full_messages}")
    competition_category = CompetitionCategory.find(:first, :conditions => ['category_id = ?', senior_women.id])
    assert_equal(competition, competition_category.competition, 'competition_category.competition')
    assert_equal(senior_women, competition_category.category, 'competition_category.category')
    assert_equal(women_1_2_3, competition_category.source_category, 'competition_category.source_category')

    # Already exist, should just return the existing category
    competition_category = competition.competition_categories.create_unless_exists(:category => senior_men)
    assert(competition_category.errors.empty?, "Should have no errors #{competition_category.errors.full_messages}")
    competition_category = CompetitionCategory.find(:first, :conditions => ['category_id = ?', senior_men.id])
    assert_equal(competition, competition_category.competition, 'competition_category.competition')
    assert_equal(senior_men, competition_category.category, 'competition_category.category')
    assert_equal(senior_men, competition_category.source_category, 'competition_category.source_category')

    competition_category = competition.competition_categories.create_unless_exists(:category => senior_women, :source_category => women_1_2_3)
    assert(competition_category.errors.empty?, "Should have no errors #{competition_category.errors.full_messages}")
    competition_category = CompetitionCategory.find(:first, :conditions => ['category_id = ?', senior_women.id])
    assert_equal(competition, competition_category.competition, 'competition_category.competition')
    assert_equal(senior_women, competition_category.category, 'competition_category.category')
    assert_equal(women_1_2_3, competition_category.source_category, 'competition_category.source_category')
  end

  def test_create_unless_exists_no_competition
    senior_women = Category.find_or_create_by_name('Senior Women')
    women_1_2_3 = Category.find_or_create_by_name('Women 1/2/3')
    category = CompetitionCategory.create(:category => senior_women, :source_category => women_1_2_3)
    assert(!category.errors.empty?, 'Should have errors')
  end
end
