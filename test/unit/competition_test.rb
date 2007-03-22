require File.dirname(__FILE__) + '/../test_helper'

class CompetitionTest < Test::Unit::TestCase

  def test_competition_category
    competition = Competition.create
    assert_equal([], competition.competition_categories, 'competition_categories for new Competition')
  end
end
