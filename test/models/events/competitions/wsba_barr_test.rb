require File.expand_path("../../../../test_helper", __FILE__)

# :stopdoc:
module Competitions
  module Events
    module Competitions
      class WsbaBarrTest < ActiveSupport::TestCase
        test "points" do
          category_men_1_2 = FactoryGirl.create(:category, raw_name: "Men Cat 1-2")
          sr_women = FactoryGirl.create(:category, raw_name: "Women Cat 1-2")
          wsba = WsbaBarr.create!(date: Date.new(2004))

          event = FactoryGirl.create(:event, date: Date.new(2004), name: "Banana Belt")
          race = event.races.create!(category: category_men_1_2)

          tonkin = FactoryGirl.create(:person, name: "Tonkin")
          race.results.create!(place: "1", person: tonkin)
          ryan = FactoryGirl.create(:person, name: "Ryan")
          race.results.create!(place: "2", person: ryan)
          matson = FactoryGirl.create(:person, name: "Matson")
          race.results.create!(place: "3", person: matson)
          wsba.source_events << event
          event.set_points_for(wsba, 2)

          event = FactoryGirl.create(:event, date: Date.new(2004), name: "Kings Valley")
          wsba.source_events << event

          race = event.races.create!(category: category_men_1_2)
          race.results.create!(place: "10", person: tonkin)

          race = event.races.create!(category: sr_women)
          race.results.create!(place: "2")
          race.results.create!(place: "15")

          fill_in_missing_results
          WsbaBarr.calculate!(2004)

          wsba = WsbaBarr.find_for_year(2004)

          men_1_2 = wsba.races.detect { |r| r.category == category_men_1_2 }
          assert_not_nil(men_1_2, "Should have Men Cat 1-2 race")
          assert_equal(3, men_1_2.results.count, "Senior men results")

          results = men_1_2.results.sort
          assert_equal(21, results[0].points, "Result 0 points")
          assert_equal(17, results[1].points, "Result 1 points")
          assert_equal(15, results[2].points, "Result 2 points")
        end
      end
    end
  end
end
