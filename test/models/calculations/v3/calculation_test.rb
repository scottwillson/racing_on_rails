# frozen_string_literal: true

require "test_helper"

# :stopdoc:
class Calculations::V3::CalculationTest < ActiveSupport::TestCase
  setup { FactoryBot.create :discipline }

  test "simplest #calculate!" do
    Timecop.freeze(2018, 1) do
      series = WeeklySeries.create!(name: "Cross Crusade")
      source_child_event = series.children.create!(date: Time.zone.local(2018, 11, 21))

      calculation = series.calculations.create!(points_for_place: [100, 50, 25, 12])
      category = Category.find_or_create_by(name: "Men A")
      calculation.categories << category

      source_race = source_child_event.races.create!(category: category)
      person = FactoryBot.create(:person)
      source_result = source_race.results.create!(place: 1, person: person)

      calculation.calculate!

      overall = calculation.reload.event
      calculation_event_id = overall.id
      assert series.children.reload.include?(overall), "should add overall as child event"
      assert_equal "Overall", overall.name
      assert_equal "Cross Crusade: Overall", calculation.name

      assert_equal 1, overall.races.size
      men_a_overall_race = overall.races.detect { |race| race.category == category }
      assert_not_nil(men_a_overall_race, "Should have Men A overall race")
      race_ids = overall.races.map(&:id).sort

      results = men_a_overall_race.results
      assert_equal 1, results.size

      result = results.first
      assert_equal person, result.person
      assert_equal "1", result.place
      assert_equal 100, result.points

      assert_equal 1, result.sources.size
      source = result.sources.first
      assert_equal 100, source.points
      assert_nil source.rejection_reason
      assert_equal source_result, source.source_result

      calculation.reload.calculate!
      assert_equal 1, Calculations::V3::Calculation.count, "Reuse existing event"
      assert_equal calculation_event_id, calculation.event.id
      assert_equal 2, series.children.count, "Reuse existing event"
      assert_equal_dates "2018-11-21", calculation.date
      assert_equal_dates "2018-11-21", calculation.end_date
      assert_equal_dates "2018-11-21", calculation.event.date
      assert_equal_dates "2018-11-21", calculation.event.end_date
      assert_equal race_ids, calculation.event.races.map(&:id).sort, "Reuse races"

      calculation.destroy!
      assert_equal 0, Calculations::V3::Calculation.count
      assert_equal 0, ResultSource.count
      assert_equal 1, Result.count
      assert_not Event.exists?(overall.id)
      assert Result.exists?(source_result.id)
    end
  end

  test "delete event" do
    Timecop.freeze(2018, 1) do
      series = WeeklySeries.create!(name: "Cross Crusade")
      source_child_event = series.children.create!(date: Time.zone.local(2018, 11, 21))

      calculation = series.calculations.create!(points_for_place: [100, 50, 25, 12])
      category = Category.find_or_create_by(name: "Men A")
      calculation.categories << category

      source_race = source_child_event.races.create!(category: category)
      person = FactoryBot.create(:person)
      source_result = source_race.results.create!(place: 1, person: person)
      assert_equal 1, Calculations::V3::Calculation.count

      calculation.calculate!
      overall = calculation.reload.event
      overall.destroy_races
      overall.destroy!

      assert_equal 1, Calculations::V3::Calculation.count
      assert_equal 0, ResultSource.count
      assert_equal 1, Result.count
      assert Event.exists?(series.id)
      assert_not Event.exists?(overall.id)
      assert Result.exists?(source_result.id)
    end
  end

  test "delete calculation" do
    Timecop.freeze(2018, 1) do
      series = WeeklySeries.create!(name: "Cross Crusade")
      source_child_event = series.children.create!(date: Time.zone.local(2018, 11, 21))

      calculation = series.calculations.create!(points_for_place: [100, 50, 25, 12])
      category = Category.find_or_create_by(name: "Men A")
      calculation.categories << category

      source_race = source_child_event.races.create!(category: category)
      person = FactoryBot.create(:person)
      source_result = source_race.results.create!(place: 1, person: person)
      assert_equal 1, Calculations::V3::Calculation.count

      calculation.calculate!
      overall = calculation.reload.event
      calculation.destroy!

      assert_equal 0, Calculations::V3::Calculation.count
      assert_equal 0, ResultSource.count
      assert_equal 1, Result.count
      assert Event.exists?(series.id)
      assert_not Event.exists?(overall.id)
      assert Result.exists?(source_result.id)
    end
  end

  test "delete source event" do
    Timecop.freeze(2018, 1) do
      series = WeeklySeries.create!(name: "Cross Crusade")
      source_child_event = series.children.create!(date: Time.zone.local(2018, 11, 21))

      calculation = series.calculations.create!(points_for_place: [100, 50, 25, 12])
      category = Category.find_or_create_by(name: "Men A")
      calculation.categories << category

      source_race = source_child_event.races.create!(category: category)
      person = FactoryBot.create(:person)
      source_result = source_race.results.create!(place: 1, person: person)
      assert_equal 1, Calculations::V3::Calculation.count

      calculation.calculate!
      overall = calculation.reload.event
      source_child_event.destroy_races
      source_child_event.destroy!
      series.destroy_races
      series.destroy!

      assert_equal 0, Calculations::V3::Calculation.count
      assert_equal 0, ResultSource.count
      assert_equal 0, Result.count
      assert_not Event.exists?(series.id)
      assert_not Event.exists?(overall.id)
      assert_not Result.exists?(source_result.id)
    end
  end

  test "delete obsolete races" do
    calculation = Calculations::V3::Calculation.create!
    men_a = ::Category.find_or_create_by(name: "Men A")
    calculation.categories << men_a
    calculation.calculate!

    calculation.categories.delete men_a

    women_a = ::Category.find_or_create_by(name: "Women A")
    calculation.categories << women_a
    calculation = Calculations::V3::Calculation.find(calculation.id)
    calculation.calculate!

    races = calculation.event.races.reload
    assert_equal 1, races.size
    assert_equal "Women A", races.first.name
  end

  test "no source event" do
    Timecop.freeze(2019, 1) do
      calculation = Calculations::V3::Calculation.create!
      assert_equal_dates "2019-01-01", calculation.date
      assert_equal_dates "2019-12-31", calculation.end_date
      calculation.calculate!
      assert_equal_dates "2019-01-01", calculation.event.date
      assert_equal_dates "2019-12-31", calculation.event.end_date
    end
  end

  test "previous year #calculate!" do
    date = 1.year.ago
    series = WeeklySeries.create!(date: date)
    source_child_event = series.children.create!

    calculation = series.calculations.create!(points_for_place: [100, 50, 25, 12], year: 1.year.ago.year)
    category = Category.find_or_create_by(name: "Men A")
    calculation.categories << category

    source_race = source_child_event.races.create!(category: category)
    person = FactoryBot.create(:person)
    source_result = source_race.results.create!(place: 1, person: person)

    calculation.calculate!

    overall = calculation.reload.event
    assert series.children.reload.include?(overall), "should add overall as child event"
    assert_equal_dates date, overall.date
    assert_equal_dates date, overall.end_date

    assert_equal 1, overall.races.size
    men_a_overall_race = overall.races.detect { |race| race.category == category }
    assert_not_nil(men_a_overall_race, "Should have Men A overall race")

    results = men_a_overall_race.results
    assert_equal 1, results.size

    result = results.first
    assert_equal person, result.person
    assert_equal "1", result.place
    assert_equal 100, result.points

    assert_equal 1, result.sources.size
    source = result.sources.first
    assert_equal 100, source.points
    assert_nil source.rejection_reason
    assert_equal source_result, source.source_result
  end

  test "#source_results" do
    FactoryBot.create(:result)

    series = WeeklySeries.create!
    series.children.create! date: Time.zone.local(2011, 1, 5)
    source_child_event = series.children.create! date: Time.zone.local(2011, 1, 12)

    category = Category.find_or_create_by(name: "Men A")
    source_race = source_child_event.races.create!(category: category)
    person = FactoryBot.create(:person)
    source_race.results.create!(place: 1, person: person)

    # Existing Calculation results should be ignored
    overall = series.children.create!
    overall_race = overall.races.create!(category: category)
    overall_race.results.create!(place: 1, person: person, competition_result: true)

    calculation = series.calculations.create!(source_event: series, year: 2011)
    assert_equal 1, calculation.source_results.size
  end
end
