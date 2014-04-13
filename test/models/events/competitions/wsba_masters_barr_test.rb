require File.expand_path("../../../../test_helper", __FILE__)

# :stopdoc:
module Events
  module Competitions
    class WsbaMastersBarrTest < ActiveSupport::TestCase
      def test_points
        masters_men_35 = FactoryGirl.create(:category, :name => "Master Men 35-39 Cat 1-3")
        masters_women_35 = FactoryGirl.create(:category, :name => "Master Women 35+ Cat 1-3")
        wsba = WsbaMastersBarr.create!(:date => Date.new(2004))

        event = FactoryGirl.create(:event, :date => Date.new(2004), :name => "Banana Belt")
        race = event.races.create!(:category => masters_men_35)

        tonkin = FactoryGirl.create(:person, :name => "Tonkin")
        race.results.create!(:place => "1", :person => tonkin)
        ryan = FactoryGirl.create(:person, :name => "Ryan")
        race.results.create!(:place => "2", :person => ryan)
        matson = FactoryGirl.create(:person, :name => "Matson")
        race.results.create!(:place => "3", :person => matson)
        wsba.source_events << event

        event = FactoryGirl.create(:event, :date => Date.new(2004), :name => "Kings Valley")
        wsba.source_events << event

        race = event.races.create!(:category => masters_men_35)
        race.results.create!(:place => "10", :person => tonkin)

        race = event.races.create!(:category => masters_women_35)
        race.results.create!(:place => "2")
        race.results.create!(:place => "15")

        fill_in_missing_results
        WsbaMastersBarr.any_instance.expects(:expire_cache)
        WsbaMastersBarr.calculate!(2004)

        wsba = WsbaMastersBarr.find_for_year(2004)

        race = wsba.races.detect { |race| race.category == masters_men_35 }
        assert_not_nil(race, "Should have Master Men 35-39 Cat 1-3 race")
        assert_equal(3, race.results.count, "Master Men 35-39 Cat 1-3 results")

        results = race.results.sort
        assert_equal(27, results[0].points, "Result 0 points")
        assert_equal(17, results[1].points, "Result 1 points")
        assert_equal(15, results[2].points, "Result 2 points")
      end
    end
  end
end
