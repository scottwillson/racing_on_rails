require File.expand_path("../../../../test_case", __FILE__)
require File.expand_path("../../../../../../app/models/competitions/cat4_womens_race_series_modules/points", __FILE__)

module Competitions
  module Cat4WomensRaceSeriesModules
    # :stopdoc:
    # Used to only award bonus points for races of five or less, but now all races get equal points
    class PointsTest < Ruby::TestCase
      def test_points_for_with_participation_points
        source_event = stub("SingleDayEvent", id: 1)
        series = stub("Cat4WomensRaceSeries", source_events: [ source_event ], association_point_schedule: nil)
        series.stubs(:participation_points? => true)
        series.extend Cat4WomensRaceSeriesModules::Points

        result = stub("result", place: "1", event_id: 1, race: stub("race", event: source_event))
        assert_equal 100, series.points_for(result), "points for result"

        result = stub("result", place: "10", event_id: 1, race: stub("race", event: source_event))
        assert_equal 66, series.points_for(result), "points for result"

        result = stub("result", place: "15", event_id: 1, race: stub("race", event: source_event))
        assert_equal 56, series.points_for(result), "points for result"

        result = stub("result", place: "16", event_id: 1, race: stub("race", event: source_event))
        assert_equal 25, series.points_for(result), "points for result"

        result = stub("result", place: "17", event_id: 1, race: stub("race", event: source_event))
        assert_equal 25, series.points_for(result), "points for result"

        result = stub("result", place: "100", event_id: 1, race: stub("race", event: source_event))
        assert_equal 25, series.points_for(result), "points for result"

        result = stub("result", place: "DNF", event_id: 1, race: stub("race", event: source_event))
        assert_equal 0, series.points_for(result), "points for result"

        result = stub("result", place: "", event_id: 1, race: stub("race", event: source_event))
        assert_equal 15, series.points_for(result), "points for result"
      end

      def test_points_for
        source_event = stub("SingleDayEvent", id: 1)
        series = stub("Cat4WomensRaceSeries", source_events: [ source_event ], association_point_schedule: nil)
        series.stubs(:participation_points? => false)
        series.extend Cat4WomensRaceSeriesModules::Points

        result = stub("result", place: "1", event_id: 1, race: stub("race", event: source_event))
        assert_equal 100, series.points_for(result), "points for result"

        result = stub("result", place: "10", event_id: 1, race: stub("race", event: source_event))
        assert_equal 66, series.points_for(result), "points for result"

        result = stub("result", place: "15", event_id: 1, race: stub("race", event: source_event))
        assert_equal 56, series.points_for(result), "points for result"

        result = stub("result", place: "16", event_id: 1, race: stub("race", event: source_event))
        assert_equal 0, series.points_for(result), "points for result"

        result = stub("result", place: "17", event_id: 1, race: stub("race", event: source_event))
        assert_equal 0, series.points_for(result), "points for result"

        result = stub("result", place: "100", event_id: 1, race: stub("race", event: source_event))
        assert_equal 0, series.points_for(result), "points for result"

        result = stub("result", place: "DNF", event_id: 1, race: stub("race", event: source_event))
        assert_equal 0, series.points_for(result), "points for result"

        result = stub("result", place: "", event_id: 1, race: stub("race", event: source_event))
        assert_equal 0, series.points_for(result), "points for result"
      end

      def test_points_for_non_source_event
        source_event = stub("SingleDayEvent", id: 1)
        series = stub("Cat4WomensRaceSeries", source_events: [ source_event ], association_point_schedule: nil)
        series.stubs(:participation_points? => true)
        series.extend Cat4WomensRaceSeriesModules::Points

        non_source_event = stub("SingleDayEvent", id: 2, parent_id: nil)

        result = stub("result", place: "1", event_id: 2, event: non_source_event, race: stub("race", event: non_source_event))
        assert_equal 15, series.points_for(result), "points for result"

        result = stub("result", place: "100", event_id: 2, event: non_source_event, race: stub("race", event: non_source_event))
        assert_equal 15, series.points_for(result), "points for result"
      end

      def test_points_for_non_source_event_no_participation_points
        source_event = stub("SingleDayEvent", id: 1)
        series = stub("Cat4WomensRaceSeries", source_events: [ source_event ], association_point_schedule: nil)
        series.stubs(:participation_points? => false)
        series.extend Cat4WomensRaceSeriesModules::Points

        non_source_event = stub("SingleDayEvent", id: 2, parent_id: nil)

        result = stub("result", place: "1", event_id: 2, event: non_source_event, race: stub("race", event: non_source_event))
        assert_equal 0, series.points_for(result), "points for result"

        result = stub("result", place: "100", event_id: 2, event: non_source_event, race: stub("race", event: non_source_event))
        assert_equal 0, series.points_for(result), "points for result"
      end
    end
  end
end
