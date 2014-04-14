require File.expand_path("../../../../test_helper", __FILE__)

# :stopdoc:
class Cat4WomensRaceSeriesTest < ActiveSupport::TestCase
  def test_calculate_omnium
    series = Cat4WomensRaceSeries.create!(date: Time.zone.local(2005), name: "Series")
    omnium = MultiDayEvent.create!(date: Time.zone.local(2005), bar_points: 1, name: "Omnium")
    series.source_events << omnium

    road_race = omnium.children.create!(date: Time.zone.local(2005), name: "Omnium road race")
    women_cat_4 = Category.find_or_create_by(name: "Category 4 Women")
    person = FactoryGirl.create(:person)
    omnium.races.create!(category: women_cat_4).results.create!(place: 1, person: person)
    road_race.races.create!(category: women_cat_4).results.create!(place: 1, person: person)

    Cat4WomensRaceSeries.calculate!(2005)
    result = series.races.first.results.first
    assert_equal 2, result.scores.size, "Should have one score"
    assert_equal 115, result.points, "Should have points for omnium only"
  end

  def test_calculate_omnium_no_participation_points
    RacingAssociation.current.award_cat4_participation_points = false
    series = Cat4WomensRaceSeries.create!(date: Time.zone.local(2005))
    omnium = MultiDayEvent.create!(date: Time.zone.local(2005))
    series.source_events << omnium

    road_race = omnium.children.create!(date: Time.zone.local(2005))
    women_cat_4 = Category.find_or_create_by(name: "Category 4 Women")
    person = FactoryGirl.create(:person)
    omnium.races.create!(category: women_cat_4).results.create!(place: 1, person: person)
    road_race.races.create!(category: women_cat_4).results.create!(place: 1, person: person)

    Cat4WomensRaceSeries.calculate!(2005)
    result = series.races.first.results.first
    assert_equal 100, result.points, "Should have points for omnium only"
    assert_equal 1, result.scores.size, "Should have one score"
  end

  def test_calculate
    setup_scenario

    assert_difference "Result.count", 2 do
      Cat4WomensRaceSeries.calculate!(2004)
    end
    assert_equal(1, Cat4WomensRaceSeries.count, "Cat4WomensRaceSeries events after calculate!")
    bar = Cat4WomensRaceSeries.find_for_year(2004)
    assert_not_nil(bar, "2004 Cat4WomensRaceSeries after calculate!")
    assert_equal_dates(Time.zone.local(2004, 1, 1), bar.date, "2004 Cat4WomensRaceSeries date")
    assert_equal_dates(Time.zone.local(2004, 12, 31), bar.end_date, "2004 Cat4WomensRaceSeries date")
    assert_equal("2004 Cat 4 Women's Race Series", bar.name, "2004 Bar name")
    assert_equal_dates(Time.zone.now, bar.updated_at, "Cat4WomensRaceSeries last updated")

    assert_equal(1, bar.races.size, 'Races')
    race = bar.races.first
    assert_equal(@category_4_women, race.category, 'Category')
    assert_equal(2, race.results.size, 'Category 4 Women race results')

    results = race.results.sort
    assert_equal('1', results[0].place, 'Place')
    assert_equal(@alice, results[0].person, 'Person')
    # FIXME Should be 102 points and exclude Boat Street from Jan 1, 2005. In practice, this isn't a problem.
    assert_equal(117, results[0].points, 'Points')

    assert_equal('2', results[1].place, 'Place')
    assert_equal(@molly, results[1].person, 'Person')

    assert_equal(65, results[1].points, 'Points')
  end

  def test_do_not_award_cat4_participation_points
    RacingAssociation.current.award_cat4_participation_points = false
    setup_scenario

    assert_difference "Result.count", 1 do
      Cat4WomensRaceSeries.calculate!(2004)
    end
    assert_equal(1, Cat4WomensRaceSeries.count, "Cat4WomensRaceSeries events after calculate!")
    bar = Cat4WomensRaceSeries.find_for_year(2004)
    assert_not_nil(bar, "2004 Cat4WomensRaceSeries after calculate!")
    assert_equal_dates(Time.zone.local(2004, 1, 1), bar.date, "2004 Cat4WomensRaceSeries date")
    assert_equal("2004 Cat 4 Women's Race Series", bar.name, "2004 Bar name")
    assert_equal_dates(Time.zone.today, bar.updated_at, "Cat4WomensRaceSeries last updated")

    assert_equal(1, bar.races.size, 'Races')

    race = bar.races.first
    assert_equal(@category_4_women, race.category, 'Category')
    assert_equal(1, race.results.size, 'Category 4 Women race results')

    results = race.results.sort
    assert_equal('1', results[0].place, 'Place')
    assert_equal(@alice, results[0].person, 'Person')
    assert_equal(72, results[0].points, 'Points')
  end

  def test_more_than_one_cat_4_race
    series = Cat4WomensRaceSeries.create(date: Time.zone.local(2004))
    event = SingleDayEvent.create(date: Time.zone.local(2004))
    women_cat_4 = Category.find_or_create_by(name: "Category 4 Women")
    race_1 = event.races.create!(category: women_cat_4)
    molly = FactoryGirl.create(:person)
    race_1.results.create!(place: "2", person: molly)
    race_2 = event.races.create!(category: women_cat_4)
    alice = FactoryGirl.create(:person)
    race_2.results.create!(place: "5", person: alice)
    series.source_events << event

    Cat4WomensRaceSeries.calculate!(2004)
    series.reload
    assert_equal(1, series.races.size, 'Races')

    race = series.races.first
    assert_equal(2, race.results.size, 'Category 4 Women race results')
    results = race.results.sort
    assert_equal('1', results[0].place, 'Place')
    assert_equal(molly, results[0].person, 'Person')
    assert_equal(95, results[0].points, 'Points')
    assert_equal('2', results[1].place, 'Place')
    assert_equal(alice, results[1].person, 'Person')
    assert_equal(80, results[1].points, 'Points')
  end

  def test_custom_category_name
    racing_association = RacingAssociation.current
    category_4_women = Category.find_or_create_by(name: "Women Cat 4")
    racing_association.cat4_womens_race_series_category = category_4_women
    racing_association.save!

    series = Cat4WomensRaceSeries.create(date: Time.zone.local(2004))
    event = SingleDayEvent.create(date: Time.zone.local(2004))
    race_1 = event.races.create!(category: category_4_women)
    molly = FactoryGirl.create(:person)
    race_1.results.create!(place: "2", person: molly)
    race_2 = event.races.create!(category: category_4_women)
    alice = FactoryGirl.create(:person)
    race_2.results.create!(place: "5", person: alice)
    series.source_events << event

    Cat4WomensRaceSeries.calculate!(2004)
    series.reload
    assert_equal(1, series.races.size, 'Races')

    race = series.races.first
    assert_equal(2, race.results.size, 'Category 4 Women race results')
    results = race.results.sort
    assert_equal('1', results[0].place, 'Place')
    assert_equal(molly, results[0].person, 'Person')
    assert_equal(95, results[0].points, 'Points')
    assert_equal('2', results[1].place, 'Place')
    assert_equal(alice, results[1].person, 'Person')
    assert_equal(80, results[1].points, 'Points')
  end

  def test_child_events
    series = Cat4WomensRaceSeries.create!(date: Time.zone.local(2004))
    event = SingleDayEvent.create!(discipline: "Time Trial", date: Time.zone.local(2004))
    series.source_events << event

    # Non Cat 4 Women race in other event
    FactoryGirl.create(:result, place: "1")

    fourteen_mile = event.children.create!
    assert_equal 1, fourteen_mile.bar_points, "Children should receive BAR points"
    assert_equal_dates Time.zone.local(2004), fourteen_mile.date, "Children should share parent date"
    women_cat_4 = Category.find_by_name("Category 4 Women")
    race = fourteen_mile.races.create!(category: women_cat_4)
    alice = FactoryGirl.create(:person, name: "Alice")
    race.results.create!(place: 3, time: 3000, person: alice)
    seven_mile = event.children.create!
    race = seven_mile.races.create!(category: women_cat_4)
    molly = FactoryGirl.create(:person, name: "Molly")
    race.results.create!(place: 1, time: 1500, person: molly)

    Cat4WomensRaceSeries.calculate!(2004)

    race = series.races.first
    assert_equal(2, race.results.size, 'Category 4 Women race results')
    results = race.results.sort
    assert_equal('1', results[0].place, 'Place')
    assert_equal(molly, results[0].person, 'Person')
    assert_equal(100, results[0].points, 'Points')
    assert_equal('2', results[1].place, 'Place')
    assert_equal(alice, results[1].person, 'Person')
    assert_equal(90, results[1].points, 'Points')
  end

  def test_honor_start_date
    event = FactoryGirl.create(:event, date: Time.zone.local(2012, 2, 15))
    category_4_women = Category.find_or_create_by(name: "Category 4 Women")
    race = FactoryGirl.create(:race, category: category_4_women, event: event)
    FactoryGirl.create(:result, race: race)

    event = FactoryGirl.create(:event, date: Time.zone.local(2012, 2, 16))
    race = FactoryGirl.create(:race, category: category_4_women, event: event)
    result = FactoryGirl.create(:result, race: race)

    racing_association = RacingAssociation.current
    racing_association.cat4_womens_race_series_start_date = Time.zone.local(2012, 2, 16).to_date
    racing_association.save!
    series = Cat4WomensRaceSeries.create(date: Time.zone.local(2012))
    results = series.source_results(series.races.first)
    assert_equal [ result ], results, "results"
  end

  def setup_scenario
    @category_4_women = Category.find_or_create_by(name: "Category 4 Women")
    series = Cat4WomensRaceSeries.create(date: Time.zone.local(2004))
    banana_belt = FactoryGirl.create(:series_event, date: Time.zone.local(2004), name: "Banana Belt Series")
    series.source_events << banana_belt
    kings_valley_2004 = FactoryGirl.create(:event, date: Time.zone.local(2004), name: "Kings Valley")
    series.source_events << kings_valley_2004

    banana_belt_women_cat_4 = banana_belt.races.create!(category: @category_4_women)
    @alice = FactoryGirl.create(:person)
    banana_belt_women_cat_4.results.create!(person: @alice, place: '7')

    # All finishes count
    @molly = FactoryGirl.create(:person)
    banana_belt_women_cat_4.results.create!(person: @molly, place: '17')

    kv_women_cat_4 = kings_valley_2004.races.create!(category: @category_4_women)
    kv_women_cat_4.results.create!(person: @molly, place: '205')

    # ... but not DNFs, DQs, etc...
    matson = FactoryGirl.create(:person)
    kv_women_cat_4.results.create!(person: matson, place: 'DQ')

    # ... and not results in different years
    wrong_year_event = SingleDayEvent.create!(name: "Boat Street CT 2003", date: Time.zone.local(2003).end_of_year)
    race = wrong_year_event.races.create!(category: @category_4_women)
    race.results.create!(person: @molly, place: "1")

    wrong_year_event = SingleDayEvent.create!(name: "Boat Street CT 2005", date: Time.zone.local(2005).beginning_of_year)
    race = wrong_year_event.races.create!(category: @category_4_women)
    race.results.create!(person: @alice, place: "2")

    # WSBA results count for participation points
    other_wsba_event = SingleDayEvent.create!(name: "Boat Street CT 2004", date: "2004-06-26")
    race = other_wsba_event.races.create!(category: @category_4_women)
    race.results.create!(person: @molly, place: "18")

    # Blank results count -- finished, but don't know where
    race.results.create!(person: @alice, place: "")

    # Non-WSBA results count for participation points
    non_wsba_event = SingleDayEvent.create!(name: "Classique des Alpes", date: Time.zone.local(2004, 9, 16), sanctioned_by: "UCI")
    race = non_wsba_event.races.create!(category: @category_4_women)
    race.results.create!(person: @alice, place: "56")

    # Other categories don't count
    category_3_women = FactoryGirl.create(:category, name: "Women Cat 3")
    banana_belt_category_3_women = banana_belt.races.create!(category: category_3_women)
    banana_belt_category_3_women.results.create!(person: @alice, place: '1')

    # Other competitions don't count!
    RiderRankings.calculate!(2004)
  end
end
