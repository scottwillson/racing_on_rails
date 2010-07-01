require File.expand_path("../../test_helper", __FILE__)

class TestCompetition < Competition
  def friendly_name
    'KOM'
  end
end

class CompetitionTest < ActiveSupport::TestCase
  def test_naming
    assert_equal("Competition", Competition.new.friendly_name, 'Default friendly_name')
    assert_equal('KOM', TestCompetition.new.friendly_name, 'friendly_name')
    assert_equal("#{Date.today.year} KOM", TestCompetition.create!.name, 'friendly_name')
    competition = TestCompetition.new
    competition.name = 'QOM'
    assert_equal('QOM', competition.name, 'name')
    competition.save!
    name_in_db = Competition.connection.select_value("select name from events where id = #{competition.id}")
    assert_equal("QOM", name_in_db, 'Name in database')
  end
  
  def test_name_after_create
    competition = TestCompetition.create!
    name_in_db = Competition.connection.select_value("select name from events where id = #{competition.id}")
    assert_equal("#{Date.today.year} KOM", name_in_db, 'Name in database')
  end

  def test_category_ids_for
    category = Category.create(:name => 'Sandbaggers')
    competition = Competition.create
    race = competition.races.create(:category => category)
    assert_equal(category.id.to_s, competition.category_ids_for(race), 'category should include itself only')
  end
  
  def test_points_for
    result = SingleDayEvent.create!.races.create!(:category => categories(:senior_men)).results.create!(:place => 1)
    competition = Competition.new
    competition.point_schedule = [0, 20, 10, 5, 4, 3, 2, 1]
    team_size = 1
    points = competition.points_for(result, team_size)
    assert_equal(20, points, 'Points for first place with team of one and no multiplier')
  end
  
  def test_points_for_team_event
    # BAR points ignored
    result = SingleDayEvent.create!(:bar_points => 3).races.create!(:category => categories(:senior_men)).results.create!(:place => 3)
    competition = Competition.new
    competition.point_schedule = [0, 20, 10, 5, 4, 3, 2, 1]
    team_size = 2
    points = competition.points_for(result, team_size)
    assert_equal(2.5, points, 'Points for first place with team of one and no multiplier')
  end
end
