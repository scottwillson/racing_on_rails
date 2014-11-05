require File.expand_path("../../../test_case", __FILE__)
require File.expand_path("../../../../../app/models/competitions/points", __FILE__)

module Competitions
  # :stopdoc:
  class PointsTest < Ruby::TestCase
    class TestCompetition
      include ::Competitions::Points
    end

    def test_points_for
      competition = TestCompetition.new
      competition.stubs(:points_factor).returns(1)
      competition.point_schedule = [ 0, 20, 10, 5, 4, 3, 2, 1 ]
      source_event = stub("SingleDayEvent", id: 1,)

      result = stub(
        "result",
        numeric_place: 1,
        event_id: 1,
        event: source_event,
        race: stub("race", event: source_event),
        team_size: 1
      )

      points = competition.points_for(result)
      assert_equal 20, points, "Points for first place with team of one and no multiplier"

      points = competition.points_for(result, 1)
      assert_equal 20, points, "Points for first place with team of one and no multiplier"

      result.stubs(:numeric_place).returns(0)
      points = competition.points_for(result)
      assert_equal 0, points, "Points for first place with team of one and no multiplier"

      result.stubs(:numeric_place).returns(7)
      points = competition.points_for(result)
      assert_equal 1, points, "Points for first place with team of one and no multiplier"

      result.stubs(:numeric_place).returns(8)
      points = competition.points_for(result)
      assert_equal 0, points, "Points for first place with team of one and no multiplier"
    end

    def test_points_for_place_members_only
      competition = TestCompetition.new
      competition.stubs(:place_members_only?).returns(true)
      competition.stubs(:points_factor).returns(1)
      competition.point_schedule = [ 0, 20, 10, 5, 4, 3, 2, 1 ]
      source_event = stub("SingleDayEvent", id: 1)

      result = stub(
        "result",
        numeric_place: 4,
        members_only_place: "1",
        event_id: 1,
        event: source_event,
        race: stub("race", event: source_event),
        team_size: 1
      )
      points = competition.points_for(result)
      assert_equal 20, points, "points"
    end

    def test_points_for_team_event
      competition = TestCompetition.new
      competition.point_schedule = [ 0, 20, 10, 5, 4, 3, 2, 1 ]
      competition.stubs(:points_factor).returns(1)
      source_event = stub("SingleDayEvent", id: 1, bar_points: 3)

      result = stub(
        "result",
        numeric_place: 3,
        event_id: 1,
        event: source_event,
        race: stub("race", event: source_event),
        team_size: 2
      )
      points = competition.points_for(result, 2)
      assert_equal 2.5, points, "Points for first place with team of two and no multiplier"
    end

    def test_consider_points_factor
      competition = TestCompetition.new
      competition.point_schedule = [ 0, 20, 10, 5, 4, 3, 2, 1 ]
      competition.stubs(:points_factor).returns(2)
      source_event = stub("SingleDayEvent", id: 1)

      result = stub(
        "result",
        numeric_place: 4,
        event_id: 1,
        event: source_event,
        race: stub("race", event: source_event),
        team_size: 1
      )
      points = competition.points_for(result, 1)
      assert_equal 8, points, "Points"
    end

    def test_do_not_consider_points_factor
      competition = TestCompetition.new
      competition.point_schedule = [ 0, 20, 10, 5, 4, 3, 2, 1 ]
      competition.stubs(:consider_points_factor?).returns(false)
      competition.stubs(:points_factor).returns(2)
      source_event = stub("SingleDayEvent", id: 1)

      result = stub(
        "result",
        numeric_place: 4,
        event_id: 1,
        event: source_event,
        race: stub("race", event: source_event),
        team_size: 1
      )
      points = competition.points_for(result, 1)
      assert_equal 4, points, "Points"
    end
  end
end
