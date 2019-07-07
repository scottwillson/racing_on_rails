# frozen_string_literal: true

require "test_helper"

# :stopdoc:
class Calculations::V3::AgeGroupsByCategoryTest < ActiveSupport::TestCase
  setup { FactoryBot.create :discipline }

  test "#calculate!" do
    series = WeeklySeries.create!(date: Time.zone.local(2018, 10, 6))
    source_child_event = series.children.create!(date: Time.zone.local(2018, 10, 6))

    junior_men_17_18 = ::Category.find_or_create_by_normalized_name("Junior Men 17-18")
    source_race = source_child_event.races.create!(category: junior_men_17_18)
    person_1 = FactoryBot.create(:person)
    source_race.results.create!(place: 1, person: person_1, time: 1700)
    person_2 = FactoryBot.create(:person)
    source_race.results.create!(place: 2, person: person_2, time: 1749)

    person_3 = FactoryBot.create(:person)
    junior_men_15_16 = ::Category.find_or_create_by_normalized_name("Junior Men 15-16")
    source_race = source_child_event.races.create!(category: junior_men_15_16)
    source_race.results.create!(place: 1, person: person_3, age: 15)
    junior_men_3_4_5 = ::Category.find_or_create_by_normalized_name("Junior Men 3/4/5")
    source_race = source_child_event.races.create!(category: junior_men_3_4_5)
    source_race.results.create!(place: 3, person: person_3, age: 15)
    men_5 = ::Category.find_or_create_by_normalized_name("Men 5")
    source_race = source_child_event.races.create!(category: men_5)
    source_race.results.create!(place: "DNF", person: person_3, time: 2851, age: 15)

    athena = ::Category.find_or_create_by_normalized_name("Athena")
    source_race = source_child_event.races.create!(category: athena)
    person_4 = FactoryBot.create(:person)
    source_race.results.create!(place: 1, person: person_4, time: 2915, age: 49)

    calculation = Calculations::V3::Calculation.create!(
      group_by: "age",
      place_by: "place",
      year: 2018
    )
    calculation.events << source_child_event
    men_9_18 = ::Category.find_or_create_by_normalized_name("Men 9-18")
    calculation.calculation_categories.create! category: men_9_18
    women_35_49 = ::Category.find_or_create_by_normalized_name("Women 35-49")
    calculation.calculation_categories.create! category: women_35_49
    calculation.calculation_categories.create! category: junior_men_3_4_5, reject: true

    calculation.calculate!

    calculation_event = calculation.reload.event
    assert_equal 2, calculation_event.races.size, calculation_event.races.map(&:name)

    race = calculation_event.races.detect { |r| r.category == men_9_18 }
    results = race.results.sort
    assert_equal 5, results.size

    result = results.first
    assert result.person == person_1 || result.person == person_3
    assert_equal "1", result.place
    assert_equal 1, result.sources.size

    result = results[1]
    assert result.person == person_1 || result.person == person_3
    assert_equal "1", result.place
    assert_equal 1, result.sources.size

    result = results[2]
    assert_equal person_2, result.person
    assert_equal "3", result.place
    assert_equal 1, result.sources.size

    race = calculation_event.races.detect { |r| r.category == women_35_49 }
    results = race.results.sort
    assert_equal 1, results.size

    result = results.first
    assert_equal person_4, result.person
    assert_equal "1", result.place
    assert_equal 1, result.sources.size
  end
  
  # TODO Create second series event + calculation with results
  # TODO Create calculation that uses series child calculations
end
