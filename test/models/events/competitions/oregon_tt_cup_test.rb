require File.expand_path("../../../../test_helper", __FILE__)

module Competitions
  # :stopdoc:
  class OregonTTCupTest < ActiveSupport::TestCase
    test "recalc with one event" do
      event = FactoryGirl.create(:time_trial_event)
      competition = OregonTTCup.create!
      competition.source_events << event

      masters_men_30_34 = Category.where(name: "Masters Men 30-34").first_or_create!
      race = event.races.create!(category: masters_men_30_34, distance: 25)
      long_result = race.results.create!(place: "1", time: 3600, person: FactoryGirl.create(:person, name: "long"))

      masters_men_35_39 = Category.where(name: "Masters Men 35-39").first_or_create!
      race = event.races.create!(category: masters_men_35_39, distance: 12)
      short_result_1 = race.results.create!(place: "1", time: 1700, person: FactoryGirl.create(:person, name: "short 1"))
      short_result_2 = race.results.create!(place: "2", time: 1800, person: FactoryGirl.create(:person, name: "short 2"))

      OregonTTCup.calculate!

      competition.reload
      assert_equal 1, competition.races_with_results.size
      race = competition.races_with_results.first
      assert_equal 3, race.results.size

      expected = [ short_result_1, long_result, short_result_2 ].map(&:person_name)
      actual = race.results.map(&:scores).flatten.map(&:source_result).flatten.map(&:person_name)
      assert_equal expected, actual, "source results should be sorted by distance-adjusted time"
    end
  end
end
