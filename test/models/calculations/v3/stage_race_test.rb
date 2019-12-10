# frozen_string_literal: true

require "test_helper"

# :stopdoc:
class Calculations::V3::StageRaceTest < ActiveSupport::TestCase
  test "#calculate!" do
    category = ::Category.find_or_create_by_normalized_name("Pro/1/2 Women")
    event = MultiDayEvent.create!(date: Time.zone.local(2018, 6, 29))
    Discipline.create!(name: "Road")

    calculation = Calculations::V3::Calculation.create!(
      disciplines: [Discipline[:road]],
      members_only: true,
      name: "Road BAR",
      points_for_place: [15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
      weekday_events: false,
      year: 2018
    )
    calculation.categories << category

    race = event.races.create!(category: category)
    person = FactoryBot.create(:person)
    gc_result = race.results.create!(place: 4, person: person)

    child = event.children.create!(date: Time.zone.local(2018, 6, 29))
    race = child.races.create!(category: category)
    race.results.create!(place: 1, person: person)

    child = event.children.create!(date: Time.zone.local(2018, 6, 30), discipline: "Time Trial")
    race = child.races.create!(category: category)
    race.results.create!(place: 2, person: person)

    child = event.children.create!(date: Time.zone.local(2018, 7, 1))
    race = child.races.create!(category: category)
    race.results.create!(place: 3, person: person)

    child = event.children.create!(date: Time.zone.local(2018, 7, 1), discipline: "Criterium")
    race = child.races.create!(category: category)
    race.results.create!(place: 5, person: person)

    calculation.calculate!

    bar = calculation.reload.event

    assert_equal 1, bar.races.size, bar.races.map(&:name)
    results = bar.races.first.results
    assert_equal 1, results.size

    result = results.first
    assert_equal 3, result.sources.size
    assert_equal(2, result.sources.count { |s| s.rejection_reason.nil? }, result.sources.map(&:rejection_reason))
    source = result.sources.detect { |s| s.source_result == gc_result }
    assert source.rejected?
    assert_equal "calculated", source.rejection_reason
  end
end
