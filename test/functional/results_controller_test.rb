require File.dirname(__FILE__) + '/../test_helper'
require_or_load 'results_controller'

# Re-raise errors caught by the controller.
class ResultsController; def rescue_action(e) raise e end; end

class ResultsControllerTest < Test::Unit::TestCase

  def setup
    @controller = ResultsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_event
    banana_belt_1 = events(:banana_belt_1)
    opts = {:controller => "results", :action => "event", :id => banana_belt_1.id.to_s}
    assert_routing("/results/event/2", opts)

    get(:event, {:action => "event", :id => banana_belt_1.id.to_s})
    assert_response(:success)
    assert_template("results/event")
    assert_not_nil(assigns["event"], "Should assign event")
    assert_equal(assigns["event"], banana_belt_1, "Banana Belt 1")
  end
  
  def test_event_bar
    bar = Bar.create
    opts = {:controller => "results", :action => "event", :id => bar.id.to_s}
    assert_routing("/results/event/#{bar.id}", opts)

    get(:event, :id => bar.id.to_s)
    assert_response(:redirect)
    assert_redirect_url "http://test.host/bar/#{bar.date.year}"
  end
  
  def test_event_with_discipline
    banana_belt_1 = events(:banana_belt_1)
    big_team = Team.create(:name => "T" * 60)
    big_racer = Racer.create(:first_name => "f" * 60, :last_name => "L" * 60, :team => big_team)
    banana_belt_1.standings.first.races.first.results.create(:place => 20, :racer => big_racer, :team => big_team, :number => '')
    opts = {:controller => "results", :action => "event", :year => "2004", :discipline => "road", :id => banana_belt_1.id.to_s}
    assert_routing("/results/2004/road/2", opts)

    get(:event, {:year => "2004", :discipline => "road", :id => banana_belt_1.id.to_s})
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
    assert_equal(assigns["discipline"], Discipline[:time_trial], "discipline")
  end
  
  def test_racer
  	weaver = racers(:weaver)
    opts = {:controller => "results", :action => "racer", :id => weaver.id.to_s}
    assert_routing("/results/racer/#{weaver.id}", opts)

    get(:racer, {:controller => "results", :action => "racer", :id => weaver.id.to_s})
    assert_response(:success)
    assert_template("results/racer")
    assert_not_nil(assigns["racer"], "Should assign racer")
    assert_equal(assigns["racer"], weaver, "Weaver!")
  end
  
  def test_racer_long_name
    big_team = Team.create(:name => "T" * 60)
    big_racer = Racer.create(:first_name => "f" * 60, :last_name => "L" * 60, :team => big_team)
    events(:banana_belt_1).standings.first.races.first.results.create(:racer => big_racer, :team => big_team, :place => 2, :number => '99')

    get(:racer, {:controller => "results", :action => "racer", :id => big_racer.id.to_s})
    assert_response(:success)
    assert_template("results/racer")
    assert_not_nil(assigns["racer"], "Should assign racer")
    assert_equal(assigns["racer"], big_racer, "racer")
    assert_not_nil(assigns["event_results"], "Should assign event_results")
    assert_not_nil(assigns["competition_results"], "Should assign competition_results")
  end
  
  def test_team
  	team = teams(:vanilla)
    opts = {:controller => "results", :action => "team", :id => team.id.to_s}
    assert_routing("/results/team/#{team.id}", opts)

    get(:racer, {:controller => "results", :action => "team", :id => team.id.to_s})
    assert_response(:success)
    assert_template("results/team")
    assert_not_nil(assigns["team"], "Should assign team")
    assert_equal(assigns["team"], team, "team")
    assert_not_nil(assigns["event_results"], "Should assign event_results")
    assert_not_nil(assigns["competition_results"], "Should assign competition_results")
  end
  
  def test_scores
    opts = {:controller => "results", :action => "show", :id => '1'}
    assert_routing("/results/show/1", opts)

    get(:show, {:id => '1'})
    assert_response(:success)
    assert_template("results/show")
    assert_not_nil(assigns["result"], "Should assign result")
  end
  
  def test_competition
    Bar.recalculate(2004)
    bar = Bar.find(:all).first
    result = bar.standings.detect {|s| s.name == 'Road'}.races.detect {|r| r.name == 'Senior Women'}.results.first
    assert_not_nil(result, 'result')
    assert_not_nil(result.racer, 'result.racer')
    opts = {:controller => "results", :action => "competition", :competition_id => bar.to_param.to_s, :racer_id => result.racer.to_param.to_s}
    assert_routing("/results/competition/#{bar.to_param}/racer/#{result.racer.to_param}", opts)

    get(:competition, :competition_id => bar.to_param.to_s, :racer_id => result.racer.to_param.to_s)
    assert_response(:success)
    assert_template("results/competition")
    assert_not_nil(assigns["results"], "Should assign results")
    assert_equal(2, assigns["results"].size, "Should assign results")
    assert_equal(assigns["racer"], result.racer, "Should assign racer")
    assert_equal(assigns["competition"], bar, "Should assign competition")
  end
  
  def test_empty_competition
    fail('not impl')
    result = bar.standings.detect {|s| s.name == 'Road'}.races.detect {|r| r.name == 'Senior Women'}.results.first
    assert_not_nil(result, 'result')
    opts = {:controller => "results", :action => "competition", :competition_id => bar.to_param.to_s, :racer_id => result.racer.to_param.to_s}
    assert_routing("/results/competition/#{bar.to_param}/racer/#{result.racer.to_param}", opts)

    get(:competition, :competition_id => bar.to_param.to_s, :racer_id => result.racer.to_param.to_s)
    assert_response(:success)
    assert_template("results/show")
    assert_equal(assigns["results"], results, "Should assign results")
    assert_equal(assigns["racer"], result.racer, "Should assign racer")
    assert_equal(assigns["competition"], bar, "Should assign competition")
  end
  
  def test_competition_team
    Bar.recalculate(2004)
    bar = Bar.find(:all).first
    result = bar.standings.detect {|s| s.name == 'Team'}.races.first.results.first
    assert_not_nil(result, 'result')
    opts = {:controller => "results", :action => "competition", :competition_id => bar.to_param.to_s, :team_id => result.team.to_param.to_s}
    assert_routing("/results/competition/#{bar.to_param}/team/#{result.team.to_param}", opts)

    get(:competition, :competition_id => bar.to_param.to_s, :team_id => result.team.to_param.to_s)
    assert_response(:success)
    assert_template("results/team_competition")
    assert_equal(assigns["results"], results, "Should assign results")
    assert_equal(assigns["team"], result.team, "Should assign team")
    assert_equal(assigns["competition"], bar, "Should assign competition")
  end
end