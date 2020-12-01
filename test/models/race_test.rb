# frozen_string_literal: true

require File.expand_path("../test_helper", __dir__)

# :stopdoc:
class RaceTest < ActiveSupport::TestCase
  test "new category name" do
    race = Race.new(category_name: "Masters 35+ Women")
    assert_equal("Masters 35+ Women", race.name, "race name")
  end

  test "save existing category" do
    race = Race.new(
      event: FactoryBot.create(:event),
      category_name: "Masters 35+ Women"
    )
    race.find_associated_records
    race.save!
  end

  test "result columns" do
    event = SingleDayEvent.create!
    race = Race.create!(category_name: "Masters Women", event: event)
    assert_equal(Race::DEFAULT_RESULT_COLUMNS, race.result_columns_or_default, "race result_columns")
    race.save!
    race.reload
    assert_equal(Race::DEFAULT_RESULT_COLUMNS, race.result_columns_or_default, "race result_columns after save")

    result_columns = %w[place first_name last_name category]
    race.result_columns = result_columns
    race.save!
    race.reload
    assert_equal(result_columns, race.result_columns_or_default, "race result_columns after save")

    event = SingleDayEvent.create!
    race = Race.create!(category_name: "Masters Women 50+", event: event, result_columns: result_columns)
    assert_equal(result_columns, race.result_columns_or_default, "race result_columns")
    race.save!
    race.reload
    assert_equal(result_columns, race.result_columns_or_default, "race result_columns after save")
  end

  test "custom result column" do
    event = SingleDayEvent.create!
    race = Race.create!(category_name: "Masters Women", event: event)

    race.result_columns = %w[place name hometown category]
    race.save
    assert race.valid?, "Race with custom result column should be valid"
  end

  test "bar points" do
    race = FactoryBot.create(:race)
    assert_nil(race[:bar_points], "BAR points column value")
    assert_equal(1, race.bar_points, "BAR points")

    race.bar_points = 1
    race.save!
    assert_nil(race[:bar_points], "BAR points column value")
    assert_equal(1, race.bar_points, "BAR points")

    race.bar_points = 0
    race.save!
    assert_equal(0, race[:bar_points], "BAR points column value")
    assert_equal(0, race.bar_points, "BAR points")

    race.event.bar_points = 2
    race.event.save!
    assert_equal(0, race[:bar_points], "BAR points column value")
    assert_equal(0, race.bar_points, "BAR points")

    race.bar_points = nil
    race.save!
    assert_nil(race[:bar_points], "BAR points column value")
    assert_equal(2, race.bar_points, "BAR points")
  end

  test "bar valid points" do
    event = SingleDayEvent.create!
    race = Race.create!(category_name: "Masters Women", event: event)
    assert_equal(1, race.bar_points, "BAR points")

    assert_raise(ArgumentError, "Fractional BAR points") { race.bar_points = 0.3333 }
    assert_equal(1, race.bar_points, "BAR points")
    race.save!
    assert_equal(1, race.bar_points, "BAR points")
  end

  # Return value from field_size column. If column is blank, count results
  test "field size" do
    race = FactoryBot.create(:race)
    assert_equal(0, race.field_size, "New race field size")

    4.times { FactoryBot.create(:result, race: race) }
    race.results.reload
    assert_equal(4, race.field_size, "Race field size with empty field_size column")

    race.field_size = 120
    assert_equal(120, race.field_size, "Race field size from field_size column")
  end

  test "calculate members only places" do
    event = FactoryBot.create(:event)
    race = event.races.create!(category: FactoryBot.create(:category))
    race.calculate_members_only_places!

    race = event.races.create!(category: FactoryBot.create(:category))
    non_members = []
    (0..2).each do |i|
      non_members << Person.create!(name: "Non member #{i}", member: false)
      assert_not(non_members[i].member?, "Should not be a member")
    end

    weaver = FactoryBot.create(:person)
    molly = FactoryBot.create(:person)

    race.results.create!(place: "1", person: non_members[0])
    race.results.create!(place: "2", person: weaver)
    race.results.create!(place: "3", person: non_members[1])
    race.results.create!(place: "4", person: molly)
    race.results.create!(place: "5", person: non_members[2])

    race.reload.results.reload
    race.calculate_members_only_places!
    assert_equal("1", race.results[0].place, "Result 0 place")
    assert_equal("", race.results[0].members_only_place, "Result 0 place")
    assert_equal(non_members[0], race.results[0].person, "Result 0 person")

    assert_equal("2", race.results[1].place, "Result 1 place")
    assert_equal("1", race.results[1].members_only_place, "Result 1 place")
    assert_equal(weaver, race.results[1].person, "Result 1 person")

    assert_equal("3", race.results[2].place, "Result 2 place")
    assert_equal("", race.results[2].members_only_place, "Result 2 place")
    assert_equal(non_members[1], race.results[2].person, "Result 2 person")

    assert_equal("4", race.results[3].place, "Result 3 place")
    assert_equal("2", race.results[3].members_only_place, "Result 3 place")
    assert_equal(molly, race.results[3].person, "Result 3 person")

    assert_equal("5", race.results[4].place, "Result 4 place")
    assert_equal("", race.results[4].members_only_place, "Result 4 place")
    assert_equal(non_members[2], race.results[4].person, "Result 4 person")
  end

  test "dates of birth" do
    event = SingleDayEvent.create!(date: Time.zone.today)
    senior_men = FactoryBot.create(:category)
    race = event.races.create!(category: senior_men)
    assert_equal_dates(Date.new(Time.zone.today.year - 999, 1, 1), race.dates_of_birth.begin, "race.dates_of_birth.begin")
    assert_equal_dates(Date.new(Time.zone.today.year, 12, 31), race.dates_of_birth.end, "race.dates_of_birth.end")

    event = SingleDayEvent.create!(date: Date.new(2000, 9, 8))
    race = event.races.create!(category: Category.new(name: "Espoirs", ages: 18..23))
    assert_equal_dates(Date.new(1977, 1, 1), race.dates_of_birth.begin, "race.dates_of_birth.begin")
    assert_equal_dates(Date.new(1982, 12, 31), race.dates_of_birth.end, "race.dates_of_birth.end")
  end

  test "create result before" do
    race = SingleDayEvent.create!.races.create!(category_name: "Masters Women")
    existing_result = race.results.create!(place: "1")
    new_result = race.create_result_before(existing_result.id)
    assert_equal(2, race.results.size, "Results")
    results = race.results.to_a.sort
    assert_equal(new_result, results[0], "New result should be first result")
    assert_equal("1", results[0].place, "New result place")
    assert_equal(existing_result, results[1], "Existing result should be second result")
    assert_equal("2", results[1].place, "Existing result place")

    another_new_result = race.create_result_before(new_result.id)
    results = race.results.reload.to_a.sort
    assert_equal(another_new_result, results[0], "New result should be first result")
    assert_equal("1", results[0].place, "New result place")
    assert_equal(new_result, results[1], "Existing result should be second result")
    assert_equal("2", results[1].place, "Existing result place")
    assert_equal(existing_result, results[2], "Existing result should be third result")
    assert_equal("3", results[2].place, "Existing result place")
  end

  test "create result before dnf" do
    race = SingleDayEvent.create!.races.create!(category_name: "Masters Women")
    first_result = race.results.create!(place: "1")
    existing_result = race.results.create!(place: "DNF")
    race.create_result_before(existing_result.id)
    assert_equal(3, race.results.size, "Results")
    results = race.results.to_a.sort
    assert_equal(first_result, results[0], "First result should still be first result")
    assert_equal("1", results[0].place, "First result place")
    assert_equal("DNF", results[1].place, "New result place")
    assert_equal("DNF", results[2].place, "Existing result place")
  end

  test "destroy should destroy related people" do
    FactoryBot.create(:number_issuer)
    FactoryBot.create(:discipline, name: "Road")

    mathew_braun = Person.create!(name: "Mathew Braun", email: "mtb@example.com")
    event = SingleDayEvent.create!
    race = event.races.create!(category: FactoryBot.create(:category))
    weaver = FactoryBot.create(:person)
    race.results.create!(place: "1", person: weaver)
    result = race.results.create!(place: "2", person: Person.new(name: "Jonah Braun"))
    race.results.create!(place: "3", person: mathew_braun)

    jonah = Person.where(first_name: "Jonah", last_name: "Braun").first!
    assert_equal event, jonah.created_by
    assert jonah.created_from_result?

    mathew_braun.reload
    assert_nil mathew_braun.created_by
    assert_not mathew_braun.created_from_result?

    weaver.reload
    assert_nil weaver.created_by
    assert_not weaver.created_from_result?

    race.reload.destroy
    assert_not Result.exists?(result.id), "Should destroy result"
    assert_not Race.exists?(race.id), "Should be destroyed. #{race.errors.full_messages}"
    assert_not Person.exists?(first_name: "Jonah", last_name: "Braun"), "New person Jonah Braun should have been deleted"
    assert  Person.exists?(weaver.id), "Existing person Ryan Weaver should not be deleted"
    assert  Person.exists?(mathew_braun.id), "Existing person with no results Mathew Braun should not be deleted"

    # TODO: Manually-created people that only have this result
    # TODO Teams
  end

  test "destroy_duplicate_results!" do
    race = FactoryBot.create(:race)
    result_1 = FactoryBot.create(:result, place: "1", race: race, event: race.event)
    result_2 = FactoryBot.create(:result, place: "2", race: race, event: race.event)
    FactoryBot.create(:result, place: "3", race: race, event: race.event, person: result_1.person)

    race.destroy_duplicate_results!
    assert_equal [result_1, result_2], race.results.reload
  end

  test "sort rejected races last" do
    races = [
      Race.new(id: 0, category: Category.new(name: "Women A")),
      Race.new(id: 1, category: Category.new(name: "Junior Women"), rejected: true),
      Race.new(id: 2, category: Category.new(name: "Women B"))
    ]

    assert_equal ["Women A", "Women B", "Junior Women"], races.sort.map(&:name)
  end
end
