require "test_helper"

class ResultsControllerTest < ActionController::TestCase
  def test_event
    banana_belt_1 = events(:banana_belt_1)
    opts = {:controller => "results", :action => "event", :id => banana_belt_1.to_param}
    assert_routing("/results/event/#{banana_belt_1.to_param}", opts)

    get(:event, {:action => "event", :id => banana_belt_1.to_param})
    assert_response(:success)
    assert_template("results/event")
    assert_not_nil(assigns["event"], "Should assign event")
    assert_equal(assigns["event"], banana_belt_1, "Banana Belt 1")
  end
  
  def test_event_rider_rankings
    rider_rankings = RiderRankings.create!
    opts = {:controller => "results", :action => "event", :id => rider_rankings.to_param}
    assert_routing("/results/event/#{rider_rankings.id}", opts)

    get(:event, {:action => "event", :id => rider_rankings.to_param})
    assert_response(:success)
    assert_template("results/event")
    assert_not_nil(assigns["event"], "Should assign event")
    assert_equal(assigns["event"], rider_rankings, "rider_rankings")
  end
  
  def test_event_bar
    bar = Bar.create!
    opts = {:controller => "results", :action => "event", :id => bar.to_param}
    assert_routing("/results/event/#{bar.id}", opts)

    get(:event, :id => bar.to_param)
    assert_response(:redirect)
    assert_redirected_to(:controller => 'bar', :year => bar.date.year)
  end
  
  def test_redirect_to_ironman
    event = Ironman.create!
    get :event, :id => event.to_param
    assert_redirected_to ironman_path(:year => event.year)
  end
  
  def test_event_with_discipline
    banana_belt_1 = events(:banana_belt_1)
    big_team = Team.create!(:name => "T" * 60)
    big_racer = Racer.create!(:first_name => "f" * 60, :last_name => "L" * 60, :team => big_team)
    banana_belt_1.races.first.results.create!(:place => 20, :racer => big_racer, :team => big_team, :number => '')
    opts = {:controller => "results", :action => "event", :year => "2004", :discipline => "road", :id => banana_belt_1.to_param}
    assert_routing("/results/2004/road/#{banana_belt_1.to_param}", opts)

    get(:event, {:year => "2004", :discipline => "road", :id => banana_belt_1.to_param})
    assert_response(:success)
    assert_template("results/event")
    assert_not_nil(assigns["event"], "Should assign event")
    assert_equal(assigns["event"], banana_belt_1, "Banana Belt 1")
  end
  
  def test_event_tt
    jack_frost = events(:jack_frost)
    get(:event, {:year => "2004", :discipline => "road", :id => jack_frost.to_param})
    assert_response(:success)
    assert_template("results/event")
    assert_not_nil(assigns["event"], "Should assign event")
  end
  
  def test_index
    opts = {:controller => "results", :action => "index", :year => "2004"}
    assert_routing("/results/2004", opts)

    get(:index, :year => "2004")
    assert_response(:success)
    assert_template("results/index")
    assert_not_nil(assigns["events"], "Should assign events")
    assert_not_nil(assigns["year"], "Should assign year")
    
    assert(!assigns["events"].include?(events(:future_usa_cycling_event)), "Should only include association-sanctioned events")
    assert(!assigns["events"].include?(events(:usa_cycling_event_with_results)), "Should only include association-sanctioned events")
  end
  
  def test_index_only_shows_sanctioned_events
    opts = {:controller => "results", :action => "index"}
    assert_routing("/results", opts)

    get(:index)
    assert_response(:success)
    assert_template("results/index")
    assert_not_nil(assigns["events"], "Should assign events")
    assert_not_nil(assigns["year"], "Should assign year")
    
    assert(!assigns["events"].include?(events(:future_usa_cycling_event)), "Should only include association-sanctioned events")
    assert_equal(
      ASSOCIATION.show_only_association_sanctioned_races_on_calendar?, 
      !assigns["events"].include?(events(:usa_cycling_event_with_results)), 
      "Honor ASSOCIATION.show_only_association_sanctioned_races_on_calendar?"
    )
  end
  
  def test_index_road
    opts = {:controller => "results", :action => "index", :year => "2004", :discipline => 'road'}
    assert_routing("/results/2004/road", opts)

    get(:index, :year => "2004", :discipline => 'road')
    assert_response(:success)
    assert_template("results/index")
    assert_not_nil(assigns["events"], "Should assign events")
    assert_not_nil(assigns["year"], "Should assign year")
    assert_equal(assigns["discipline"], Discipline::ROAD, "discipline")
  end
  
  def test_index_road
    opts = {:controller => "results", :action => "index", :year => "2004", :discipline => 'time_trial'}
    assert_routing("/results/2004/time_trial", opts)

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
  
  def test_racer
  	weaver = racers(:weaver)
    opts = {:controller => "results", :action => "racer", :id => weaver.to_param}
    assert_routing("/results/racer/#{weaver.id}", opts)

    get(:racer, {:controller => "results", :action => "racer", :id => weaver.to_param})
    assert_response(:success)
    assert_template("results/racer")
    assert_not_nil(assigns["racer"], "Should assign racer")
    assert_equal(assigns["racer"], weaver, "Weaver!")
  end
  
  def test_racer_long_name
    big_team = Team.create!(:name => "T" * 60)
    big_racer = Racer.create!(:first_name => "f" * 60, :last_name => "L" * 60, :team => big_team)
    events(:banana_belt_1).races.first.results.create!(:racer => big_racer, :team => big_team, :place => 2, :number => '99')

    get(:racer, {:controller => "results", :action => "racer", :id => big_racer.to_param})
    assert_response(:success)
    assert_template("results/racer")
    assert_not_nil(assigns["racer"], "Should assign racer")
    assert_equal(assigns["racer"], big_racer, "racer")
    assert_not_nil(assigns["event_results"], "Should assign event_results")
    assert_not_nil(assigns["competition_results"], "Should assign competition_results")
  end
  
  def test_team
  	team = teams(:vanilla)
    opts = {:controller => "results", :action => "team", :id => team.to_param}
    assert_routing("/results/team/#{team.id}", opts)

    get(:team, {:controller => "results", :action => "team", :id => team.to_param})
    assert_redirected_to(team_path(team))
  end
  
  def test_competition
    Bar.calculate!(2004)
    bar = Bar.find_by_year_and_discipline(2004, "Road")
    result = bar.races.detect {|r| r.name == 'Senior Women'}.results.first
    assert_not_nil(result, 'result')
    assert_not_nil(result.racer, 'result.racer')
    opts = {:controller => "results", :action => "competition", :competition_id => bar.to_param.to_s, :racer_id => result.racer.to_param.to_s}
    assert_routing("/results/competition/#{bar.to_param}/racer/#{result.racer.to_param}", opts)

    get(:competition, :competition_id => bar.to_param.to_s, :racer_id => result.racer.to_param.to_s)
    assert_response(:success)
    assert_template("results/competition")
    assert_not_nil(assigns["results"], "Should assign results")
    assert_equal(1, assigns["results"].size, "Should assign results")
    assert_equal(assigns["racer"], result.racer, "Should assign racer")
    assert_equal(assigns["competition"], bar, "Should assign competition")
  end
  
  # A Competition calculated from another Competition
  def test_overall_bar
    Bar.calculate!(2004)
    bar = Bar.find_by_year_and_discipline(2004, "Road")
    result = bar.races.detect {|r| r.name == 'Senior Women'}.results.first
    assert_not_nil(result, 'result')
    assert_not_nil(result.racer, 'result.racer')
    
    OverallBar.calculate!(2004)
    competition = OverallBar.find(:last)
    result = competition.races.detect {|r| r.name == 'Senior Women'}.results.first
    assert_not_nil(result, 'result')

    get(:competition, :competition_id => competition.to_param.to_s, :racer_id => result.racer.to_param.to_s)
    assert_response(:success)
    assert_template("results/competition")
    assert_not_nil(assigns["results"], "Should assign results")
    assert_equal(1, assigns["results"].size, "Should assign results")
    assert_equal(assigns["racer"], result.racer, "Should assign racer")
    assert_equal(assigns["competition"], bar, "Should assign competition")
  end
  
  def test_empty_competition
    bar = Bar.create!
    racer = Racer.create!(:name => 'JP Morgen')
    opts = {:controller => "results", :action => "competition", :competition_id => bar.to_param.to_s, :racer_id => racer.to_param.to_s}
    assert_routing("/results/competition/#{bar.to_param}/racer/#{racer.to_param}", opts)

    get(:competition, :competition_id => bar.to_param.to_s, :racer_id => racer.to_param.to_s)
    assert_response(:success)
    assert_template("results/competition")
    assert_equal(assigns["results"], [], "Should assign results")
    assert_equal(assigns["racer"], racer, "Should assign racer")
    assert_equal(assigns["competition"], bar, "Should assign competition")
  end
  
  def test_competition_team
    Bar.calculate!(2004)
    TeamBar.calculate!(2004)
    bar = TeamBar.find(:all).first
    result = bar.races.first.results.first
    assert_not_nil(result, 'result')
    opts = {:controller => "results", :action => "competition", :competition_id => bar.to_param.to_s, :team_id => result.team.to_param.to_s}
    assert_routing("/results/competition/#{bar.to_param}/team/#{result.team.to_param}", opts)

    get(:competition, :competition_id => bar.to_param.to_s, :team_id => result.team.to_param.to_s)
    assert_response(:success)
    assert_template("results/team_competition")
    assert_equal([result], assigns["results"], "Should assign results")
    assert_equal(result.team, assigns["team"], "Should assign team")
    assert_equal(bar, assigns["competition"], "Should assign competition")
  end

  def test_show_racer_result
    result = results(:tonkin_kings_valley)
    opts = {:controller => "results", :action => "show", :id => result.to_param}
    assert_routing("/results/show/#{result.id}", opts)

    get(:show, {:controller => "results", :id => result.to_param})
    assert_response(:redirect)
    assert_redirected_to(
      :controller => "results", 
      :action => "competition", 
      :competition_id => result.event.to_param, 
      :racer_id => result.racer.to_param)
  end  

  def test_show_team_result
    result = races(:kings_valley_3).results.create!(:team => teams(:vanilla))
    opts = {:controller => "results", :action => "show", :id => result.to_param}
    assert_routing("/results/show/#{result.id}", opts)

    get(:show, {:controller => "results", :id => result.to_param})
    assert_response(:redirect)
    assert_redirected_to(
      :controller => "results", 
      :action => "competition", 
      :competition_id => result.event.to_param, 
      :team_id => teams(:vanilla).to_param)
  end
  
  def test_show_result_no_team_no_racer
    result = races(:kings_valley_3).results.create!
    opts = {:controller => "results", :action => "show", :id => result.to_param}
    assert_routing("/results/show/#{result.id}", opts)

    get(:show, {:controller => "results", :id => result.to_param})
    assert_response(:redirect)
    assert_redirected_to(
      :controller => "results", 
      :action => "competition", 
      :competition_id => result.event.to_param)
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
    
    get(:event, :id => event.to_param)
    assert_response(:success)
    
    assert(@response.body["Bonus"], "Should format points_bonus correctly")
    assert(@response.body["Penalty"], "Should format points_penalty correctly")
    assert(@response.body["Laps"], "Should format laps correctly")
  end
end