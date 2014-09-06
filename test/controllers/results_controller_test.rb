require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class ResultsControllerTest < ActionController::TestCase
  def setup
    super

    association_category = FactoryGirl.create(:category, name: "CBRA")
    @senior_men          = FactoryGirl.create(:category, name: "Senior Men", parent: association_category)
    @senior_women        = FactoryGirl.create(:category, name: "Senior Women", parent: association_category)

    discipline = FactoryGirl.create(:discipline, name: "Road")
    discipline.bar_categories << @senior_men
    discipline.bar_categories << @senior_women

    discipline = FactoryGirl.create(:discipline, name: "Time Trial")
    discipline.bar_categories << @senior_men
    discipline.bar_categories << @senior_women

    discipline = FactoryGirl.create(:discipline, name: "Overall")
    discipline.bar_categories << @senior_men
    discipline.bar_categories << @senior_women
  end

  test "event" do
    banana_belt_1 = FactoryGirl.create(:event)
    get(:event, event_id: banana_belt_1.to_param)
    assert_response(:success)
    assert_template("results/event")
    assert_not_nil(assigns["event"], "Should assign event")
    assert_equal(assigns["event"], banana_belt_1, "Banana Belt 1")
  end

  test "big names" do
    banana_belt_1 = FactoryGirl.create(:result).event
    big_team = Team.create!(name: "T" * 60)
    big_person = Person.create!(first_name: "f" * 60, last_name: "L" * 60, team: big_team)
    banana_belt_1.races.first.results.create!(place: 20, person: big_person, team: big_team, number: '')

    get :event, event_id: banana_belt_1.to_param
    assert_response(:success)
    assert_template("results/event")
    assert_not_nil(assigns["event"], "Should assign event")
    assert_equal(assigns["event"], banana_belt_1, "Banana Belt 1")
  end

  test "event tt" do
    jack_frost = FactoryGirl.create(:time_trial_event)
    get :event, event_id: jack_frost.to_param
    assert_response(:success)
    assert_template("results/event")
    assert_not_nil(assigns["event"], "Should assign event")
  end

  test "index" do
    future_national_federation_event = FactoryGirl.create(:event, date: Date.new(2004, 3), sanctioned_by: "USA Cycling")
    get(:index, year: "2004")
    assert_response(:success)
    assert_template("results/index")
    assert_not_nil(assigns["events"], "Should assign events")
    assert_not_nil(assigns["year"], "Should assign year")

    assert(!assigns["events"].include?(future_national_federation_event), "Should only include association-sanctioned events")
  end

  test "index only shows sanctioned events" do
    future_national_federation_event = FactoryGirl.create(:event, date: 1.day.from_now, sanctioned_by: "USA Cycling")
    get(:index)
    assert_response(:success)
    assert_template("results/index")
    assert_not_nil(assigns["events"], "Should assign events")
    assert_not_nil(assigns["year"], "Should assign year")

    assert(!assigns["events"].include?(future_national_federation_event), "Should only include association-sanctioned events")
  end

  test "index road" do
    FactoryGirl.create(:event, date: Date.new(2004)).races.create!(category: @senior_women).results.create!(place: "1", person: Person.create!, team: Team.create!(name: "dfl"))
    get(:index, year: "2004", discipline: 'road')
    assert_response(:success)
    assert_template("results/index")
    assert_not_nil(assigns["events"], "Should assign events")
    assert_not_nil(assigns["year"], "Should assign year")
    assert_equal(assigns["discipline"], Discipline[:road], "discipline")
  end

  test "index road with discipline" do
    get(:index, year: "2004", discipline: 'time_trial')
    assert_response(:success)
    assert_template("results/index")
    assert_not_nil(assigns["events"], "Should assign events")
    assert_not_nil(assigns["year"], "Should assign year")
    assert_equal(Discipline[:time_trial], assigns["discipline"], "discipline")
  end

  test "index all subclasses" do
    Timecop.freeze(Time.zone.local(2007, 5)) do
      SingleDayEvent.create!(name: 'In past', date: Date.new(2006, 12, 31)).races.create!(category: @senior_men).results.create!
      SingleDayEvent.create!(name: 'In future', date: Date.new(2008, 1, 1)).races.create!(category: @senior_men).results.create!
      SingleDayEvent.create!(name: 'SingleDayEvent no races', date: Date.new(2007, 4, 12))
      single_day_event = SingleDayEvent.create!(name: 'SingleDayEvent', date: Date.new(2007, 4, 15))
      single_day_event.races.create!(category: @senior_men).results.create!

      MultiDayEvent.create!(name: 'In past', date: Date.new(2006, 12, 31)).races.create!(category: @senior_men).results.create!
      MultiDayEvent.create!(name: 'In future', date: Date.new(2008, 1, 1)).races.create!(category: @senior_men).results.create!
      MultiDayEvent.create!(name: 'MultiDayEvent no races', date: Date.new(2007, 1, 12))

      multi_day_event_with_children = MultiDayEvent.create!(name: 'MultiDayEvent with children, no races', date: Date.new(2007, 5, 15))
      multi_day_event_with_children.children.create!(date: Date.new(2007, 5, 15))

      multi_day_event_with_races = MultiDayEvent.create!(name: 'MultiDayEvent with races, no children', date: Date.new(2007, 6, 12))
      multi_day_event_with_races.races.create!(category: @senior_men).results.create!

      multi_day_event_with_child_races = MultiDayEvent.create!(name: 'MultiDayEvent with children races', date: Date.new(2007, 6, 17))
      multi_day_event_with_child_races_child = multi_day_event_with_child_races.children.create!(date: Date.new(2007, 6, 17))
      multi_day_event_with_child_races_child.races.create!(category: @senior_men).results.create!

      Series.create!(name: 'In past', date: Date.new(2006, 12, 31)).races.create!(category: @senior_men).results.create!
      Series.create!(name: 'In future', date: Date.new(2008, 1, 1)).races.create!(category: @senior_men).results.create!
      Series.create!(name: 'Series no races', date: Date.new(2007, 1, 12))

      series_with_children = Series.create!(name: 'Series with children, no races', date: Date.new(2007, 2, 15))
      series_with_children.children.create!(date: Date.new(2007, 2, 15))

      series_with_races = Series.create!(name: 'Series with races, no children', date: Date.new(2007, 3, 12))
      series_with_races.races.create!(category: @senior_men).results.create!

      series_with_child_races = Series.create!(name: 'Series with children races', date: Date.new(2007, 4, 17))
      series_with_child_races_child = series_with_child_races.children.create!(date: Date.new(2007, 4, 17))
      series_with_child_races_child.races.create!(category: @senior_men).results.create!
      series_with_child_races_child.races.create!(category: @senior_men).results.create!

      series_with_races_and_child_races = Series.create!(name: 'Series with races and  with children races', date: Date.new(2007, 11, 1))
      series_with_races_and_child_races.races.create!(category: @senior_men).results.create!
      series_with_races_and_child_races_child = series_with_child_races.children.create!(date: Date.new(2007, 11, 11))
      series_with_races_and_child_races_child.races.create!(category: @senior_men).results.create!
      series_with_races_and_child_races_child.races.create!(category: @senior_men).results.create!

      WeeklySeries.create!(name: 'In past', date: Date.new(2006, 12, 31)).races.create!(category: @senior_men).results.create!
      WeeklySeries.create!(name: 'In future', date: Date.new(2008, 1, 1)).races.create!(category: @senior_men).results.create!
      WeeklySeries.create!(name: 'WeeklySeries no races', date: Date.new(2007, 1, 12))

      weekly_series_with_children = WeeklySeries.create!(name: 'WeeklySeries with children, no races', date: Date.new(2007, 8, 2))
      weekly_series_with_children.children.create!(date: Date.new(2007, 8, 2))

      weekly_series_with_races = WeeklySeries.create!(name: 'WeeklySeries with races, no children', date: Date.new(2007, 9, 22))
      weekly_series_with_races.races.create!(category: @senior_men).results.create!

      weekly_series_with_child_races = WeeklySeries.create!(name: 'WeeklySeries with children races', date: Date.new(2007, 3, 5))
      weekly_series_with_child_races_child = weekly_series_with_child_races.children.create!(date: Date.new(2007, 3, 5))
      weekly_series_with_child_races_child.races.create!(category: @senior_men).results.create!

      weekly_series_with_races_and_child_races = WeeklySeries.create!(name: 'WeeklySeries with races and children races', date: Date.new(2007, 12, 2))
      weekly_series_with_races_and_child_races.races.create!(category: @senior_men).results.create!
      weekly_series_with_races_and_child_races_child = weekly_series_with_child_races.children.create!(date: Date.new(2007, 12, 2))
      weekly_series_with_races_and_child_races_child.races.create!(category: @senior_men).results.create!

      usa_cycling_event_with_results = SingleDayEvent.create!(date: Date.new(2007, 5), sanctioned_by: "CBRA")
      usa_cycling_event_with_results.races.create!(category: @senior_men).results.create!

      get(:index, year: "2007")
      assert_response(:success)

      assert_not_nil(assigns['events'], "Should assign 'events'")

      if RacingAssociation.current.show_only_association_sanctioned_races_on_calendar?
        [series_with_races, single_day_event, series_with_child_races, multi_day_event_with_races,
                  multi_day_event_with_child_races, series_with_races_and_child_races]
      else
        [series_with_races, single_day_event, series_with_child_races, usa_cycling_event_with_results, multi_day_event_with_races,
                  multi_day_event_with_child_races, series_with_races_and_child_races]
      end
    end
  end

  test "person with year" do
    weaver = FactoryGirl.create(:person)
    result = SingleDayEvent.create!(date: Date.new(2008)).races.create!(category: @senior_men).results.create!(person: weaver, place: "1")

    get :person, person_id: weaver.to_param, year: "2008"
    assert_response(:success)
    assert_template("results/person")
    assert_not_nil(assigns["person"], "Should assign person")
    assert_equal(assigns["person"], weaver, "Weaver!")
    assert_equal [ result ], assigns(:event_results), "@event_results for 2008"
  end

  test "person long name" do
    big_team = Team.create!(name: "T" * 60)
    big_person = Person.create!(first_name: "f" * 60, last_name: "L" * 60, team: big_team)
    FactoryGirl.create(:result, person: big_person, team: big_team, place: 2, number: '99')

    get :person, person_id: big_person.to_param
    assert_response(:success)
    assert_template("results/person")
    assert_not_nil(assigns["person"], "Should assign person")
    assert_equal(assigns["person"], big_person, "person")
    assert_not_nil(assigns["event_results"], "Should assign event_results")
    assert_not_nil(assigns["competition_results"], "Should assign competition_results")
  end

  test "column headers display correctly" do
    result = FactoryGirl.create(:result, points_bonus: 8, points_penalty: -2, laps: 9)

    get :event, event_id: result.event_id
    assert_response :success

    assert(@response.body["Bonus"], "Should format points_bonus correctly")
    assert(@response.body["Penalty"], "Should format points_penalty correctly")
    assert(@response.body["Laps"], "Should format laps correctly")
  end

  test "index ssl" do
    use_ssl
    get :index
    assert_response :success
  end

  test "missing person event bad person" do
    banana_belt_1 = FactoryGirl.create(:event)
    assert_raise(ActiveRecord::RecordNotFound) {
      get(:person_event, event_id: banana_belt_1.to_param, person_id: 236127361273)
    }
  end

  test "return 404 for missing person event bad event" do
    weaver = FactoryGirl.create(:person)
    assert_raise(ActiveRecord::RecordNotFound) {
      get(:person_event, event_id: 236127361273, person_id: weaver.to_param)
    }
  end

  test "person json" do
    person = FactoryGirl.create(:result).person
    get :person, person_id: person.id, format: :json
  end

  test "person json with year" do
    result = FactoryGirl.create(:result)
    get :person, person_id: result.person_id, format: :json, year: result.year
  end

  test "person xml" do
    Timecop.freeze(Time.zone.local(2015, 11)) do
      person = FactoryGirl.create(:result).person
      get :person, person_id: person.id, format: :xml
      assert_equal "application/xml", @response.content_type
      [
        "results > result",
        "result > age",
        "result > age-group",
        "result > category-class",
        "result > city",
        "result > custom-attributes",
        "result > date-of-birth",
        "result > gender",
        "result > id",
        "result > laps",
        "result > license",
        "result > number",
        "result > place",
        "result > place-in-category",
        "result > points",
        "result > points-bonus",
        "result > points-bonus-penalty",
        "result > points-from-place",
        "result > points-penalty",
        "result > points-total",
        "result > preliminary",
        "result > state",
        "result > time",
        "result > time-gap-to-leader",
        "result > time-gap-to-previous",
        "result > time-gap-to-winner",
        "result > first-name",
        "result > last-name",
        "result > license",
        "result > id"
      ].each { |key| assert_select key }
    end
  end

  test "team" do
    team = FactoryGirl.create(:result).team
    get :team, team_id: team.id
  end

  test "team json" do
    team = FactoryGirl.create(:result).team
    get :team, team_id: team.id, format: :json
  end

  test "team xml" do
    team = FactoryGirl.create(:result).team
    get :team, team_id: team.id, format: :xml
  end

  test "index xml" do
    FactoryGirl.create(:result)
    get :index, format: :xml
    assert_response :success
  end

  test "show unregistered teams in results" do
    kona = FactoryGirl.create(:team, member: false, name: "Kona")
    gentle_lovers = FactoryGirl.create(:team, name: "Gentle Lovers")
    result = FactoryGirl.create(:result, team: kona)
    FactoryGirl.create(:result, team: gentle_lovers, race: result.race)

    get :event, event_id: result.event.to_param
    assert_response :success
    assert @response.body["Kona"]
    assert @response.body["Gentle Lovers"]
  end

  test "do not show unregistered teams in results" do
    RacingAssociation.current.unregistered_teams_in_results = true
    RacingAssociation.current.save!

    kona = FactoryGirl.create(:team, member: false, name: "Kona")
    FactoryGirl.create(:team, name: "Gentle Lovers")
    @senior_men = FactoryGirl.create(:category)
    tonkin = FactoryGirl.create(:person)

    event = SingleDayEvent.create!
    race = event.races.create!(category: @senior_men)
    race.results.create! person: tonkin, team: kona
    race.results.create! person: Person.create!, team: Team.create!(name: "DFL")

    get :event, event_id: event.to_param
    assert_response :success
    assert @response.body["Kona"], "Expected 'Kona' in #{@response.body}"
    assert @response.body["DFL"], "Expected 'DFL' in #{@response.body}"
  end

  test "do not show unregistered teams in results should show previous years" do
    RacingAssociation.current.unregistered_teams_in_results = false
    RacingAssociation.current.save!

    kona = FactoryGirl.create(:team, member: false, name: "Kona")
    gentle_lovers = FactoryGirl.create(:team, name: "Gentle Lovers", member: true)
    result = FactoryGirl.create(:result, team: kona)
    FactoryGirl.create(:result, team: gentle_lovers, race: result.race)

    get :event, event_id: result.event.to_param
    assert_response :success
    assert !@response.body["Kona"], "Expected no 'Kona' in #{@response.body}"
    assert @response.body["Gentle Lovers"], "Expected 'Gentle Lovers' in #{@response.body}"
  end
end
