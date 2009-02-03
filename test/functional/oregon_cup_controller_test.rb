require File.dirname(__FILE__) + '/../test_helper'

class OregonCupControllerTest < ActionController::TestCase
  include OregonCupHelper

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
    assert_equal("<a href=\"http://#{STATIC_HOST}/flyers/2006/rehearsal.html\">Rehearsal Road Race</a>", link, 'Link to flyer')
  end
end
