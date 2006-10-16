require File.dirname(__FILE__) + '/../test_helper'
require_or_load 'results_controller'

# Re-raise errors caught by the controller.
class ResultsController; def rescue_action(e) raise e end; end

class ResultsControllerTest < Test::Unit::TestCase

  fixtures :teams, :racers, :aliases, :users, :promoters, :categories, :disciplines, :events, :standings, :races, :results

  def setup
    @controller = ResultsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_event
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
    assert_not_nil(assigns["road_events"], "Should assign road_events")
    assert_not_nil(assigns["year"], "Should assign year")
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
  
  def test_racer
    big_team = Team.create(:name => "T" * 60)
    big_racer = Racer.create(:first_name => "f" * 60, :last_name => "L" * 60, :team => big_team)
    events(:banana_belt_1).standings.first.races.first.results.create(:racer => big_racer, :team => big_team, :place => 2, :number => '99')

    get(:racer, {:controller => "results", :action => "racer", :id => big_racer.id.to_s})
    assert_response(:success)
    assert_template("results/racer")
    assert_not_nil(assigns["racer"], "Should assign racer")
    assert_equal(assigns["racer"], big_racer, "racer")
  end
  
  def test_scores
    opts = {:controller => "results", :action => "show", :id => '1'}
    assert_routing("/results/show/1", opts)

    get(:show, {:id => '1'})
    assert_response(:success)
    assert_template("results/show")
    assert_not_nil(assigns["result"], "Should assign result")
  end
  
end