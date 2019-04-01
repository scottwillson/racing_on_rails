# frozen_string_literal: true

require "test_helper"

# :stopdoc:
class Calculations::V3::BarTest < ActiveSupport::TestCase
  test "#calculate!" do
    Timecop.freeze(2019) do
      calculation = Calculations::V3::Calculation.create!(
        discipline: Discipline[:road],
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
      source_result = source_race.results.create!(place: 7, person: person)

      calculation.calculate!

      bar = calculation.reload.event

      assert_equal 3, bar.races.size
      race = bar.races.detect { |race| race.category == category_3_men }
      assert_not_nil race

      results = race.results
      assert_equal 1, results.size
      assert_equal 1, results.first.source_results.size
      assert_equal 18, results.first.points
    end
  end
end
