# frozen_string_literal: true

require "test_helper"

# :stopdoc:
class Calculations::V3::TeamTest < ActiveSupport::TestCase
  setup { FactoryBot.create :discipline }

  test "#calculate!" do
    series = WeeklySeries.create!(date: Time.zone.local(2018, 10, 6))
    source_child_event = series.children.create!(date: Time.zone.local(2018, 10, 6))

    athena = ::Category.find_or_create_by_normalized_name("Athena")
    source_race = source_child_event.races.create!(category: athena)
    person_1 = FactoryBot.create(:person)
    team = FactoryBot.create(:team)
    source_race.results.create!(place: 1, person: person_1, team: team)
    person_2 = FactoryBot.create(:person)
    source_race.results.create!(place: 2, person: person_2)

    calculation = series.calculations.create!(
      missing_result_penalty: 100,
      points_for_place: (1..100).to_a,
      results_per_event: 10,
      team: true,
      year: 2018
    )
    calculation.calculation_categories.create!(category: athena, source_only: true)
    calculation.calculation_categories.create!(category: ::Category.find_or_create_by_normalized_name("Team"))

    calculation.calculate!
  end
end
