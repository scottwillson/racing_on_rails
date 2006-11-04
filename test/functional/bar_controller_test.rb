require File.dirname(__FILE__) + '/../test_helper'
require 'bar_controller'

class BarController; def rescue_action(e) raise e end; end

class BarControllerTest < Test::Unit::TestCase

  include ActionView::Helpers::TextHelper

  def setup
    @controller = BarController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    big_team = Team.create(:name => "T" * 60)
    weaver = racers(:weaver)
    weaver.team = big_team
    events(:banana_belt_1).standings.first.races.first.results.create(:racer => weaver, :team => big_team)
    weaver.first_name = "f" * 60
    weaver.last_name = "T" * 60

    @bar = Bar.recalculate(2004)
  end

  def test_index
    opts = {:controller => "bar", :action => "show", :year => "2004"}
    assert_routing("/bar/2004", opts)
    get(:show, :year => "2004")
    assert_response(:success)
    assert_template("bar/show")
    assert_not_nil(assigns["standings"], "Should assign standings")
    assert_not_nil(assigns["year"], "Should assign year")
    assert_not_nil(assigns["discipline"], "Should assign discipline")
    assert_not_nil(assigns["all_disciplines"], "Should assign all_disciplines")
  end

  def test_show
    opts = {:controller => "bar", :action => "show", :year => "2004", :discipline => "Road"}
    assert_routing("/bar/2004/Road", opts)
    get(:show, :year => "2004")
    assert_response(:success)
    assert_template("bar/show")
    assert_not_nil(assigns["standings"], "Should assign road_events")
    assert_not_nil(assigns["year"], "Should assign year")
    assert_not_nil(assigns["discipline"], "Should assign discipline")
    assert_not_nil(assigns["all_disciplines"], "Should assign all_disciplines")
  end
  
  def test_categories
    opts = {:controller => "bar", :action => "categories", :year => "2004"}
    assert_routing("/bar/2004/categories", opts)
    get(:categories, :year => '2004')
    assert_response(:success)
    assert_template("bar/categories")
    assert_not_nil(assigns["bar"], "Should assign bar")
    assert_not_nil(assigns["excluded_categories"], "Should assign excluded_categories")
  end
  
  # Broken lib implementation!
  def test_truncate
    name = 'Broadmark'
    truncated = truncate(name, 5)
    assert_equal('Br...', truncated, 'truncated Broadmark')

    truncated = truncate(name, 9)
    assert_equal('Broadmark', truncated, 'truncated Broadmark')

    truncated = truncate(name, 8)
    assert_equal('Broad...', truncated, 'truncated Broadmark')
  end
end
