require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class RaceTest < ActiveSupport::TestCase
  test "new category name" do
    race = Race.new(category_name: "Masters 35+ Women")
    assert_equal("Masters 35+ Women", race.name, "race name")
  end

  test "save existing category" do
    race = Race.new(
      event: FactoryGirl.create(:event),
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

    result_columns = ["place", "name", "category"]
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

    race.result_columns = [ "place", "name", "hometown", "category" ]
    race.save
    assert race.valid?, "Race with custom result column should be valid"
  end

  test "bar points" do
    race = FactoryGirl.create(:race)
    assert_nil(race[:bar_points], 'BAR points column value')
    assert_equal(1, race.bar_points, 'BAR points')

    race.bar_points = 1
    race.save!
    assert_nil(race[:bar_points], 'BAR points column value')
    assert_equal(1, race.bar_points, 'BAR points')

    race.bar_points = 0
    race.save!
    assert_equal(0, race[:bar_points], 'BAR points column value')
    assert_equal(0, race.bar_points, 'BAR points')

    race.event.bar_points = 2
    race.event.save!
    assert_equal(0, race[:bar_points], 'BAR points column value')
    assert_equal(0, race.bar_points, 'BAR points')

    race.bar_points = nil
    race.save!
    assert_nil(race[:bar_points], 'BAR points column value')
    assert_equal(2, race.bar_points, 'BAR points')
  end

  test "bar valid points" do
    event = SingleDayEvent.create!
    race = Race.create!(category_name: "Masters Women", event: event)
    assert_equal(1, race.bar_points, 'BAR points')

    assert_raise(ArgumentError, 'Fractional BAR points') {race.bar_points = 0.3333}
    assert_equal(1, race.bar_points, 'BAR points')
    race.save!
    assert_equal(1, race.bar_points, 'BAR points')
  end

  # Return value from field_size column. If column is blank, count results
  test "field size" do
    race = FactoryGirl.create(:race)
    assert_equal(0, race.field_size, 'New race field size')

    4.times { FactoryGirl.create(:result, race: race) }
    race.results(true)
    assert_equal(4, race.field_size, 'Race field size with empty field_size column')

    race.field_size = 120
    assert_equal(120, race.field_size, 'Race field size from field_size column')
  end

  test "place results by points" do
    race = FactoryGirl.create(:race)
    race.place_results_by_points

    first_result = race.results.create!
    second_result = race.results.create!

    race.results(true)
    race.place_results_by_points
    race.results(true)
    assert_equal(first_result, race.results.first, 'First result')
    assert_equal('1', race.results.first.place, 'First result place')
    assert_equal(second_result, race.results.last, 'Last result')
    assert_equal('1', race.results.last.place, 'Last result place')

    race = FactoryGirl.create(:race)
    [
      race.results.create!(points: 90, place: 4),
      race.results.create!(points: 0, place: 5),
      race.results.create!(points: 89, place: 4),
      race.results.create!(points: 89, place: ''),
      race.results.create!(points: 100, place: 1),
      race.results.create!(points: 89)
    ]

    race.results(true)
    race.place_results_by_points
    results = race.results(true).to_a.sort

    assert_equal('1', results[0].place, 'Result 0 place')
    assert_equal(100, results[0].points, 'Result 0 points')

    assert_equal('2', results[1].place, 'Result 1 place')
    assert_equal(90, results[1].points, 'Result 1 points')

    assert_equal('3', results[2].place, 'Result 2 place')
    assert_equal(89, results[2].points, 'Result 2 points')

    assert_equal('3', results[3].place, 'Result 3 place')
    assert_equal(89, results[3].points, 'Result 3 points')

    assert_equal('3', results[4].place, 'Result 4 place')
    assert_equal(89, results[4].points, 'Result 4 points')

    assert_equal('6', results[5].place, 'Result 5 place')
    assert_equal(0, results[5].points, 'Result 5 points')
  end

  # Look at source results for tie-breaking
  # Intentional nonsense in some results and points to test sorting
  test "competition place results by points" do
    race = FactoryGirl.create(:race)

    20.times do
      FactoryGirl.create(:result, race: race)
    end

    ironman = Competitions::Ironman.create!
    ironman_race = ironman.races.create!(category: Category.new(name: 'Ironman'))

    first_competition_result = ironman_race.results.create!
    first_competition_result.scores.create!(source_result: race.results[0], competition_result: first_competition_result, points: 45)

    second_competition_result = ironman_race.results.create!
    second_competition_result.scores.create!(source_result: race.results[2], competition_result: second_competition_result, points: 45)

    third_competition_result = ironman_race.results.create!
    race.results[3].place = 2
    race.results[3].save!
    third_competition_result.scores.create!(source_result: race.results[3], competition_result: third_competition_result, points: 15)
    third_competition_result.scores.create!(source_result: race.results[4], competition_result: third_competition_result, points: 15)
    race.results[4].place = 3
    race.results[4].save!

    fourth_competition_result = ironman_race.results.create!
    fourth_competition_result.scores.create!(source_result: race.results[1], competition_result: fourth_competition_result, points: 30)
    race.results[1].place = 1
    race.results[1].save!

    fifth_competition_result = ironman_race.results.create!
    fifth_competition_result.scores.create!(source_result: race.results[5], competition_result: fifth_competition_result, points: 4)
    race.results[5].place = 15
    race.results[5].save!
    fifth_competition_result.scores.create!(source_result: race.results[7], competition_result: fifth_competition_result, points: 2)
    race.results[7].place = 17
    race.results[7].save!

    sixth_competition_result = ironman_race.results.create!
    sixth_competition_result.scores.create!(source_result: race.results[6], competition_result: sixth_competition_result, points: 5)
    race.results[6].place = 15
    race.results[6].save!
    sixth_competition_result.scores.create!(source_result: race.results[8], competition_result: sixth_competition_result, points: 1)
    race.results[8].place = 18
    race.results[8].save!

    seventh_competition_result = ironman_race.results.create!
    seventh_competition_result.scores.create!(source_result: race.results[11], competition_result: seventh_competition_result, points: 2)
    race.results[11].place = 20
    race.results[11].save!

    eighth_competition_result = ironman_race.results.create!
    eighth_competition_result.scores.create!(source_result: race.results[10], competition_result: eighth_competition_result, points: 1)
    race.results[10].place = 20
    race.results[10].save!
    eighth_competition_result.scores.create!(source_result: race.results[9], competition_result: eighth_competition_result, points: 1)
    race.results[9].place = 25
    race.results[9].save!

    ironman_race.results.each(&:update_points!)
    ironman_race.results(true)
    ironman_race.place_results_by_points(false)
    results = ironman_race.results(true).sort
    assert_equal('1', results.first.place, 'First result place')
    assert_equal('1', results[1].place, 'Second result place')
    assert_equal('3', results[2].place, 'Third result place')
    assert_equal('3', results[3].place, 'Fourth result place')
    assert_equal('5', results[4].place, 'Fifth result place')
    assert_equal('5', results[5].place, 'Sixth result place')
    assert_equal('7', results[6].place, '7th result place')
    assert_equal('7', results[7].place, '8th result place')
  end

  test "most recent placing should break tie" do
    races = []
    races << SingleDayEvent.create!(date: Date.new(2006, 1)).races.create!(category_name: "Masters Men 50+")
    races << SingleDayEvent.create!(date: Date.new(2006, 2)).races.create!(category_name: "Masters Men 50+")
    races << SingleDayEvent.create!(date: Date.new(2006, 3)).races.create!(category_name: "Masters Men 50+")
    races << SingleDayEvent.create!(date: Date.new(2006, 4)).races.create!(category_name: "Masters Men 50+")

    ironman = Competitions::Ironman.create!
    ironman_race = ironman.races.create!(category: Category.new(name: 'Ironman'))

    first_competition_result = ironman_race.results.create!
    first_competition_result.scores.create!(source_result: races[3].results.create!(place: 15), competition_result: first_competition_result, points: 2)

    second_competition_result = ironman_race.results.create!
    second_competition_result.scores.create!(source_result: races[0].results.create!(place: 15), competition_result: second_competition_result, points: 2)

    third_competition_result = ironman_race.results.create!
    third_competition_result.scores.create!(source_result: races[1].results.create!(place: 15), competition_result: third_competition_result, points: 2)

    fourth_competition_result = ironman_race.results.create!
    fourth_competition_result.scores.create!(source_result: races[2].results.create!(place: 15), competition_result: fourth_competition_result, points: 2)

    ironman_race.results(true)
    ironman_race.results.each do |result|
      result.calculate_points
      result.save!
    end
    ironman_race.place_results_by_points
    results = ironman_race.results(true).to_a.sort

    assert_equal("1", results[0].place, "First result place")
    assert_equal(first_competition_result, results[0], "First result")

    assert_equal("2", results[1].place, "Second result place")
    assert_equal(fourth_competition_result, results[1], "Second result")

    assert_equal("3", results[2].place, "Third result place")
    assert_equal(third_competition_result, results[2], "Third result")

    assert_equal("4", results[3].place, "Fourth result place")
    assert_equal(second_competition_result, results[3], "Fourth result")
  end

  test "highest placing in last race should break tie" do
    race = SingleDayEvent.create!(date: Date.new(2006, 10)).races.create!(category_name: "Masters Men 50+")
    second_race = SingleDayEvent.create!(date: Date.new(2006, 11)).races.create!(category_name: "Masters Men 50+")

    ironman = Competitions::Ironman.create!
    ironman_race = ironman.races.create!(category: Category.new(name: 'Ironman'))

    first_competition_result = ironman_race.results.create!
    first_competition_result.scores.create!(source_result: race.results.create!(place: 3), competition_result: first_competition_result, points: 30)
    first_competition_result.scores.create!(source_result: second_race.results.create!(place: 4), competition_result: first_competition_result, points: 20)

    second_competition_result = ironman_race.results.create!
    second_competition_result.scores.create!(source_result: race.results.create!(place: 4), competition_result: second_competition_result, points: 20)
    second_competition_result.scores.create!(source_result: second_race.results.create!(place: 3), competition_result: second_competition_result, points: 30)

    ironman_race.results(true)
    ironman_race.results.each do |result|
      result.calculate_points
      result.save!
    end
    ironman_race.place_results_by_points
    results = ironman_race.results(true).to_a.sort

    assert_equal("1", results[0].place, "First result place")
    assert_equal("2", results[1].place, "Second result place")
    assert_equal(first_competition_result, results[1], "Second result")
  end

  test "highest placing in most recent race should break tie" do
    race = SingleDayEvent.create!(date: Date.new(2006, 10)).races.create!(category_name: "Masters Men 50+")
    second_race = SingleDayEvent.create!(date: Date.new(2006, 11)).races.create!(category_name: "Masters Men 50+")
    third_race = SingleDayEvent.create!(date: Date.new(2006, 12)).races.create!(category_name: "Masters Men 50+")

    ironman = Competitions::Ironman.create!
    ironman_race = ironman.races.create!(category: Category.new(name: 'Ironman'))

    first_competition_result = ironman_race.results.create!
    first_competition_result.scores.create!(source_result: race.results.create!(place: 4), competition_result: first_competition_result, points: 20)
    first_competition_result.scores.create!(source_result: second_race.results.create!(place: 2), competition_result: first_competition_result, points: 30)
    first_competition_result.scores.create!(source_result: third_race.results.create!(place: 10), competition_result: first_competition_result, points: 1)

    second_competition_result = ironman_race.results.create!
    second_competition_result.scores.create!(source_result: race.results.create!(place: 2), competition_result: second_competition_result, points: 30)
    second_competition_result.scores.create!(source_result: second_race.results.create!(place: 4), competition_result: second_competition_result, points: 20)
    second_competition_result.scores.create!(source_result: third_race.results.create!(place: 10), competition_result: second_competition_result, points: 1)

    third_competition_result = ironman_race.results.create!
    third_competition_result.scores.create!(source_result: second_race.results.create!(place: 1), competition_result: third_competition_result, points: 50)
    third_competition_result.scores.create!(source_result: third_race.results.create!(place: 10), competition_result: third_competition_result, points: 1)

    ironman_race.results(true)
    ironman_race.results.each do |result|
      result.calculate_points
      result.save!
    end
    ironman_race.place_results_by_points
    results = ironman_race.results(true).to_a.sort

    assert_equal("1", results[0].place, "First result place")
    assert_equal(third_competition_result, results[0], "First result")

    assert_equal("2", results[1].place, "Second result place")
    assert_equal(first_competition_result, results[1], "2nd result")

    assert_equal("3", results[2].place, "Third result place")
    assert_equal(second_competition_result, results[2], "3rd result")
  end

  test "calculate members only places" do
    event = FactoryGirl.create(:event)
    race = event.races.create!(category: FactoryGirl.create(:category))
    race.calculate_members_only_places!

    race = event.races.create!(category: FactoryGirl.create(:category))
    non_members = []
    for i in 0..2
      non_members << Person.create!(name: "Non member #{i}", member: false)
      assert(!non_members[i].member?, 'Should not be a member')
    end

    weaver = FactoryGirl.create(:person)
    molly = FactoryGirl.create(:person)

    race.results.create!(place: '1', person: non_members[0])
    race.results.create!(place: '2', person: weaver)
    race.results.create!(place: '3', person: non_members[1])
    race.results.create!(place: '4', person: molly)
    race.results.create!(place: '5', person: non_members[2])

    race.reload.results(true)
    race.calculate_members_only_places!
    assert_equal('1', race.results[0].place, 'Result 0 place')
    assert_equal('', race.results[0].members_only_place, 'Result 0 place')
    assert_equal(non_members[0], race.results[0].person, 'Result 0 person')

    assert_equal('2', race.results[1].place, 'Result 1 place')
    assert_equal('1', race.results[1].members_only_place, 'Result 1 place')
    assert_equal(weaver, race.results[1].person, 'Result 1 person')

    assert_equal('3', race.results[2].place, 'Result 2 place')
    assert_equal('', race.results[2].members_only_place, 'Result 2 place')
    assert_equal(non_members[1], race.results[2].person, 'Result 2 person')

    assert_equal('4', race.results[3].place, 'Result 3 place')
    assert_equal('2', race.results[3].members_only_place, 'Result 3 place')
    assert_equal(molly, race.results[3].person, 'Result 3 person')

    assert_equal('5', race.results[4].place, 'Result 4 place')
    assert_equal('', race.results[4].members_only_place, 'Result 4 place')
    assert_equal(non_members[2], race.results[4].person, 'Result 4 person')
  end

  test "calculate members only places should not trigger combined results calculation" do
    FactoryGirl.create(:discipline, name: "Time Trial")
    event = SingleDayEvent.create!(discipline: "Time Trial")
    senior_men = FactoryGirl.create(:category)
    race = event.races.create!(category: senior_men)
    non_member = Person.create!
    assert(!non_member.member?, "Person member?")
    race.results.create!(place: "1", person: non_member, time: 100)

    weaver = FactoryGirl.create(:person)
    assert(weaver.member?, "Person member?")
    race.results.create!(place: "2", person: weaver, time: 102)

    CombinedTimeTrialResults.calculate!

    assert_not_nil(event.combined_results(true), "TT event should have combined results")
    result_id = event.combined_results.races.first.results.first.id

    race.reload
    race.calculate_members_only_places!
    event.reload
    result_id_after_member_place = event.combined_results(true).races.first.results.first.id
    assert_equal(result_id, result_id_after_member_place, "calculate_members_only_places! should not trigger combined results recalc")
  end

  test "dates of birth" do
    event = SingleDayEvent.create!(date: Time.zone.today)
    senior_men = FactoryGirl.create(:category)
    race = event.races.create!(category: senior_men)
    assert_equal_dates(Date.new(Time.zone.today.year - 999, 1, 1), race.dates_of_birth.begin, 'race.dates_of_birth.begin')
    assert_equal_dates(Date.new(Time.zone.today.year, 12, 31), race.dates_of_birth.end, 'race.dates_of_birth.end')

    event = SingleDayEvent.create!(date: Date.new(2000, 9, 8))
    race = event.races.create!(category: Category.new(name:'Espoirs', ages: 18..23))
    assert_equal_dates(Date.new(1977, 1, 1), race.dates_of_birth.begin, 'race.dates_of_birth.begin')
    assert_equal_dates(Date.new(1982, 12, 31), race.dates_of_birth.end, 'race.dates_of_birth.end')
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
    results = race.results(true).to_a.sort
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
    FactoryGirl.create(:number_issuer)
    FactoryGirl.create(:discipline, name: "Road")

    mathew_braun = Person.create!(name: "Mathew Braun", email: "mtb@example.com")
    event = SingleDayEvent.create!
    race = event.races.create!(category: FactoryGirl.create(:category))
    weaver = FactoryGirl.create(:person)
    race.results.create!(place: "1", person: weaver)
    result = race.results.create!(place: "2", person: Person.new(name: "Jonah Braun"))
    race.results.create!(place: "3", person: mathew_braun)
    assert(Person.exists?(first_name: "Jonah", last_name: "Braun"), "New person Jonah Braun should have been created")

    race.reload
    race.destroy
    assert !Result.exists?(result.id), "Should destroy result"
    assert(!Race.exists?(race.id), "Should be destroyed. #{race.errors.full_messages}")
    assert(!Person.exists?(first_name: "Jonah", last_name: "Braun"), "New person Jonah Braun should have been deleted")
    assert(Person.exists?(weaver.id), "Existing person Ryan Weaver should not be deleted")
    assert(Person.exists?(mathew_braun.id), "Existing person with no results Mathew Braun should not be deleted")

    # TODO Manually-created people that only have this result
    # TODO Teams
  end
end
