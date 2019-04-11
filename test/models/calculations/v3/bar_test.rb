# frozen_string_literal: true

require "test_helper"

# :stopdoc:
class Calculations::V3::BarTest < ActiveSupport::TestCase
  test "#calculate!" do
    Timecop.freeze(2019) do
      calculation = Calculations::V3::Calculation.create!(
        discipline: Discipline[:road],
        members_only: true,
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
      Calculations::V3::Calculation.create!(
        discipline: Discipline[:criterium],
        key: "criterium",
        members_only: true,
        points_for_place: [15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
        weekday_events: false
      )

      Calculations::V3::Calculation.create!(
        discipline: Discipline[:road],
        key: "road",
        members_only: true,
        points_for_place: [15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
        weekday_events: false
      )

      calculation = Calculations::V3::Calculation.create!(
        members_only: true,
        points_for_place: [15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
        source_events: %w[criterium_bar road_bar],
        weekday_events: false
      )
    end
  end
end
