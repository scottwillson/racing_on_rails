# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + "/acceptance_test")

# :stopdoc:
class CalculationsTest < AcceptanceTest
  test "calculated results" do
    series = Series.create!(name: "Mt. Tabor Series")
    source_child_event = series.children.create!

    calculation = series.calculations.create!(points_for_place: [100, 50, 25, 12])
    category = Category.find_or_create_by(name: "Women A")
    calculation.categories << category

    source_race = source_child_event.races.create!(category: category)
    person = FactoryBot.create(:person, name: "Jane Racer")
    source_race.results.create!(place: 1, person: person)

    rejected_category = Category.find_or_create_by(name: "Women B")
    source_race = source_child_event.races.create!(category: rejected_category)
    person = FactoryBot.create(:person, name: "Liz B-Racer")
    source_race.results.create!(place: 1, person: person)

    calculation.calculate!

    visit "/results/#{series.year}"
    assert_page_has_content "Mt. Tabor Series"

    click_link "Mt. Tabor Series", match: :first
    assert_page_has_content "Mt. Tabor Series"

    click_link "Overall"
    assert_page_has_content "Women A"
    assert_page_has_content "Jane Racer"
    assert_page_has_content 100

    assert_page_has_no_content "Women B"
    assert_page_has_no_content "Liz B-Racer"

    click_link "Show all results"
    assert_page_has_content "Women A"
    assert_page_has_content "Jane Racer"
    assert_page_has_content 100

    assert_page_has_content "Women B"
    assert_page_has_content "Liz B-Racer"
  end
end
