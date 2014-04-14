require File.expand_path("../../../../../test_case", __FILE__)
require File.expand_path("../../../../../../../app/models/competitions/concerns/competition/points", __FILE__)

# :stopdoc:
class Concerns::Competition::PointsTest < Ruby::TestCase
  class TestCompetition
    include ::Concerns::Competition::Points
  end

  test "points_for" do
    competition = TestCompetition.new
    competition.stubs(:points_factor).returns(1)
    competition.stubs(:team_size_from_result).returns(1)
    competition.point_schedule = [ 0, 20, 10, 5, 4, 3, 2, 1 ]
    source_event = stub("SingleDayEvent", id: 1,)

    result = stub(
      "result",
      place: "1",
      event_id: 1,
      event: source_event,
      race: stub("race", event: source_event)
    )

    points = competition.points_for(result)
    assert_equal 20, points, "Points for first place with team of one and no multiplier"

    points = competition.points_for(result, 1)
    assert_equal 20, points, "Points for first place with team of one and no multiplier"

    result.stubs(:place).returns("")
    points = competition.points_for(result)
    assert_equal 0, points, "Points for first place with team of one and no multiplier"

    result.stubs(:place).returns("7")
    points = competition.points_for(result)
    assert_equal 1, points, "Points for first place with team of one and no multiplier"

    result.stubs(:place).returns("8")
    points = competition.points_for(result)
    assert_equal 0, points, "Points for first place with team of one and no multiplier"

    result.stubs(:place).returns("DNF")
    points = competition.points_for(result)
    assert_equal 0, points, "Points for first place with team of one and no multiplier"

    result.stubs(:place).returns("DNS")
    points = competition.points_for(result)
    assert_equal 0, points, "Points for first place with team of one and no multiplier"
  end

  test "points_for_place_members_only" do
    competition = TestCompetition.new
    competition.stubs(:team_size_from_result).returns(1)
    competition.stubs(:place_members_only?).returns(true)
    competition.stubs(:points_factor).returns(1)
    competition.point_schedule = [ 0, 20, 10, 5, 4, 3, 2, 1 ]
    source_event = stub("SingleDayEvent", id: 1)

    result = stub(
      "result",
      place: "4",
      members_only_place: "1",
      event_id: 1,
      event: source_event,
      race: stub("race", event: source_event)
    )
    points = competition.points_for(result)
    assert_equal 20, points, "points"
  end

  test "points_for_team_event" do
    competition = TestCompetition.new
    competition.point_schedule = [ 0, 20, 10, 5, 4, 3, 2, 1 ]
    competition.stubs(:points_factor).returns(1)
    source_event = stub("SingleDayEvent", id: 1, bar_points: 3)

    result = stub(
      "result",
      place: "3",
      event_id: 1,
      event: source_event,
      race: stub("race", event: source_event)
    )
    points = competition.points_for(result, 2)
    assert_equal 2.5, points, "Points for first place with team of two and no multiplier"
  end

  test "consider_points_factor" do
    competition = TestCompetition.new
    competition.point_schedule = [ 0, 20, 10, 5, 4, 3, 2, 1 ]
    competition.stubs(:points_factor).returns(2)
    source_event = stub("SingleDayEvent", id: 1)

    result = stub(
      "result",
      place: "4",
      event_id: 1,
      event: source_event,
      race: stub("race", event: source_event)
    )
    points = competition.points_for(result, 1)
    assert_equal 8, points, "Points"
  end

  test "do_not_consider_points_factor" do
    competition = TestCompetition.new
    competition.point_schedule = [ 0, 20, 10, 5, 4, 3, 2, 1 ]
    competition.stubs(:consider_points_factor?).returns(false)
    competition.stubs(:points_factor).returns(2)
    source_event = stub("SingleDayEvent", id: 1)

    result = stub(
      "result",
      place: "4",
      event_id: 1,
      event: source_event,
      race: stub("race", event: source_event)
    )
    points = competition.points_for(result, 1)
    assert_equal 4, points, "Points"
  end
end
