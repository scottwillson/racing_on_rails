require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class ResultsControllerTest < ActionController::TestCase
  def test_event
    banana_belt_1 = events(:banana_belt_1)
    get(:event, :event_id => banana_belt_1.to_param)
    assert_response(:success)
    assert_template("results/event")
    assert_not_nil(assigns["event"], "Should assign event")
    assert_equal(assigns["event"], banana_belt_1, "Banana Belt 1")
  end
  
  def test_event_rider_rankings
    rider_rankings = RiderRankings.create!
    get(:event, :event_id => rider_rankings.to_param)
    assert_redirected_to(rider_rankings_path(rider_rankings.date.year))
  end
  
  def test_event_bar
    bar = Bar.create!
    get(:event, :event_id => bar.to_param)
    assert_redirected_to(:controller => 'bar', :action => "show", :year => bar.date.year, :discipline => bar.discipline)
  end
  
  def test_event_overall_bar
    bar = OverallBar.create!
    get(:event, :event_id => bar.to_param)
    assert_redirected_to(:controller => 'bar', :action => "show", :year => bar.date.year)
  end
  
  def test_redirect_to_ironman
    event = Ironman.create!
    get :event, :event_id => event.to_param
    assert_redirected_to ironman_path(:year => event.year)
  end
  
  def test_cross_crusade_team_competition
    event = CrossCrusadeTeamCompetition.create!(:parent => Series.create!)
    get :event, :event_id => event.to_param
    assert_template "results/event"
  end
  
  def test_big_names
    banana_belt_1 = events(:banana_belt_1)
    big_team = Team.create!(:name => "T" * 60)
    big_person = Person.create!(:first_name => "f" * 60, :last_name => "L" * 60, :team => big_team)
    banana_belt_1.races.first.results.create!(:place => 20, :person => big_person, :team => big_team, :number => '')
  
    get :event, :event_id => banana_belt_1.to_param
    assert_response(:success)
    assert_template("results/event")
    assert_not_nil(assigns["event"], "Should assign event")
    assert_equal(assigns["event"], banana_belt_1, "Banana Belt 1")
  end
  
  def test_event_tt
    jack_frost = events(:jack_frost)
    get :event, :event_id => jack_frost.to_param
    assert_response(:success)
    assert_template("results/event")
    assert_not_nil(assigns["event"], "Should assign event")
  end
  
  def test_index
    get(:index, :year => "2004")
    assert_response(:success)
    assert_template("results/index")
    assert_not_nil(assigns["events"], "Should assign events")
    assert_not_nil(assigns["year"], "Should assign year")
    
    assert(!assigns["events"].include?(events(:future_national_federation_event)), "Should only include association-sanctioned events")
    assert(!assigns["events"].include?(events(:usa_cycling_event_with_results)), "Should only include association-sanctioned events")
  end
  
  def test_index_only_shows_sanctioned_events
    get(:index)
    assert_response(:success)
    assert_template("results/index")
    assert_not_nil(assigns["events"], "Should assign events")
    assert_not_nil(assigns["year"], "Should assign year")
    
    assert(!assigns["events"].include?(events(:future_national_federation_event)), "Should only include association-sanctioned events")
    assert_equal(
      RacingAssociation.current.show_only_association_sanctioned_races_on_calendar?, 
      !assigns["events"].include?(events(:usa_cycling_event_with_results)), 
      "Honor RacingAssociation.current.show_only_association_sanctioned_races_on_calendar?"
    )
  end
  
  def test_index_road
    get(:index, :year => "2004", :discipline => 'road')
    assert_response(:success)
    assert_template("results/index")
    assert_not_nil(assigns["events"], "Should assign events")
    assert_not_nil(assigns["year"], "Should assign year")
    assert_equal(assigns["discipline"], Discipline::ROAD, "discipline")
  end
  
  def test_index_road
    get(:index, :year => "2004", :discipline => 'time_trial')
    assert_response(:success)
    assert_template("results/index")
    assert_not_nil(assigns["events"], "Should assign events")
    assert_not_nil(assigns["year"], "Should assign year")
    assert_equal(Discipline[:time_trial], assigns["discipline"], "discipline")
  end
    
  def test_index_all_subclasses
    RacingAssociation.current.now = Time.local(2007, 5)
    SingleDayEvent.create!(:name => 'In past', :date => Date.new(2006, 12, 31)).races.create!(:category => categories(:senior_men)).results.create!
    SingleDayEvent.create!(:name => 'In future', :date => Date.new(2008, 1, 1)).races.create!(:category => categories(:senior_men)).results.create!
    SingleDayEvent.create!(:name => 'SingleDayEvent no races', :date => Date.new(2007, 4, 12))
    single_day_event = SingleDayEvent.create!(:name => 'SingleDayEvent', :date => Date.new(2007, 4, 15))
    single_day_event.races.create!(:category => categories(:senior_men)).results.create!
    
    MultiDayEvent.create!(:name => 'In past', :date => Date.new(2006, 12, 31)).races.create!(:category => categories(:senior_men)).results.create!
    MultiDayEvent.create!(:name => 'In future', :date => Date.new(2008, 1, 1)).races.create!(:category => categories(:senior_men)).results.create!
    MultiDayEvent.create!(:name => 'MultiDayEvent no races', :date => Date.new(2007, 1, 12))
    
    multi_day_event_with_children = MultiDayEvent.create!(:name => 'MultiDayEvent with children, no races', :date => Date.new(2007, 5, 15))
    multi_day_event_with_children.children.create!(:date => Date.new(2007, 5, 15))
    
    multi_day_event_with_races = MultiDayEvent.create!(:name => 'MultiDayEvent with races, no children', :date => Date.new(2007, 6, 12))
    multi_day_event_with_races.races.create!(:category => categories(:senior_men)).results.create!
    
    multi_day_event_with_child_races = MultiDayEvent.create!(:name => 'MultiDayEvent with children races', :date => Date.new(2007, 6, 17))
    multi_day_event_with_child_races_child = multi_day_event_with_child_races.children.create!(:date => Date.new(2007, 6, 17))
    multi_day_event_with_child_races_child.races.create!(:category => categories(:senior_men)).results.create!
        
    Series.create!(:name => 'In past', :date => Date.new(2006, 12, 31)).races.create!(:category => categories(:senior_men)).results.create!
    Series.create!(:name => 'In future', :date => Date.new(2008, 1, 1)).races.create!(:category => categories(:senior_men)).results.create!
    Series.create!(:name => 'Series no races', :date => Date.new(2007, 1, 12))
    
    series_with_children = Series.create!(:name => 'Series with children, no races', :date => Date.new(2007, 2, 15))
    series_with_children.children.create!(:date => Date.new(2007, 2, 15))
    
    series_with_races = Series.create!(:name => 'Series with races, no children', :date => Date.new(2007, 3, 12))
    series_with_races.races.create!(:category => categories(:senior_men)).results.create!
    
    series_with_child_races = Series.create!(:name => 'Series with children races', :date => Date.new(2007, 4, 17))
    series_with_child_races_child = series_with_child_races.children.create!(:date => Date.new(2007, 4, 17))
    series_with_child_races_child.races.create!(:category => categories(:senior_men)).results.create!
    series_with_child_races_child.races.create!(:category => categories(:senior_men)).results.create!
    
    series_with_races_and_child_races = Series.create!(:name => 'Series with races and  with children races', :date => Date.new(2007, 11, 1))
    series_with_races_and_child_races.races.create!(:category => categories(:senior_men)).results.create!
    series_with_races_and_child_races_child = series_with_child_races.children.create!(:date => Date.new(2007, 11, 11))
    series_with_races_and_child_races_child.races.create!(:category => categories(:senior_men)).results.create!
    series_with_races_and_child_races_child.races.create!(:category => categories(:senior_men)).results.create!
    
    WeeklySeries.create!(:name => 'In past', :date => Date.new(2006, 12, 31)).races.create!(:category => categories(:senior_men)).results.create!
    WeeklySeries.create!(:name => 'In future', :date => Date.new(2008, 1, 1)).races.create!(:category => categories(:senior_men)).results.create!
    WeeklySeries.create!(:name => 'WeeklySeries no races', :date => Date.new(2007, 1, 12))
  
    weekly_series_with_children = WeeklySeries.create!(:name => 'WeeklySeries with children, no races', :date => Date.new(2007, 8, 2))
    weekly_series_with_children.children.create!(:date => Date.new(2007, 8, 2))
  
    weekly_series_with_races = WeeklySeries.create!(:name => 'WeeklySeries with races, no children', :date => Date.new(2007, 9, 22))
    weekly_series_with_races.races.create!(:category => categories(:senior_men)).results.create!
  
    weekly_series_with_child_races = WeeklySeries.create!(:name => 'WeeklySeries with children races', :date => Date.new(2007, 3, 5))
    weekly_series_with_child_races_child = weekly_series_with_child_races.children.create!(:date => Date.new(2007, 3, 5))
    weekly_series_with_child_races_child.races.create!(:category => categories(:senior_men)).results.create!
  
    weekly_series_with_races_and_child_races = WeeklySeries.create!(:name => 'WeeklySeries with races and children races', :date => Date.new(2007, 12, 2))
    weekly_series_with_races_and_child_races.races.create!(:category => categories(:senior_men)).results.create!
    weekly_series_with_races_and_child_races_child = weekly_series_with_child_races.children.create!(:date => Date.new(2007, 12, 2))
    weekly_series_with_races_and_child_races_child.races.create!(:category => categories(:senior_men)).results.create!
    
    usa_cycling_event_with_results = SingleDayEvent.create!(:date => Date.new(2007, 5), :sanctioned_by => "NCNCA")
    usa_cycling_event_with_results.races.create!(:category => categories(:senior_men)).results.create!
    
    get(:index, :year => "2007")
    assert_response(:success)
    
    assert_not_nil(assigns['events'], "Should assign 'events'")
    
    if RacingAssociation.current.show_only_association_sanctioned_races_on_calendar?
      expected = [series_with_races, single_day_event, series_with_child_races, multi_day_event_with_races, 
                multi_day_event_with_child_races, series_with_races_and_child_races]
    else
      expected = [series_with_races, single_day_event, series_with_child_races, usa_cycling_event_with_results, multi_day_event_with_races, 
                multi_day_event_with_child_races, series_with_races_and_child_races]
    end
    assert_equal_events(expected, assigns['events'], 'Events')
  
    assert_not_nil(assigns['weekly_series'], "Should assign 'weekly_series'")
    expected = [weekly_series_with_races, weekly_series_with_child_races, weekly_series_with_races_and_child_races]
    assert_equal_events(expected, assigns['weekly_series'], 'weekly_series')
    assert_nil(assigns['discipline'], 'discipline')
  end
  
  def test_person
    weaver = people(:weaver)
    competition = RiderRankings.create!
    competition_result = competition.races.create!(:category => categories(:senior_men)).results.create!
    Score.create!(:competition_result => competition_result, :source_result => results(:weaver_banana_belt), :points => 1)
    
    get :person, :person_id => weaver.to_param
    assert_response(:success)
    assert_template("results/person")
    assert_not_nil(assigns["person"], "Should assign person")
    assert_equal(assigns["person"], weaver, "Weaver!")
  end
  
  def test_person_with_year
    weaver = people(:weaver)
    result = SingleDayEvent.create!(:date => Date.new(2008)).races.create!(:category => categories(:senior_men)).results.create!(:person => weaver, :place => "1")
    
    get :person, :person_id => weaver.to_param, :year => "2008"
    assert_response(:success)
    assert_template("results/person")
    assert_not_nil(assigns["person"], "Should assign person")
    assert_equal(assigns["person"], weaver, "Weaver!")
    assert_equal [ result ], assigns(:event_results), "@event_results for 2008"
  end
  
  def test_person_long_name
    big_team = Team.create!(:name => "T" * 60)
    big_person = Person.create!(:first_name => "f" * 60, :last_name => "L" * 60, :team => big_team)
    events(:banana_belt_1).races.first.results.create!(:person => big_person, :team => big_team, :place => 2, :number => '99')

    get :person, :person_id => big_person.to_param
    assert_response(:success)
    assert_template("results/person")
    assert_not_nil(assigns["person"], "Should assign person")
    assert_equal(assigns["person"], big_person, "person")
    assert_not_nil(assigns["event_results"], "Should assign event_results")
    assert_not_nil(assigns["competition_results"], "Should assign competition_results")
  end
  
  def test_competition
    Bar.calculate!(2004)
    bar = Bar.find_by_year_and_discipline(2004, "Road")
    result = bar.races.detect {|r| r.name == 'Senior Women'}.results.first
    assert_not_nil(result, 'result')
    assert_not_nil(result.person, 'result.person')

    get(:person_event, :event_id => bar.to_param, :person_id => result.person.to_param)
    assert_response(:success)
    assert_template("results/person_event")
    assert_not_nil(assigns["results"], "Should assign results")
    assert_equal(1, assigns["results"].size, "Should assign results")
    assert_equal(assigns["person"], result.person, "Should assign person")
    assert_equal(assigns["event"], bar, "Should assign event")
  end
  
  # A Competition calculated from another Competition
  def test_overall_bar
    Bar.calculate!(2004)
    bar = Bar.find_by_year_and_discipline(2004, "Road")
    result = bar.races.detect {|r| r.name == 'Senior Women'}.results.first
    assert_not_nil(result, 'result')
    assert_not_nil(result.person, 'result.person')
    
    OverallBar.calculate!(2004)
    overall_bar = OverallBar.find(:last)
    result = overall_bar.races.detect {|r| r.name == 'Senior Women'}.results.first
    assert_not_nil(result, 'result')

    get(:person_event, :event_id => overall_bar.to_param, :person_id => result.person.to_param)
    assert_response(:success)
    assert_template("results/person_event")
    assert_not_nil(assigns["results"], "Should assign results")
    assert_equal(1, assigns["results"].size, "Should assign results")
    assert_equal(assigns["person"], result.person, "Should assign person")
    assert_equal(assigns["event"], overall_bar, "Should assign event")
  end
  
  def test_empty_competition
    bar = Bar.create!
    person = Person.create!(:name => 'JP Morgen')

    get(:person_event, :event_id => bar.to_param, :person_id => person.to_param)
    assert_response(:success)
    assert_template("results/person_event")
    assert_equal(assigns["results"], [], "Should assign results")
    assert_equal(assigns["person"], person, "Should assign person")
    assert_equal(assigns["event"], bar, "Should assign event")
  end
  
  def test_competition_team
    Bar.calculate!(2004)
    TeamBar.calculate!(2004)
    bar = TeamBar.find(:all).first
    result = bar.races.first.results.first
    assert_not_nil(result, 'result')
    assert_not_nil result.team, "result.team" 

    get(:team_event, :event_id => bar.to_param, :team_id => result.team.to_param, :race_id => result.race.to_param)

    assert_response(:success)
    assert_template("results/team_event")
    assert_equal(result, assigns["result"], "Should assign result")
  end
  
  def test_person_with_overall_results
    person = people(:tonkin)
    event = CrossCrusadeOverall.create!(:parent => Series.create!)
    event.races.create!(:category => categories(:senior_men)).results.create!(:place => "1")
    get :person, :person_id => person.to_param
    assert_response :success
  end
  
  def test_person_overall_results
    person = people(:tonkin)
    event = CrossCrusadeOverall.create!(:parent => Series.create!)
    event.races.create!(:category => categories(:senior_men)).results.create!(:place => "1")
    get(:person_event, :event_id => event.to_param, :person_id => person.to_param)
    assert_response :success
  end
  
  def test_column_headers_display_correctly
    event = events(:banana_belt_1)
    race = event.races.first
    race.results.create!(:points_bonus => 8, :points_penalty => -2, :laps => 9)
    race.result_columns = Race::DEFAULT_RESULT_COLUMNS.dup
    race.result_columns << "points_bonus"
    race.result_columns << "points_penalty"
    race.result_columns << "laps"
    race.save!
    
    get(:event, :event_id => event.to_param)
    assert_response(:success)
    
    assert(@response.body["Bonus"], "Should format points_bonus correctly")
    assert(@response.body["Penalty"], "Should format points_penalty correctly")
    assert(@response.body["Laps"], "Should format laps correctly")
  end
  
  def test_index_ssl
    if RacingAssociation.current.ssl?
      use_ssl
      get :index
      assert_redirected_to "http://test.host/results"
    end
  end
  
  def test_return_404_for_missing_event
    assert_raise(ActiveRecord::RecordNotFound) { get(:event, :event_id => 236127361273) }
  end
  
  def test_return_404_for_missing_person
    assert_raise(ActiveRecord::RecordNotFound) { get(:person, :person_id => 236127361273) }
  end
  
  def test_return_404_for_missing_team_event
    assert_raise(ActiveRecord::RecordNotFound) { get(:team_event, :event_id => events(:banana_belt_1).to_param, :team_id => 236127361273) }
  end
  
  def test_return_404_for_missing_team_event_bad_event
    assert_raise(ActiveRecord::RecordNotFound) { get(:team_event, :event_id => 236127361273, :team_id => teams(:vanilla).to_param) }
  end
  
  def test_return_404_for_missing_team_event_result
    event = CrossCrusadeTeamCompetition.create!(:parent => SingleDayEvent.create!(:name => "Cross Crusade"))
    assert_raise(ActiveRecord::RecordNotFound) {
      get(:team_event, :event_id => event.to_param, :team_id => teams(:vanilla).to_param) 
    }
  end
  
  def test_missing_person_event_bad_person
    assert_raise(ActiveRecord::RecordNotFound) { 
      get(:person_event, :event_id => events(:banana_belt_1).to_param, :person_id => 236127361273) 
    }
  end
  
  def test_return_404_for_missing_person_event_bad_event
    assert_raise(ActiveRecord::RecordNotFound) { 
      get(:person_event, :event_id => 236127361273, :person_id => people(:weaver).to_param) 
    }
  end
  
  def test_missing_person_event_result
    Bar.create!
    event = Bar.find_for_year
    get(:person_event, :event_id => event.to_param, :person_id => Person.create!.to_param)
    assert_response :success
  end
  
  def test_return_404_for_missing_event
    assert_raise(ActiveRecord::RecordNotFound) { get(:event, :event_id => 236127361273) }
  end
  
  def test_return_404_for_missing_person
    assert_raise(ActiveRecord::RecordNotFound) { get(:person, :person_id => 236127361273) }
  end
  
  def test_return_404_for_missing_team_event
    assert_raise(ActiveRecord::RecordNotFound) { get(:team_event, :event_id => events(:banana_belt_1).to_param, :team_id => 236127361273) }
  end
  
  def test_return_404_for_missing_team_event_bad_event
    assert_raise(ActiveRecord::RecordNotFound) { get(:team_event, :event_id => 236127361273, :team_id => teams(:vanilla).to_param) }
  end
  
  def test_return_404_for_missing_person_event
    assert_raise(ActiveRecord::RecordNotFound) { get(:person_event, :event_id => events(:banana_belt_1).to_param, :person_id => 236127361273) }
  end
  
  def test_return_404_for_missing_person_event_bad_event
    assert_raise(ActiveRecord::RecordNotFound) { get(:person_event, :event_id => 236127361273, :person_id => people(:weaver).to_param) }
  end

  def test_index_as_xml
    event = events :banana_belt_1
    get :index, :event_id => event[:id], :format => "xml"
    assert_response :success
    assert_equal "application/xml", @response.content_type
    [
      "race > city",
      "race > distance",
      "race > field-size",
      "race > finishers",
      "race > id",
      "race > laps",
      "race > notes",
      "race > state",
      "race > time",
      "race > results",
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
      "result > person",
      "person > first-name",
      "person > last-name",
      "person > license",
      "person > id",
      "race > category",
      "category > ages-begin",
      "category > ages-end",
      "category > friendly-param",
      "category > id",
      "category > name"
    ].each { |key| assert_select key }
  end

  def test_index_as_json
    event = events :banana_belt_1
    get :index, :event_id => event[:id], :format => "json"
    assert_response :success
    assert_equal "application/json", @response.content_type
  end

  def test_index_filtered_by_person_id
    person = people :weaver
    get :index, :person_id => person[:id], :format => "xml"
    assert_response :success
  end
  
  def test_show_unregistered_teams_in_results
    team = teams(:gentle_lovers)
    team.member = false
    team.save!
    
    get :event, :event_id => events(:banana_belt_1).to_param
    assert_response :success
    assert @response.body["Kona"]
    assert @response.body["Gentle Lovers"]
  end
  
  def test_do_not_show_unregistered_teams_in_results
    RacingAssociation.current.unregistered_teams_in_results = false
    RacingAssociation.current.save!
    
    event = SingleDayEvent.create!
    race = event.races.create!(:category => categories(:senior_men))
    race.results.create! :person => people(:tonkin), :team => teams(:kona)
    race.results.create! :person => Person.create!, :team => Team.create!(:name => "DFL")
    
    get :event, :event_id => events(:banana_belt_1).to_param
    assert_response :success
    assert @response.body["Kona"]
    assert !@response.body["DFL"]
  end
  
  def test_do_not_show_unregistered_teams_in_results_should_show_previous_years
    RacingAssociation.current.unregistered_teams_in_results = false
    RacingAssociation.current.save!
    
    team = teams(:gentle_lovers)
    team.member = false
    team.save!
    
    get :event, :event_id => events(:banana_belt_1).to_param
    assert_response :success
    assert @response.body["Kona"]
    assert @response.body["Gentle Lovers"]
  end
end
