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
  
  def test_points_for
    race = Race.new(:standings => Standings.new)
    result = Result.new(:race => race, :place => 1)
    competition = Competition.new
    competition.point_schedule = [0, 20, 10, 5, 4, 3, 2, 1]
    team_size = 1
    points = competition.points_for(result, team_size)
    assert_equal(20, points, 'Points for first place with team of one and no multiplier')
  end
  
  def test_points_for_team_event
    # BAR points ignored
    race = Race.new(:standings => Standings.new(:bar_points => 3))
    result = Result.new(:race => race, :place => 3)
    competition = Competition.new
    competition.point_schedule = [0, 20, 10, 5, 4, 3, 2, 1]
    team_size = 2
    points = competition.points_for(result, team_size)
    assert_equal(2.5, points, 'Points for first place with team of one and no multiplier')
  end
end
