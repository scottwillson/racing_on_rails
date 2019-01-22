# frozen_string_literal: true

require "test_helper"

# :stopdoc:
class Calculations::V3::CalculationTest < ActiveSupport::TestCase
  test "simplest #calculate!" do
    series = WeeklySeries.create!
    source_child_event = series.children.create!

    calculation = series.calculations.create!
    category = Category.find_or_create_by(name: "Men A")
    calculation.categories << category

    source_race = source_child_event.races.create!(category: category)
    person = FactoryBot.create(:person)
    source_result = source_race.results.create!(place: 1, person: person)

    calculation.calculate!

    overall = calculation.reload.event
    assert series.children.reload.include?(overall), "should add overall as child event"

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

  test "series #calculate!" do
    previous_year_series = WeeklySeries.create!(date: 1.year.ago)
    category = Category.find_or_create_by(name: "Men A")
    source_child_event = previous_year_series.children.create!(date: 1.year.ago)
    source_race = source_child_event.races.create!(category: category)
    source_race.results.create!(place: 1, person: FactoryBot.create(:person))
    source_race.results.create!(place: 2, person: FactoryBot.create(:person))

    series = WeeklySeries.create!
    source_child_event = series.children.create!

    calculation = series.calculations.create!
    calculation.categories << category

    source_race = source_child_event.races.create!(category: category)
    person = FactoryBot.create(:person)
    source_result = source_race.results.create!(place: 1, person: person)

    calculation.calculate!

    overall = calculation.reload.event
    assert series.children.reload.include?(overall), "should add overall as child event"

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
    
  end
end
