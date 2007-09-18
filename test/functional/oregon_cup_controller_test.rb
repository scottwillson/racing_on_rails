require File.dirname(__FILE__) + '/../test_helper'
require 'oregon_cup_controller'

class OregonCupController; def rescue_action(e) raise e end; end

class OregonCupControllerTest < Test::Unit::TestCase

  include OregonCupHelper
  
  def setup
    @controller = OregonCupController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_routing
    assert_routing("/oregon_cup", {:controller => "oregon_cup", :action => "index"})
    assert_routing("/oregon_cup/2003", {:controller => "oregon_cup", :action => "index", :year => '2003'})
  end

  def test_index
    OregonCup.create(:date => Date.new(2004))
    get(:index, :year => "2004")
    assert_response(:success)
    assert_template("oregon_cup/index")
    assert_not_nil(assigns["oregon_cup"], "Should assign oregon_cup")
  end

  def test_index
    get(:index, :year => "2004")
    assert_response(:success)
    assert_template("oregon_cup/index")
    assert_not_nil(assigns["oregon_cup"], "Should assign oregon_cup")
  end

  def test_races
    get(:races, :year => "2004")
    assert_response(:redirect)
    assert_redirected_to(:action => :index)
  end
  
  def test_rules
    get(:rules)
    assert_response(:redirect)
    assert_redirected_to(:action => :index)
  end
  
  def test_flyer_link_from_app_server
    external_event = Event.new
    external_event.name = 'Mudslinger'
    external_event.flyer = 'http://my.yahoo.com/mudslinger.html'
    link = flyer_link_from_app_server(external_event)
    assert_equal('<a href="http://my.yahoo.com/mudslinger.html">Mudslinger</a>', link, 'Link to flyer')
    
    obra_event = Event.new
    obra_event.name = 'Rehearsal Road Race'
    obra_event.flyer = '../../flyers/2006/rehearsal.html'
    link = flyer_link_from_app_server(obra_event)
    assert_equal('<a href="http://STATIC_HOST/flyers/2006/rehearsal.html">Rehearsal Road Race</a>', link, 'Link to flyer')
  end
end
