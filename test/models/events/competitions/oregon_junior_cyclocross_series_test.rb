# frozen_string_literal: true

require "test_helper"

module Competitions
  # :stopdoc:
  class OregonJuniorCyclocrossSeriesTest < ActiveSupport::TestCase
    test "calculate" do
      competition = OregonJuniorCyclocrossSeries::Overall.create!

      event = FactoryBot.create(:event)
      competition.source_events << event
      junior_men_9 = Category.find_or_create_by_normalized_name(name: "Junior Men 9")
      junior_men_9_race = event.races.create!(category: junior_men_9)

      person_9_1 = FactoryBot.create(:person, date_of_birth: 9.years.ago)
      junior_men_9_race.results.create!(place: 1, time: 1893, laps: 3, person: person_9_1)

      person_9_2 = FactoryBot.create(:person, date_of_birth: 9.years.ago)
      junior_men_9_race.results.create!(place: 2, time: 1943, laps: 3, person: person_9_2)

      person_9_3 = FactoryBot.create(:person, date_of_birth: 9.years.ago)
      junior_men_9_race.results.create!(place: 3, time: 1567, laps: 2, person: person_9_3)

      junior_men_10_12 = Category.find_or_create_by_normalized_name(name: "Junior Men 10-12")
      junior_men_10_12_race = event.races.create!(category: junior_men_10_12)

      person_10_1 = FactoryBot.create(:person, date_of_birth: 11.years.ago)
      junior_men_10_12_race.results.create!(place: 1, time: 1893, laps: 4, age: 11, person: person_10_1)

      person_10_2 = FactoryBot.create(:person, date_of_birth: 12.years.ago)
      junior_men_10_12_race.results.create!(place: 2, time: 2028, laps: 4, age: 12, person: person_10_2)

      person_10_3 = FactoryBot.create(:person, date_of_birth: 11.years.ago)
      junior_men_10_12_race.results.create!(place: 3, time: 2028, laps: 4, age: 11, person: person_10_3)

      person_10_4 = FactoryBot.create(:person, date_of_birth: 10.years.ago)
      junior_men_10_12_race.results.create!(place: 4, time: 2029, laps: 4, age: 10, person: person_10_4)

      OregonJuniorCyclocrossSeries::Overall.calculate!

      expected_people = [
        person_10_1,
        person_10_2,
        person_10_3,
        person_10_4,
        person_9_1,
        person_9_2,
        person_9_3
      ].map(&:id)
      race = competition.races.find { |r| r.category.name == "Junior Men 9-12 3/4/5" }
      assert_equal expected_people, race.results.sort.map(&:person_id), "people finish order"
      assert_equal %w[1 2 3 4 5 6 7], race.results.sort.map(&:place), "places"
    end
  end
end
