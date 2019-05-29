# frozen_string_literal: true

require "test_helper"

# :stopdoc:
class Calculations::V3::OBRACompetitionTest < ActiveSupport::TestCase
  setup { FactoryBot.create :discipline }

  test "#calculate!" do
    calculation = Calculations::V3::Calculation.create!(
      members_only: true,
      points_for_place: [100, 75, 60, 50, 45, 40, 35, 30, 25, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10],
      specific_events: true
    )
    senior_men = ::Category.find_or_create_by(name: "Senior Men")
    calculation.categories << senior_men
    senior_women = ::Category.find_or_create_by(name: "Senior Women")
    calculation.categories << senior_women
    category_4_men = Category.find_or_create_by(name: "Category 4 Men")

    # Not calculation events
    race = FactoryBot.create :race, category: senior_men
    FactoryBot.create :result, race: race
    race = FactoryBot.create :race, category: senior_women
    FactoryBot.create :result, race: race
    race = FactoryBot.create :race, category: category_4_men
    FactoryBot.create :result, race: race

    event = FactoryBot.create :event
    race = event.races.create!(category: senior_men)
    person = FactoryBot.create :person
    race.results.create!(place: 1, person: person)

    calculation.events << event

    calculation.calculate!

    event = calculation.reload.event
    assert_equal 2, event.races.size

    race = event.races.detect { |r| r.category == senior_men }
    assert_equal 1, race.results.size
    result = race.results.first
    assert_equal 100, result.points
    assert_equal person, result.person
  end
end
