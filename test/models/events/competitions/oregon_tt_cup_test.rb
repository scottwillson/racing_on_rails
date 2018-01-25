# frozen_string_literal: true

require "test_helper"

module Competitions
  # :stopdoc:
  class OregonTTCupTest < ActiveSupport::TestCase
    test "recalc with one event" do
      event = FactoryBot.create(:time_trial_event)
      competition = OregonTTCup.create!
      competition.source_events << event

      masters_men_30_34 = Category.where(name: "Masters Men 30-34").first_or_create!
      race = event.races.create!(category: masters_men_30_34, distance: 25)
      long_result = race.results.create!(place: "1", time: 3600, person: FactoryBot.create(:person, name: "long"))

      masters_men_35_14 = Category.where(name: "Masters Men 35-39").first_or_create!
      race = event.races.create!(category: masters_men_35_14, distance: 12)
      short_result_1 = race.results.create!(place: "1", time: 1700, person: FactoryBot.create(:person, name: "short 1"))
      short_result_2 = race.results.create!(place: "2", time: 1800, person: FactoryBot.create(:person, name: "short 2"))

      OregonTTCup.calculate!

      competition.reload
      assert_equal 1, competition.races_with_results.size
      race = competition.races_with_results.first
      assert_equal 3, race.results.size

      expected = [short_result_1, long_result, short_result_2].map(&:person_name)
      actual = race.results.map(&:scores).flatten.map(&:source_result).flatten.map(&:person_name)
      assert_equal expected, actual, "source results should be sorted by distance-adjusted time"
    end

    test "split_from races" do
      event = FactoryBot.create(:time_trial_event)
      competition = OregonTTCup.create!
      competition.source_events << event

      racer_10 = FactoryBot.create(:person, name: "Racer 10", date_of_birth: 10.years.ago)
      racer_13 = FactoryBot.create(:person, name: "Racer 13", date_of_birth: 13.years.ago)
      racer_14 = FactoryBot.create(:person, name: "Racer 14", date_of_birth: 14.years.ago)

      junior_10_14 = Category.where(name: "Junior Men 10-14").first_or_create!
      race_10_14 = event.races.create!(category: junior_10_14, distance: 25)
      race_10_14.results.create!(place: "1", time: 1600, person: racer_13)
      race_10_14.results.create!(place: "2", time: 1700, person: racer_14)
      race_10_14.results.create!(place: "3", time: 1800, person: racer_10)

      OregonTTCup.calculate!

      competition.reload
      assert_equal 2, competition.races_with_results.size

      race_13_14 = competition.races_with_results.detect { |r| r.name == "Junior Men 13-14" }
      assert_equal 2, race_13_14.results.size

      expected = [racer_13, racer_14].map(&:name)
      actual = race_13_14.results.map(&:scores).flatten.map(&:source_result).flatten.map(&:person_name)
      assert_equal expected, actual, "people"

      race_10_12 = competition.races_with_results.detect { |r| r.name == "Junior Men 10-12" }
      assert_equal 1, race_10_12.results.size

      actual = race_10_12.results.map(&:scores).flatten.map(&:source_result).flatten.map(&:person_name)
      assert_equal ["Racer 10"], actual, "people"

      source_race_10_12 = event.races.reload.detect { |r| r.name == "Junior Men 10-12" }
      assert_equal race_10_14, source_race_10_12.split_from

      source_race_13_14 = event.races.detect { |r| r.name == "Junior Men 13-14" }
      assert_equal race_10_14, source_race_13_14.split_from

      assert_equal race_10_14, source_race_13_14.split_from
      (event.races.reload - [source_race_10_12, source_race_13_14]).each do |race|
        assert_nil race.split_from, "#{race.name} split_from"
      end
    end

    test "2017 results" do
      competition = OregonTTCup.create!
      cat_4_5_men = Category.where(name: "Category 4/5 Men").first
      person = FactoryBot.create(:person)

      # 5	Jack Frost Time Trial	Category 4/5 Men	3/5	11.0
      # 2	Revenge Of The Disc	Men Category 4/5	4/9	14.0
      # 2	Revenge Of The Disc	Men Category 4/5	4/29	14.0
      # 1	OBRA TTT Championships	Men 4/5	5/7	7.5
      # 4	Rally the Valley Omnium: Time Trial	Category 4/5	5/20	12.0
      # 6	OBRA TT Championships	Men Category 4/5	6/11	20.0
      # 13	Thump Coffee High Desert Omnium: Time Trial	Men Category 4/5 TT	7/1	3.0
      # 5	Larch Mt. Hill Climb	Category 4 Men	7/9	11.0
      # 6	2017 OBRA Hillclimb Time Trial Championship - Presented by Sam Barlow Track & Field	Men Category 4	7/16	20.0

      event = FactoryBot.create(:event, name: "Jack Frost Time Trial")
      competition.source_events << event
      race = event.races.create!(category: cat_4_5_men)
      race.results.create!(person: person, place: 5)

      event = FactoryBot.create(:event, name: "Revenge Of The Disc")
      competition.source_events << event
      men_category_4_5 = Category.where(name: "Men Category 4/5").first_or_create!
      race = event.races.create!(category: men_category_4_5)
      race.results.create!(person: person, place: 2)

      event = FactoryBot.create(:event, name: "OBRA TTT Championships", bar_points: 2)
      competition.source_events << event
      men_4_5 = Category.where(name: "Category 4/5").first_or_create!
      race = event.races.create!(category: men_4_5)
      race.results.create!(person: person, place: 1)
      race.results.create!(person: FactoryBot.create(:person), place: 1)
      race.results.create!(person: FactoryBot.create(:person), place: 1)
      race.results.create!(person: FactoryBot.create(:person), place: 1)
      race.results.create!(person: FactoryBot.create(:person), place: 2)
      race.results.create!(person: FactoryBot.create(:person), place: 2)
      race.results.create!(person: FactoryBot.create(:person), place: 2)
      race.results.create!(person: FactoryBot.create(:person), place: 2)

      event = FactoryBot.create(:event, name: "Rally the Valley Omnium: Time Trial")
      competition.source_events << event
      men_4_5 = Category.where(name: "Men 4/5").first_or_create!
      race = event.races.create!(category: men_4_5)
      race.results.create!(person: person, place: 4)

      event = FactoryBot.create(:event, name: "OBRA TT Championships", bar_points: 2)
      competition.source_events << event
      race = event.races.create!(category: men_category_4_5)
      race.results.create!(person: person, place: 6)

      event = FactoryBot.create(:event, name: "OBRA Hillclimb Time Trial Championship", bar_points: 2)
      competition.source_events << event
      men_category_4 = Category.where(name: "Men Category 4").first_or_create!
      race = event.races.create!(category: men_category_4)
      race.results.create!(person: person, place: 6)

      OregonTTCup.calculate!

      competition.reload
      assert_equal 1, competition.races_with_results.size

      race = competition.races_with_results.detect { |r| r.name == "Category 4/5 Men" }
      result = race.results.detect { |r| r.person == person }
      assert_equal [10, 10, 11, 13, 17, 20], result.scores.map(&:points).sort
    end
  end
end
