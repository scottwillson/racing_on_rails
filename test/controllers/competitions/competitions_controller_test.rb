require File.expand_path("../../../test_helper", __FILE__)

module Competitions
  # :stopdoc:
  class CompetitionsControllerTest < ActionController::TestCase #:nodoc: all

    tests ::CompetitionsController

    # How does this happen?
    def test_rider_rankings_result_with_no_person
      ::RiderRankings.calculate!
      rider_rankings = RiderRankings.find_for_year
      rider_rankings.races.first.results.create!(place: "1")
      get(:show, type: 'rider_rankings')
      assert_response(:success)
      assert_template("results/event")
      assert_not_nil(assigns["event"], "Should assign event")
      assert_not_nil(assigns["year"], "Should assign year")
    end

    def test_unknown_competition_type
      assert_raise(ActionController::UrlGenerationError) { get(:show, type: 'not_a_series') }
    end
  end
end
