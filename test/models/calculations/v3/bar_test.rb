# frozen_string_literal: true

require "test_helper"

# :stopdoc:
class Calculations::V3::BarTest < ActiveSupport::TestCase
  test "#calculate!" do
    Discipline.create!(name: "Road")

    Timecop.freeze(2019) do
      calculation = Calculations::V3::Calculation.create!(
        disciplines: [Discipline[:road]],
        members_only: true,
        name: "Road BAR",
        points_for_place: [15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
        weekday_events: false
      )

      category_3_men = ::Category.find_or_create_by(name: "Category 3 Men")
      calculation.categories << ::Category.find_or_create_by(name: "Senior Men")
      calculation.categories << ::Category.find_or_create_by(name: "Junior Men")
      calculation.categories << category_3_men

      event = FactoryBot.create(:event, date: Time.zone.local(2019, 3, 31))
      calculation.calculations_events.create!(event: event, multiplier: 2)
      source_race = event.races.create!(category: category_3_men)
      person = FactoryBot.create(:person)
      source_race.results.create!(place: 7, person: person)

      person = FactoryBot.create(:past_member)
      source_race.results.create!(place: 3, person: person)

      calculation.calculate!

      bar = calculation.reload.event

      assert_equal "Road BAR", bar.name
      assert_equal 3, bar.races.size
      race = bar.races.detect { |r| r.category == category_3_men }
      assert_not_nil race

      results = race.results.sort
      assert_equal 2, results.size

      assert_equal 1, results.first.source_results.size
      assert_nil results.first.rejection_reason
      assert_equal 18, results.first.points

      assert_equal 0, results.second.points
      assert 0, results.second.rejected?
      assert_equal "members_only", results.second.rejection_reason
    end
  end

  test "overall BAR" do
    Timecop.freeze(2019) do
      criterium_discipline = Discipline.create!(name: "Criterium")
      circuit_race_discipline = Discipline.create!(name: "Circuit Race")
      road_discipline = Discipline.create!(name: "Road")
      senior_women = ::Category.find_or_create_by(name: "Senior Women")

      criterium = Calculations::V3::Calculation.create!(
        disciplines: [criterium_discipline],
        key: "criterium_bar",
        members_only: true,
        name: "Criterium BAR",
        points_for_place: [15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
        weekday_events: false
      )
      criterium.categories << senior_women

      road = Calculations::V3::Calculation.create!(
        disciplines: [circuit_race_discipline, road_discipline],
        key: "road_bar",
        name: "Road BAR",
        members_only: true,
        points_for_place: [15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
        weekday_events: false
      )
      road.categories << senior_women

      overall = Calculations::V3::Calculation.create!(
        members_only: true,
        name: "Overall BAR",
        points_for_place: (1..300).to_a.reverse,
        source_event_keys: %w[criterium_bar road_bar],
        weekday_events: true
      )
      overall.categories << senior_women

      event = FactoryBot.create :event, date: Time.zone.local(2019, 4, 13)
      race = event.races.create!(category: senior_women)
      person = FactoryBot.create :person
      race.results.create!(place: 12, person: person)

      # Another non-BAR competition
      FactoryBot.create :result, person: person, competition_result: true

      overall.calculate!

      assert_equal 2, overall.source_events.size

      event = criterium.reload.event

      assert_equal 1, event.races.size
      race = event.races.detect { |r| r.category == senior_women }
      assert_not_nil race

      results = race.results.sort
      assert_equal 0, results.size

      event = road.reload.event

      assert_equal 1, event.races.size
      race = event.races.detect { |r| r.category == senior_women }
      assert_not_nil race

      results = race.results.sort
      assert_equal 1, results.size

      assert_equal 1, results.first.source_results.size
      assert_nil results.first.sources.first.rejection_reason
      assert_equal 4, results.first.points
      assert_equal "1", results.first.place

      event = overall.reload.event

      assert_equal 1, event.races.size
      race = event.races.detect { |r| r.category == senior_women }
      assert_not_nil race

      results = race.results.sort
      assert_equal 1, results.size

      assert_equal 1, results.first.source_results.size
      assert_equal 300, results.first.points
      assert_equal "1", results.first.place
    end
  end
end
