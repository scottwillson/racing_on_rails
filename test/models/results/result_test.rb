require File.expand_path("../../../test_helper", __FILE__)

# :stopdoc:
class ResultTest < ActiveSupport::TestCase
  setup :number_issuer

  def number_issuer
    FactoryGirl.create(:number_issuer)
    FactoryGirl.create(:discipline)
  end

  test "person first last name" do
    result = Result.new
    assert_equal(nil, result.first_name, "Person first name w/nil person")
    assert_equal(nil, result.last_name, "Person last name w/nil person")
    assert_equal(nil, result.team_name, "Person team name w/nil person")
  end

  test "name" do
    result = Result.new
    assert_equal(nil, result.name, "Person name w/nil person")

    result = FactoryGirl.create(:result, person: FactoryGirl.create(:person, name: "Ryan Weaver"))
    assert_equal("Ryan Weaver", result.name, "Person name")

    person = Person.new(last_name: 'Willson')
    result = FactoryGirl.create(:result, person: person)
    assert_equal("Willson", result.person.name, "Person name")
    assert_equal("Willson", result.name, "Person name")
    result.save!
    assert_equal("Willson", result.reload.name, "Person name")

    person = Person.new(first_name: 'Clara')
    result = Result.new(person: person)
    assert_equal("Clara", result.person.name, "Person name")

    result = Result.new
    assert_equal(nil, result.name, "Person name")
    result.name = 'Clara Hughes'
    assert_equal("Clara Hughes", result.name, "Person name")
    assert_equal("Clara", result.first_name, "Person first_name")
    assert_equal("Hughes", result.last_name, "Person last_name")

    race = FactoryGirl.create(:race)
    result = race.results.build
    result.name = 'Walrod, Marjon'
    assert_equal("Walrod, Marjon", result.name, "Person name")
    assert_equal("Marjon", result.first_name, "Person first_name")
    assert_equal("Walrod", result.last_name, "Person last_name")
    assert_equal "Marjon", result[:first_name], ":first_name"
    assert_equal "Walrod", result[:last_name], ":last_name"
    assert_equal "Walrod, Marjon", result[:name], ":name"

    result.save!
    assert_equal "Marjon", result[:first_name], ":first_name"
    assert_equal "Walrod", result[:last_name], ":last_name"
    assert_equal "Marjon Walrod", result[:name], ":name"
  end

  test "save" do
    event = SingleDayEvent.create!(name: "Tabor CR", discipline: 'Road')
    category = Category.find_or_create_by(name: "Senior Men Pro/1/2")
    race = event.races.create!(category: category)
    race.save!
    assert_equal(0, race.results.size, "Results before save")
    assert_nil(Person.find_by_last_name("Hampsten"), "Hampsten should not be in DB")
    assert_nil(Team.find_by_name("7-11"), "7-11 should not be in DB")

    person = Person.new(last_name: "Hampsten")
    result = race.results.build
    result.person = person
    result.place = "17"
    result.number = "H67"
    team = Team.new(name: "7-11")
    result.team = team

    race.save!

    assert_equal(1, race.results.size, "Results after save")
    result_from_db = race.results.first
    person_from_db = Person.find_by_last_name("Hampsten")
    assert_not_nil(person_from_db, "Hampsten should  be  DB")
    assert_equal(result.person, result_from_db.person, "result.person")
    assert_not_nil(Team.find_by_name("7-11"), "7-11 should be in DB")
    assert_equal(result.team, result_from_db.team, "result.team")
    assert_equal("17", result_from_db.place, "result.place")
    assert_equal("H67", result_from_db.number, "result.number")
    assert(!result_from_db.new_record?, "result_from_db.new_record")
    assert(!result.team.new_record?, "team.new_record")
    assert(!person_from_db.new_record?, "person_from_db.new_record")
    assert_nil person_from_db.road_number, "Should not create racing association number from result"
  end

  test "first name" do
    attributes = {place: "22", first_name: "Jan"}
    result = Result.new(attributes)
    assert_equal("Jan", result.first_name, "person.first_name")
    assert_equal("Jan", result.person.first_name, "person.first_name")

    result.first_name = "Ivan"
    assert_equal("Ivan", result.first_name, "person.first_name")
    assert_equal("Ivan", result.person.first_name, "person.first_name")
  end

  test "last name" do
    result = Result.new(place: "22", last_name: "Ulrich")
    assert_equal("Ulrich", result.last_name, "person.last_name")
    assert_equal("Ulrich", result.person.last_name, "person.last_name")

    result.last_name = "Basso"
    assert_equal("Basso", result.last_name, "person.last_name")
    assert_equal("Basso", result.person.last_name, "person.last_name")
  end

  test "team name" do
    attributes = {place: "22", team_name: "T-Mobile"}
    result = FactoryGirl.create(:race).results.build(attributes)
    assert_equal("T-Mobile", result.team_name, "person.team_name")
    assert_equal("T-Mobile", result.team.name, "person.team")

    result.team_name = "CSC"
    assert_equal("CSC", result.team_name, "person.team_name")
    assert_equal("CSC", result.team.name, "person.team")
    assert_equal("CSC", result[:team_name], "person.team_name")

    result.save!
    assert_equal("CSC", result[:team_name], "person.team_name")
  end

  test "category name" do
    result = Result.new(place: "22", last_name: "Ulrich")
    assert_equal(nil, result.category_name, "category_name")

    result.category = Category.find_or_create_by(name: "Senior Men Pro/1/2")
    assert_equal("Senior Men Pro/1/2", result.category.name, "category_name")
    assert_equal(nil, result.category_name, "category_name")
    result.race = FactoryGirl.create(:race)
    result.save!
    assert_equal("Senior Men Pro/1/2", result.category_name, "category_name")

    result = Result.new
    result.category_name = "Senior Men Pro/1/2"
    assert_equal("Senior Men Pro/1/2", result.category_name, "category_name")

    result.category_name = ""
    assert_equal("", result.category_name, "category_name")

    result.category_name = nil
    assert_equal(nil, result.category_name, "category_name")
  end

  test "person team" do
    event = FactoryGirl.create(:event)
    race = FactoryGirl.create(:race, event: event)
    result = race.results.build(place: '3', number: '932')
    person = Person.new(last_name: 'Kovach', first_name: 'Barry')
    team = Team.new(name: 'Sorella Forte ')
    result.person = person
    result.team = team

    result.save!
    assert(!person.new_record?, 'person new record')
    assert(!team.new_record?, 'team new record')
    assert_equal(team, result.team, 'result team')
    assert_equal(nil, person.team, 'result team')
    sorella_forte = Team.find_by_name('Sorella Forte')
    assert_equal(sorella_forte, result.team, 'result team')
    assert_equal(nil, person.team, 'result team')

    race = FactoryGirl.create(:race)
    result = race.results.build(place: '3', number: '932')
    result.person = person
    new_team = Team.new(name: 'Bike Gallery')
    result.person = person
    result.team = new_team

    result.save!
    bike_gallery_from_db = Team.find_by_name('Bike Gallery')
    assert_equal(bike_gallery_from_db, result.team, 'result team')
    assert_equal(nil, person.team, 'result team')
    assert_not_equal(bike_gallery_from_db, person.team, 'result team')

    person_with_no_team = Person.create!(last_name: 'Ollerenshaw', first_name: 'Doug')
    result = race.results.build(place: '3', number: '932')
    result.person = person_with_no_team
    vanilla = FactoryGirl.create(:team)
    result.team = vanilla

    result.save!
    assert_equal(vanilla, result.team, 'result team')
    assert_equal(nil, person_with_no_team.team, 'result team')
  end

  test "event" do
    event = FactoryGirl.create(:event)
    result = event.races.create!(category: FactoryGirl.create(:category)).results.create!
    result.reload
    assert_equal(event, result.event, 'Result event')
  end

  test "sort" do
    results = [
     Result.new(place: '1'),
     Result.new(place: ''),
     Result.new(place: nil),
     Result.new(place: '11'),
     Result.new(place: 'DNS'),
     Result.new(place: '3'),
     Result.new(place: 'DNF'),
     Result.new(place: '')
    ]

    results = results.sort
    assert_equal('1', results[0].place, 'result 0 place')
    assert_equal('3', results[1].place, 'result 1 place')
    assert_equal('11', results[2].place, 'result 2 place')
    assert(results[3].place.blank?, 'result 3 place blank')
    assert(results[4].place.blank?, 'result 4 place blank')
    assert(results[5].place.blank?, 'result 5 place blank')
    assert_equal('DNF', results[6].place, 'result 6 place')
    assert_equal('DNS', results[7].place, 'result 7 place')

    results = [
     Result.new(place: '1'),
     Result.new(place: '2'),
     Result.new(place: '11'),
     Result.new(place: 'DNF'),
     Result.new(place: ''),
     Result.new(place: nil)
    ]

    results = results.sort
    assert_equal('1', results[0].place, 'result 0 place')
    assert_equal('2', results[1].place, 'result 1 place')
    assert_equal('11', results[2].place, 'result 2 place')
    assert(results[3].place.blank?, 'result 3 place blank')
    assert(results[4].place.blank?, 'result 4 place blank')
    assert_equal('DNF', results[5].place, 'result 5 place')

    results = [
     Result.new(place: '1'),
     Result.new(place: '2'),
     Result.new(place: '11'),
     Result.new(place: 'DQ'),
     Result.new(place: 'DNF'),
     Result.new(place: nil)
    ]

    results = results.sort
    assert_equal('1', results[0].place, 'result 0 place')
    assert_equal('2', results[1].place, 'result 1 place')
    assert_equal('11', results[2].place, 'result 2 place')
    assert(results[3].place.blank?, 'result 3 place blank')
    assert_equal('DNF', results[4].place, 'result 4 place')
    assert_equal('DQ', results[5].place, 'result 5 place')

    result_5 = Result.new(place: '5')
    result_dnf = Result.new(place: 'DNF')
    assert_equal(-1, result_5 <=> result_dnf)
    assert_equal(1, result_dnf <=> result_5)

    result_5 = Result.new(place: 5)
    assert_equal(-1, result_5 <=> result_dnf)
    assert_equal(1, result_dnf <=> result_5)
  end

  test "save number" do
    racing_association = RacingAssociation.current
    racing_association.rental_numbers = 51..99
    racing_association.save!

    kings_valley_pro_1_2_2004 = FactoryGirl.create(:race)
    results = kings_valley_pro_1_2_2004.results
    result = results.create!(place: 1, first_name: 'Clara', last_name: 'Willson', number: '300')
    assert(result.person.errors.empty?, "People should have no errors, but had: #{result.person.errors.full_messages}")
    assert_nil(result.person(true).road_number(true), 'Current road number')
    road_number_2004 = result.person.race_numbers.detect{|number| number.year == 2004}
    assert_nil road_number_2004, "Should not create official race number from result"
    assert(result.person.ccx_number.blank?, 'Cyclocross number')
    assert(result.person.xc_number.blank?, 'MTB number')

    event = SingleDayEvent.create!(discipline: "Road")
    senior_women = FactoryGirl.create(:category)
    race = event.races.create!(category: senior_women)
    result = race.results.create!(place: 2, first_name: 'Eddy', last_name: 'Merckx', number: '200')
    assert(result.person.errors.empty?, "People should have no errors, but had: #{result.person.errors.full_messages}")
    road_number = result.person(true).race_numbers(true).detect{|number| number.year == Time.zone.today.year}
    assert_nil(road_number, 'Current road number should not be set from result')
    assert(result.person.ccx_number.blank?, 'Cyclocross number')
    assert(result.person.xc_number.blank?, 'MTB number')
    assert_equal(RacingAssociation.current.add_members_from_results?, result.person.member?, "Person should be member")

    # Rental
    result = race.results.create!(place: 2, first_name: 'Benji', last_name: 'Whalen', number: '51')
    assert(result.person.errors.empty?, "People should have no errors, but had: #{result.person.errors.full_messages}")
    road_number = result.person(true).race_numbers(true).detect{|number| number.year == Time.zone.today.year}
    assert_nil(road_number, 'Current road number')
    assert(!result.person.member?, "Person with rental number should not be member")
  end

  test "save number alt" do
    kings_valley_pro_1_2_2004 = FactoryGirl.create(:race)
    results = kings_valley_pro_1_2_2004.results
    result = results.create!(place: 1, first_name: 'Clara', last_name: 'Willson', number: '300')
    assert(result.person.errors.empty?, "People should have no errors, but had: #{result.person.errors.full_messages}")
    assert_nil(result.person(true).road_number(true), 'Current road number')
    road_number_2004 = result.person.race_numbers.detect{|number| number.year == 2004}
    assert_nil road_number_2004, "Should not create official race number from result"
    assert(result.person.ccx_number.blank?, 'Cyclocross number')
    assert(result.person.xc_number.blank?, 'MTB number')

    event = SingleDayEvent.create!(discipline: "Road")
    senior_women = FactoryGirl.create(:category)
    race = event.races.create!(category: senior_women)
    result = race.results.create!(place: 2, first_name: 'Eddy', last_name: 'Merckx', number: '200')
    assert(result.person.errors.empty?, "People should have no errors, but had: #{result.person.errors.full_messages}")
    road_number = result.person(true).race_numbers(true).detect{|number| number.year == Time.zone.today.year}
    assert_nil(road_number, 'Current road number should not be set from result')
    assert(result.person.ccx_number.blank?, 'Cyclocross number')
    assert(result.person.xc_number.blank?, 'MTB number')
    assert_equal(RacingAssociation.current.add_members_from_results?, result.person.member?, "Person should be member")

    RacingAssociation.current.rental_numbers = 0..99
    result = race.results.create!(place: 2, first_name: 'Benji', last_name: 'Whalen', number: '51')
    assert(result.person.errors.empty?, "People should have no errors, but had: #{result.person.errors.full_messages}")
    road_number = result.person(true).race_numbers(true).detect{|number| number.year == Time.zone.today.year}
    assert_nil(road_number, 'Current road number')
    assert(!result.person.member?, "Person with rental number should not be member")
  end

  test "find all for person" do
    molly = FactoryGirl.create(:person)
    FactoryGirl.create(:result, person: molly)
    FactoryGirl.create(:result, person: molly)
    FactoryGirl.create(:result, person: molly)

    results = Result.find_all_for(molly)
    assert_not_nil(results)
    assert_equal(3, results.size, 'Results')

    results = Result.find_all_for(molly.id)
    assert_not_nil(results)
    assert_equal(3, results.size, 'Results')
  end

  test "last event?" do
    result = Result.new
    assert(!result.last_event?, "New result should not be last event")

    event = MultiDayEvent.create!.children.create!(name: "Tabor CR")
    category = Category.find_or_create_by(name: "Senior Men Pro/1/2")
    race = event.races.create!(category: category)
    result = race.results.create!
    assert(result.last_event?, "Only event should be last event")

    # Series overall
    banana_belt_series = FactoryGirl.create(:series)
    banana_belt_1 = banana_belt_series.children.create!(date: 1.week.from_now)
    banana_belt_2 = banana_belt_series.children.create!(date: 2.weeks.from_now)
    series_result = banana_belt_series.races.create!(category: category).results.create!
    assert(!series_result.last_event?, "Series result should not be last event")

    # First event
    first_result = banana_belt_1.races.create!(category: category).results.create!
    assert(!first_result.last_event?, "First result should not be last event")

    # Second (and last) event
    banana_belt_2.races.create!(category: category).results.create!
    assert(result.last_event?, "Last event should be last event")
  end

  test "finished?" do
    category = Category.find_or_create_by(name: "Senior Men Pro/1/2")
    race = SingleDayEvent.create!.races.create!(category: category)

    result = race.results.create!(place: "1")
    assert(result.finished?, "'1' should be a finisher")

    result = race.results.create!(place: nil)
    assert(!result.finished?, "nil should not be a finisher")

    result = race.results.create!(place: "")
    assert(!result.finished?, "'' should not be a finisher")

    result = race.results.create!(place: "1000")
    assert(result.finished?, "'1000' should be a finisher")

    result = race.results.create!(place: "DNF")
    assert(!result.finished?, "'DNF' should not be a finisher")

    result = race.results.create!(place: "dnf")
    assert(!result.finished?, "'dnf' should not be a finisher")

    result = race.results.create!(place: "DQ")
    assert(!result.finished?, "'DNF' should not be a finisher")

    result = race.results.create!(place: "nanplace")
    assert(!result.finished?, "'nanplace' should not be a finisher")

    result = race.results.create!(place: "noplace9")
    assert(!result.finished?, "'noplace9' should not be a finisher")

    result = race.results.create!(place: "1st")
    assert(result.finished?, "'1st' should be a finisher")

    result = race.results.create!(place: "4th")
    assert(result.finished?, "'4th' should be a finisher")
  end

  test "make member if association number" do
    event = SingleDayEvent.create!(name: "Tabor CR")
    race = event.races.create!(category: Category.find_or_create_by(name: "Senior Men Pro/1/2"))
    result = race.results.create!(
      first_name: "Tom", last_name: "Boonen", team_name: "Davitamon", number: "702"
    )

    person = result.person
    person.reload

    if RacingAssociation.current.add_members_from_results?
      assert(person.member?, "Finisher with racing association number should be member")
    else
      assert(!person.member?, "Finisher with racing association number should be member if RacingAssociation doesn't allow this")
    end
  end

  test "do not make member if not association number" do
    number_issuer = NumberIssuer.create!(name: "Tabor")
    event = SingleDayEvent.create!(name: "Tabor CR", number_issuer: number_issuer)
    race = event.races.create!(category: Category.find_or_create_by(name: "Senior Men Pro/1/2"))
    result = race.results.create!(
      first_name: "Tom", last_name: "Boonen", team_name: "Davitamon", number: "702"
    )

    event.reload
    assert_equal number_issuer, event.number_issuer, "Event number_issuer"

    person = result.person
    person.reload
    assert(!person.member?, "Finisher with event (not racing association) number should not be a member")
  end

  test "only make member if full name" do
    event = SingleDayEvent.create!(name: "Tabor CR")
    race = event.races.create!(category: Category.find_or_create_by(name: "Senior Men Pro/1/2"))
    result = race.results.create!(
      first_name: "Tom", team_name: "Davitamon", number: "702"
    )
    result_2 = race.results.create!(
      last_name: "Boonen", team_name: "Davitamon", number: "702"
    )

    result.person.reload
    assert(!result.person.member?, "Finisher with only first_name should be not member")

    result_2.person.reload
    assert(!result_2.person.member?, "Finisher with only last_name should be not member")
  end

  test "stable name on old results" do
    team = Team.create!(name: "Tecate-Una Mas")

    event = SingleDayEvent.create!(date: 1.years.ago)
    senior_men = FactoryGirl.create(:category)
    old_result = event.races.create!(category: senior_men).results.create!(team: team)
    team.names.create!(name: "Twin Peaks", year: 1.years.ago.year)

    event = SingleDayEvent.create!(date: Time.zone.today)
    result = event.races.create!(category: senior_men).results.create!(team: team)

    assert_equal("Tecate-Una Mas", result.reload.team_name, "Team name on this year's result")
    assert_equal("Twin Peaks", old_result.reload.team_name, "Team name on old result")
  end

  test "bar" do
    event = SingleDayEvent.create!(name: "Tabor CR")
    race = event.races.create!(category: Category.find_or_create_by(name: "Senior Men Pro/1/2"))
    result = race.results.create!(
      first_name: "Tom", team_name: "Davitamon", number: "702"
    )
    assert(result.bar?, "By default, results should count toward BAR")
    result.bar = false
    assert(!result.bar?, "Result bar?")
  end

  test "dont delete team names if used by person" do
    event = SingleDayEvent.create!
    race = event.races.create!(category: Category.find_or_create_by(name: "Senior Men Pro/1/2"))
    race.results.create!(
      first_name: "Tom", team_name: "Blow", team_name: "QuickStep"
    )

    Person.create!(name: "Phil Anderson", team: Team.find_by_name("QuickStep"))
    assert(race.destroy, "Should destroy race")

    assert_nil(Person.find_by_name("Tom Blow"), "Should delete person that just came from results")
    assert_not_nil(Person.find_by_name("Phil Anderson"), "Should keep person that was manually entered")
    assert_not_nil(Team.find_by_name("QuickStep"), "Should keep team that is used by person, even though it was created by a result")
  end

  test "competition result" do
    FactoryGirl.create(:discipline, name: "Team")
    senior_men = FactoryGirl.create(:category, name: "Senior Men")
    result = FactoryGirl.create(:result)
    assert !result.competition_result?, "SingleDayEvent competition_result?"

    result = Competitions::Ironman.create!.races.create!(category: Category.new(name: "Team")).results.create!(category: senior_men)
    assert result.competition_result?, "Ironman competition_result?"

    result = Competitions::TeamBar.create!.races.create!(category: Category.new(name: "Team")).results.create!(category: senior_men)
    assert result.competition_result?, "TeamBar competition_result?"
  end

  test "team competition result" do
    FactoryGirl.create(:discipline, name: "Team")
    senior_men = FactoryGirl.create(:category, name: "Senior Men")
    result = FactoryGirl.create(:result)
    assert !result.team_competition_result?, "SingleDayEvent team_competition_result?"

    result = Competitions::Ironman.create!.races.create!(category: Category.new(name: "Team")).results.create!(category: senior_men)
    assert !result.team_competition_result?, "Ironman team_competition_result?"

    result = Competitions::TeamBar.create!.races.create!(category: Category.new(name: "Team")).results.create!(category: senior_men)
    assert result.team_competition_result?, "TeamBar competition_result?"
  end

  test "custom attributes" do
    banana_belt_1 = FactoryGirl.create(:event)
    senior_men = FactoryGirl.create(:category)
    race = banana_belt_1.races.create!(category: senior_men, result_columns: [ "place" ], custom_columns: [ "run", 20100929 ])

    result = race.reload.results.create!(place: "1", custom_attributes: { run: "9:00" })
    assert_equal "9:00", result.custom_attribute(:run), "run custom_attribute"
    assert_equal "9:00", result.custom_attribute("run"), "run custom_attribute"
    assert_equal nil, result.custom_attribute(:"20100929"), "numerical column"
    assert_raise(NoMethodError) { result.foo_bar }
    assert_raise(NoMethodError) { result.custom_attribute(:foo_bar) }

    result = race.results.create!(place: "1", custom_attributes: { "20100929" => "A" })
    assert_equal "A", result.custom_attribute(:"20100929"), "numerical column"
  end

  test "touch" do
    result = nil
    Timecop.freeze(1.day.ago) do
      result = FactoryGirl.create(:weekly_series_event_result)
    end

    person = Person.find(result.person)
    person.name = "Ryan Hieb"
    person.save!

    result = Result.find(result)
    assert result.updated_at > 1.day.ago, "result updated_at should be updated when result person changes"

    race = Race.find(result.race)
    assert race.updated_at > 1.day.ago, "race updated_at should be updated when result person changes"

    event = Event.find(result.event)
    assert event.updated_at > 1.day.ago, "event updated_at should be updated when result person changes"

    parent = Event.find(result.event.parent)
    assert parent.updated_at > 1.day.ago, "parent event updated_at should be updated when result person changes"
  end
end
