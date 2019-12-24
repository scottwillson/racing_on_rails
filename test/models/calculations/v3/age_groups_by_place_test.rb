# frozen_string_literal: true

require "test_helper"

# :stopdoc:
class Calculations::V3::AgeGroupsByPlaceTest < ActiveSupport::TestCase
  setup { FactoryBot.create :discipline }

  test "#calculate!" do
    series = WeeklySeries.create!(date: Time.zone.local(2018, 10, 6))
    source_child_event = series.children.create!(date: Time.zone.local(2018, 10, 6))

    junior_men_17_18 = ::Category.find_or_create_by_normalized_name("Junior Men 17-18")
    source_race = source_child_event.races.create!(category: junior_men_17_18)
    person_1 = FactoryBot.create(:person, name: "Person 1")
    source_race.results.create!(place: 1, person: person_1, time: 1700)
    person_2 = FactoryBot.create(:person, name: "Person 2")
    source_race.results.create!(place: 2, person: person_2, time: 1749)

    person_3 = FactoryBot.create(:person, name: "Person 3")
    junior_men_15_16 = ::Category.find_or_create_by_normalized_name("Junior Men 15-16")
    source_race = source_child_event.races.create!(category: junior_men_15_16)
    source_race.results.create!(place: 1, person: person_3)
    junior_men_3_4_5 = ::Category.find_or_create_by_normalized_name("Junior Men 3/4/5")
    source_race = source_child_event.races.create!(category: junior_men_3_4_5)
    source_race.results.create!(place: 3, person: person_3)
    men_5 = ::Category.find_or_create_by_normalized_name("Men 5")
    source_race = source_child_event.races.create!(category: men_5)
    source_race.results.create!(place: "DNF", person: person_3, time: 2851)

    athena = ::Category.find_or_create_by_normalized_name("Athena")
    source_race = source_child_event.races.create!(category: athena)
    person_4 = FactoryBot.create(:person, name: "Person 4")
    source_race.results.create!(place: 1, person: person_4, time: 2915, age: 49)

    calculation = Calculations::V3::Calculation.create!(
      group_by: "age",
      place_by: "place",
      specific_events: true,
      year: 2018
    )
    calculation.events << source_child_event
    men_9_18 = ::Category.find_or_create_by_normalized_name("Men 9-18")
    calculation.calculation_categories.create! category: men_9_18
    men_19_34 = ::Category.find_or_create_by_normalized_name("Men 19-34")
    calculation.calculation_categories.create! category: men_19_34
    women_35_49 = ::Category.find_or_create_by_normalized_name("Women 35-49")
    calculation.calculation_categories.create! category: women_35_49
    calculation.calculation_categories.create! category: junior_men_3_4_5, reject: true

    calculation.calculate!

    calculation_event = calculation.reload.event
    assert_equal 3, calculation_event.races.size, calculation_event.races.map(&:name)

    race = calculation_event.races.detect { |r| r.category == men_9_18 }
    results = race.results.sort
  end

  test "team standings from age groups" do
    # Series with 2 events
    series = WeeklySeries.create!(date: Time.zone.local(2018, 10, 6))
    source_child_event = series.children.create!(date: Time.zone.local(2018, 10, 6))
    source_child_event_2 = series.children.create!(date: Time.zone.local(2018, 10, 13))

    # First event results
    junior_men_17_18 = ::Category.find_or_create_by_normalized_name("Junior Men 17-18")
    source_race = source_child_event.races.create!(category: junior_men_17_18)
    team_1 = FactoryBot.create(:team, name: "Team 1")
    person_1 = FactoryBot.create(:person, name: "Person 1", team: team_1)
    source_race.results.create!(place: 1, person: person_1, time: 1700)
    team_2 = FactoryBot.create(:team, name: "Team 2")
    person_2 = FactoryBot.create(:person, name: "Person 2", team: team_2)
    source_race.results.create!(place: 2, person: person_2, time: 1749)

    person_3 = FactoryBot.create(:person, name: "Person 3", team: team_2)
    junior_men_15_16 = ::Category.find_or_create_by_normalized_name("Junior Men 15-16")
    source_race = source_child_event.races.create!(category: junior_men_15_16)
    source_race.results.create!(place: 1, person: person_3)
    junior_men_3_4_5 = ::Category.find_or_create_by_normalized_name("Junior Men 3/4/5")
    source_race = source_child_event.races.create!(category: junior_men_3_4_5)
    source_race.results.create!(place: 3, person: person_3)
    men_5 = ::Category.find_or_create_by_normalized_name("Men 5")
    source_race = source_child_event.races.create!(category: men_5)
    source_race.results.create!(place: "DNF", person: person_3, time: 2851)

    athena = ::Category.find_or_create_by_normalized_name("Athena")
    source_race = source_child_event.races.create!(category: athena)
    person_4 = FactoryBot.create(:person, name: "Person 4", team: team_1)
    source_race.results.create!(place: 1, person: person_4, time: 2915, age: 49)

    # First event results by age and place
    calculation = Calculations::V3::Calculation.create!(
      group_by: "age",
      key: :event_1,
      place_by: "place",
      specific_events: true,
      year: 2018
    )
    calculation.events << source_child_event
    men_9_18 = ::Category.find_or_create_by_normalized_name("Men 9-18")
    calculation.calculation_categories.create! category: men_9_18
    men_19_34 = ::Category.find_or_create_by_normalized_name("Men 19-34")
    calculation.calculation_categories.create! category: men_19_34
    women_35_49 = ::Category.find_or_create_by_normalized_name("Women 35-49")
    calculation.calculation_categories.create! category: women_35_49
    calculation.calculation_categories.create! category: junior_men_3_4_5, reject: true

    # Second event results
    source_race = source_child_event_2.races.create!(category: junior_men_15_16)
    source_race.results.create!(place: 11, person: person_1)
    team_3 = FactoryBot.create(:team, name: "Team 3")
    person_5 = FactoryBot.create(:person, name: "Person 5", team: team_3)
    source_race.results.create!(place: 3, person: person_5)

    # Second event results by age and place
    calculation = Calculations::V3::Calculation.create!(
      group_by: "age",
      key: :event_2,
      place_by: "place",
      specific_events: true,
      year: 2018
    )
    calculation.events << source_child_event_2
    calculation.calculation_categories.create! category: men_9_18
    calculation.calculation_categories.create! category: men_19_34
    calculation.calculation_categories.create! category: women_35_49
    calculation.calculation_categories.create! category: junior_men_3_4_5, reject: true

    # Series team calculation uses points from event calculations
    calculation = Calculations::V3::Calculation.create!(
      source_event_keys: %i[ event_1 event_2 ],
      team: true,
      year: 2018
    )

    calculation.calculate!

    calculation_event = calculation.reload.event
    assert_equal 1, calculation_event.races.size, calculation_event.races.map(&:name)
    results = calculation_event.races.first.results.sort
    assert_equal 3, results.size, results.map(&:team_name)
  end
end
