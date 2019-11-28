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
    pro_1_2_men = ::Category.find_or_create_by(name: "Pro/1/2 Men")
    calculation.categories << pro_1_2_men
    women_1_2_3 = ::Category.find_or_create_by(name: "Women 1/2/3")
    calculation.categories << women_1_2_3
    category_4_men = Category.find_or_create_by(name: "Category 4 Men")

    # Not calculation events
    race = FactoryBot.create :race, category: pro_1_2_men
    FactoryBot.create :result, race: race
    race = FactoryBot.create :race, category: women_1_2_3
    FactoryBot.create :result, race: race
    race = FactoryBot.create :race, category: category_4_men
    FactoryBot.create :result, race: race

    event = FactoryBot.create :event
    senior_men = ::Category.find_or_create_by(name: "Senior Men")
    race = event.races.create!(category: senior_men)
    person = FactoryBot.create :person
    race.results.create!(place: 1, person: person)

    # Not calculation category
    race = event.races.create!(category: Category.find_or_create_by(name: "Masters Men 40+"))
    race.results.create!(place: 1, person: FactoryBot.create(:person))

    calculation.events << event

    calculation.calculate!

    event = calculation.reload.event
    assert_equal 3, event.races.size, event.races.map(&:name)

    race = event.races.detect { |r| r.category == pro_1_2_men }
    assert_equal 1, race.results.size, race.results.flat_map(&:source_results).map(&:race_name)
    result = race.results.first
    assert_equal 100, result.points
    assert_equal person, result.person
  end
end
