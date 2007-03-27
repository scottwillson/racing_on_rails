require File.dirname(__FILE__) + '/../test_helper'

class TestCompetition < Competition
  def friendly_name
    'KOM'
  end
end

class CompetitionTest < Test::Unit::TestCase
  def test_naming
    assert_equal("Competition", Competition.new.friendly_name, 'Default friendly_name')
    assert_equal('KOM', TestCompetition.new.friendly_name, 'friendly_name')
    assert_equal("#{Date.today.year} KOM", TestCompetition.new.name, 'friendly_name')
    competition = TestCompetition.new
    competition.name = 'QOM'
    assert_equal('QOM', competition.name, 'name')
  end

  def test_category_ids_for
    category = Category.create(:name => 'Sandbaggers')
    competition = Competition.create
    race = competition.standings.first.races.create(:category => category)
    assert_equal(category.id.to_s, competition.category_ids_for(race), 'category should include itself only')
  end
end
