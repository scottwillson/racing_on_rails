require File.dirname(__FILE__) + '/../test_helper'

class TestCompetition < Competition
  def friendly_name
    'KOM'
  end
end

class CompetitionTest < Test::Unit::TestCase

  def test_competition_category
    competition = Competition.create
    assert_equal([], competition.competition_categories, 'competition_categories for new Competition')
  end
  
  def test_naming
    assert_equal("Competition", Competition.new.friendly_name, 'Default friendly_name')
    assert_equal('KOM', TestCompetition.new.friendly_name, 'friendly_name')
    assert_equal("#{Date.today.year} KOM", TestCompetition.new.name, 'friendly_name')
    competition = TestCompetition.new
    competition.name = 'QOM'
    assert_equal('QOM', competition.name, 'name')
  end
end
