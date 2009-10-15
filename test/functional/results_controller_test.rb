require "test_helper"

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
      ASSOCIATION.show_only_association_sanctioned_races_on_calendar?, 
      !assigns["events"].include?(events(:usa_cycling_event_with_results)), 
      "Honor ASSOCIATION.show_only_association_sanctioned_races_on_calendar?"
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
      SingleDayEvent.create!(:name => 'In past', :date => Date.new(2008, 12, 31)).races.create!(:category => categories(:senior_men)).results.create!
      SingleDayEvent.create!(:name => 'In future', :date => Date.new(2010, 1, 1)).races.create!(:category => categories(:senior_men)).results.create!
      SingleDayEvent.create!(:name => 'SingleDayEvent no races', :date => Date.new(2009, 4, 12))
      single_day_event = SingleDayEvent.create!(:name => 'SingleDayEvent', :date => Date.new(2009, 4, 15))
      single_day_event.races.create!(:category => categories(:senior_men)).results.create!
      
      MultiDayEvent.create!(:name => 'In past', :date => Date.new(2008, 12, 31)).races.create!(:category => categories(:senior_men)).results.create!
      MultiDayEvent.create!(:name => 'In future', :date => Date.new(2010, 1, 1)).races.create!(:category => categories(:senior_men)).results.create!
      MultiDayEvent.create!(:name => 'MultiDayEvent no races', :date => Date.new(2009, 1, 12))
      
      multi_day_event_with_children = MultiDayEvent.create!(:name => 'MultiDayEvent with children, no races', :date => Date.new(2009, 5, 15))
      multi_day_event_with_children.children.create!(:date => Date.new(2009, 5, 15))
      
      multi_day_event_with_races = MultiDayEvent.create!(:name => 'MultiDayEvent with races, no children', :date => Date.new(2009, 6, 12))
      multi_day_event_with_races.races.create!(:category => categories(:senior_men)).results.create!
      
      multi_day_event_with_child_races = MultiDayEvent.create!(:name => 'MultiDayEvent with children races', :date => Date.new(2009, 6, 17))
      multi_day_event_with_child_races_child = multi_day_event_with_child_races.children.create!(:date => Date.new(2009, 6, 17))
      multi_day_event_with_child_races_child.races.create!(:category => categories(:senior_men)).results.create!
          
      Series.create!(:name => 'In past', :date => Date.new(2008, 12, 31)).races.create!(:category => categories(:senior_men)).results.create!
      Series.create!(:name => 'In future', :date => Date.new(2010, 1, 1)).races.create!(:category => categories(:senior_men)).results.create!
      Series.create!(:name => 'Series no races', :date => Date.new(2009, 1, 12))
      
      series_with_children = Series.create!(:name => 'Series with children, no races', :date => Date.new(2009, 2, 15))
      series_with_children.children.create!(:date => Date.new(2009, 2, 15))
      
      series_with_races = Series.create!(:name => 'Series with races, no children', :date => Date.new(2009, 3, 12))
      series_with_races.races.create!(:category => categories(:senior_men)).results.create!
      
      series_with_child_races = Series.create!(:name => 'Series with children races', :date => Date.new(2009, 4, 17))
      series_with_child_races_child = series_with_child_races.children.create!(:date => Date.new(2009, 4, 17))
      series_with_child_races_child.races.create!(:category => categories(:senior_men)).results.create!
      series_with_child_races_child.races.create!(:category => categories(:senior_men)).results.create!
      
      series_with_races_and_child_races = Series.create!(:name => 'Series with races and  with children races', :date => Date.new(2009, 11, 1))
      series_with_races_and_child_races.races.create!(:category => categories(:senior_men)).results.create!
      series_with_races_and_child_races_child = series_with_child_races.children.create!(:date => Date.new(2009, 11, 11))
      series_with_races_and_child_races_child.races.create!(:category => categories(:senior_men)).results.create!
      series_with_races_and_child_races_child.races.create!(:category => categories(:senior_men)).results.create!
      
      WeeklySeries.create!(:name => 'In past', :date => Date.new(2008, 12, 31)).races.create!(:category => categories(:senior_men)).results.create!
      WeeklySeries.create!(:name => 'In future', :date => Date.new(2010, 1, 1)).races.create!(:category => categories(:senior_men)).results.create!
      WeeklySeries.create!(:name => 'WeeklySeries no races', :date => Date.new(2009, 1, 12))
    
      weekly_series_with_children = WeeklySeries.create!(:name => 'WeeklySeries with children, no races', :date => Date.new(2009, 8, 2))
      weekly_series_with_children.children.create!(:date => Date.new(2009, 8, 2))
    
      weekly_series_with_races = WeeklySeries.create!(:name => 'WeeklySeries with races, no children', :date => Date.new(2009, 9, 22))
      weekly_series_with_races.races.create!(:category => categories(:senior_men)).results.create!
    
      weekly_series_with_child_races = WeeklySeries.create!(:name => 'WeeklySeries with children races', :date => Date.new(2009, 3, 5))
      weekly_series_with_child_races_child = weekly_series_with_child_races.children.create!(:date => Date.new(2009, 3, 5))
      weekly_series_with_child_races_child.races.create!(:category => categories(:senior_men)).results.create!
    
      weekly_series_with_races_and_child_races = WeeklySeries.create!(:name => 'WeeklySeries with races and children races', :date => Date.new(2009, 12, 2))
      weekly_series_with_races_and_child_races.races.create!(:category => categories(:senior_men)).results.create!
      weekly_series_with_races_and_child_races_child = weekly_series_with_child_races.children.create!(:date => Date.new(2009, 12, 2))
      weekly_series_with_races_and_child_races_child.races.create!(:category => categories(:senior_men)).results.create!
      
      get(:index, :year => '2009')
      assert_response(:success)
      
      assert_not_nil(assigns['events'], "Should assign 'events'")
      
      if ASSOCIATION.show_only_association_sanctioned_races_on_calendar?
        expected = [series_with_races, single_day_event, series_with_child_races, multi_day_event_with_races, 
                  multi_day_event_with_child_races, series_with_races_and_child_races]
      else
        expected = [series_with_races, single_day_event, series_with_child_races, events(:usa_cycling_event_with_results), multi_day_event_with_races, 
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
  
  def test_team
  	team = teams(:vanilla)
    get(:deprecated_team, :team_id => team.to_param)
    assert_redirected_to(team_results_path(team))
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

    get(:team_event, :event_id => bar.to_param, :team_id => result.team.to_param)

    assert_response(:success)
    assert_template("results/team_event")
    assert_equal(result, assigns["result"], "Should assign result")
  end

  def test_show_person_result
    result = results(:tonkin_kings_valley)
    get(:show, :id => result.to_param)
    assert_redirected_to event_person_results_path(result.event, result.person)
  end  

  def test_show_team_result
    result = races(:kings_valley_3).results.create!(:team => teams(:vanilla))
    get(:show, :id => result.to_param)
    assert_redirected_to event_team_results_path(result.event, teams(:vanilla))
  end
  
  def test_show_result_no_team_no_person
    result = races(:kings_valley_3).results.create!
    get(:show, :id => result.to_param)
    assert_redirected_to(event_results_path(result.event))
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
    use_ssl
    get :index
    assert_redirected_to "http://test.host/results"
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
end
