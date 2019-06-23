# frozen_string_literal: true

require "test_helper"

# :stopdoc:
class Calculations::V3::AgeGroupsByTimeTest < ActiveSupport::TestCase
  setup { FactoryBot.create :discipline }

  test "#calculate!" do
    series = WeeklySeries.create!(date: Time.zone.local(2018, 10, 6))
    source_child_event = series.children.create!(date: Time.zone.local(2018, 10, 6))

    junior_men_17_18 = ::Category.find_or_create_by_normalized_name("Junior Men 17-18")
    source_race = source_child_event.races.create!(category: junior_men_17_18)
    person_1 = FactoryBot.create(:person)
    source_race.results.create!(place: 1, person: person_1, time: 1700)

    calculation = series.calculations.create!(
      place_by: "time",
      year: 2018
    )
    men_9_18 = ::Category.find_or_create_by_normalized_name("Men 9-18")
    calculation.calculation_categories.create! category: men_9_18, reject: true

    calculation.calculate!

    calculation_event = calculation.reload.event
    assert_equal 1, calculation_event.races.size, calculation_event.races.map(&:name)

    race = calculation_event.races.first
    results = race.results.sort
    assert_equal 1, results.size

    result = results.first
    assert_equal person_1, result.person
    assert_equal "1", result.place
    assert_equal 1, result.sources.size
  end
end
