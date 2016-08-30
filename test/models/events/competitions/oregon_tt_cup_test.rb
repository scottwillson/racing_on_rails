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

      masters_men_35_14 = Category.where(name: "Masters Men 35-14").first_or_create!
      race = event.races.create!(category: masters_men_35_14, distance: 12)
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

    test "split_from races" do
      event = FactoryGirl.create(:time_trial_event)
      competition = OregonTTCup.create!
      competition.source_events << event

      racer_10 = FactoryGirl.create(:person, name: "Racer 10", date_of_birth: 10.years.ago)
      racer_13 = FactoryGirl.create(:person, name: "Racer 13", date_of_birth: 13.years.ago)
      racer_14 = FactoryGirl.create(:person, name: "Racer 14", date_of_birth: 14.years.ago)

      junior_10_14 = Category.where(name: "Junior Men 10-14").first_or_create!
      race_10_14 = event.races.create!(category: junior_10_14, distance: 25)
      race_10_14.results.create!(place: "1", time: 1600, person: racer_13)
      race_10_14.results.create!(place: "2", time: 1700, person: racer_14)
      race_10_14.results.create!(place: "3", time: 1800, person: racer_10)

      OregonTTCup.calculate!

      competition.reload
      assert_equal 2, competition.races_with_results.size

      race_13_14 = competition.races_with_results.detect { |r| r.name == "Junior Men 13-14"}
      assert_equal 2, race_13_14.results.size

      expected = [ racer_13, racer_14 ].map(&:name)
      actual = race_13_14.results.map(&:scores).flatten.map(&:source_result).flatten.map(&:person_name)
      assert_equal expected, actual, "people"

      race_10_12 = competition.races_with_results.detect { |r| r.name == "Junior Men 10-12"}
      assert_equal 1, race_10_12.results.size

      actual = race_10_12.results.map(&:scores).flatten.map(&:source_result).flatten.map(&:person_name)
      assert_equal [ "Racer 10" ], actual, "people"

      source_race_10_12 = event.races.reload.detect { |r| r.name == "Junior Men 10-12"}
      assert_equal race_10_14, source_race_10_12.split_from

      source_race_13_14 = event.races.detect { |r| r.name == "Junior Men 13-14"}
      assert_equal race_10_14, source_race_13_14.split_from

      assert_equal race_10_14, source_race_13_14.split_from
      (event.races.reload - [ source_race_10_12, source_race_13_14 ]).each do |race|
        assert_equal nil, race.split_from, "#{race.name} split_from"
      end
    end
  end
end
