# frozen_string_literal: true

require "test_helper"

# :stopdoc:
class Calculations::V3::SeriesTest < ActiveSupport::TestCase
  setup { FactoryBot.create :discipline }

  test "#calculate!" do
    previous_year_series = WeeklySeries.create!(date: Time.zone.local(2018, 8, 11))
    men_a = Category.find_or_create_by_normalized_name("Men A")
    source_child_event = previous_year_series.children.create!(date: Time.zone.local(2018, 8, 11))
    source_race = source_child_event.races.create!(category: men_a)
    source_race.results.create!(place: 1, person: FactoryBot.create(:person))
    source_race.results.create!(place: 2, person: FactoryBot.create(:person))

    different_series = WeeklySeries.create!(date: Time.zone.local(2018, 8, 25))
    source_child_event = different_series.children.create!(date: Time.zone.local(2018, 8, 25))
    source_race = source_child_event.races.create!(category: men_a)
    team = FactoryBot.create(:team)
    person_1 = FactoryBot.create(:person, team: team, name: "First Place")
    source_race.results.create!(place: 1, person: person_1, team: team)
    source_race.results.create!(place: 2, person: FactoryBot.create(:person))

    series = WeeklySeries.create!(date: Time.zone.local(2019, 3, 9))
    series.children.create!(date: Time.zone.local(2019, 3, 9))
    source_child_event = series.children.create!(date: Time.zone.local(2019, 3, 18))

    source_race = source_child_event.races.create!(category: men_a)
    source_result_1 = source_race.results.create!(place: 1, person: person_1, team: team)
    person_2 = FactoryBot.create(:person, name: "Second Place")
    source_result_2 = source_race.results.create!(place: 2, person: person_2)

    women_b = Category.find_or_create_by_normalized_name("Women B")
    source_race = source_child_event.races.create!(category: women_b)
    person_3 = FactoryBot.create(:person, name: "Third Place")
    source_race.results.create!(place: 1, person: person_3)

    series.children.create!(date: Time.zone.local(2019, 3, 18))

    calculation = series.calculations.create!(
      double_points_for_last_event: true,
      points_for_place: [100, 90, 75, 50, 40, 30, 20, 10],
      year: 2019
    )
    calculation.categories << men_a

    # Non-series event
    event = FactoryBot.create(:event, date: Time.zone.local(2018, 5, 1))
    race = event.races.create!(category: women_b)
    race.results.create!(place: "3", person: person_3)

    calculation.calculate!

    series.reload
    assert_equal_dates Date.new(2019, 3, 9), series.date
    assert_equal_dates Date.new(2019, 3, 18), series.end_date

    overall = calculation.reload.event
    assert_equal_dates Date.new(2019, 3, 9), overall.date
    assert_equal_dates Date.new(2019, 3, 18), overall.end_date
    assert series.children.reload.include?(overall), "should add overall as child event"
    assert overall.series_overall?
    assert_not_equal series, overall

    assert_equal 2, overall.races.size, overall.races.map(&:name)
    men_a_overall_race = overall.races.detect { |r| r.category == men_a }
    assert_not_nil(men_a_overall_race, "Should have Men A overall race")

    results = men_a_overall_race.results.sort
    assert_equal 2, results.size

    result = results.first
    assert_equal person_1, result.person
    assert_equal "1", result.place
    assert_equal 200, result.points
    assert_equal team, result.team

    assert_equal 1, result.sources.size
    source = result.sources.first
    assert_equal 200, source.points
    assert_nil source.rejection_reason
    assert_equal source_result_1, source.source_result

    result = results.second
    assert_equal person_2, result.person
    assert_equal "2", result.place
    assert_equal 180, result.points

    assert_equal 1, result.sources.size
    source = result.sources.first
    assert_equal 180, source.points
    assert_nil source.rejection_reason
    assert_equal source_result_2, source.source_result

    women_b_overall_race = overall.races.detect { |r| r.category == women_b }
    assert_not_nil(women_b_overall_race, "Should have Women B overall race")
    assert women_b_overall_race.rejected?
    assert_equal "not_calculation_category", women_b_overall_race.rejection_reason

    results = women_b_overall_race.results.sort
    assert_equal 1, results.size

    result = results.first
    assert_equal person_3, result.person
    assert_equal "not_calculation_category", result.rejection_reason
    assert result.rejected?
    assert_equal "", result.place
    assert_equal 0, result.points
    assert_equal 1, result.sources.size
    source = result.sources.first
    assert_equal 0, source.points
    assert source.rejected?
    assert_equal "not_calculation_category", source.rejection_reason

    # Validate multiple calculations
    assert_difference "Result.count", 0 do
      calculation.reload.calculate!
    end

    assert_equal 0, calculation.events.size
    assert_equal 3, calculation.source_events.size
  end
end
