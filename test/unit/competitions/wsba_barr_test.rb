require 'test_helper'

class Competitions::WsbaBarrTest < ActiveSupport::TestCase

  def test_create
    assert_nil(WsbaBarr.find(:first, :conditions => ['date = ?', Date.new(2006)]), 'Should have no Wsba Barr for 2006')
    wsba = WsbaBarr.create!(:date => Date.new(2006))
    assert(wsba.errors.empty?, "New WSBA BARR should have no errors, but has: #{wsba.errors.full_messages}")
    assert_equal(12, wsba.races.size, 'races')
    wsba.races.sort_by {|s| s.name }

    men_1_2 = wsba.races.first
    assert_equal('Men Cat 1-2', men_1_2.category.name, 'Senior men category')
    assert(men_1_2.results.empty?, 'Senior men results.empty?')

    women_cat_4 = wsba.races.last
    assert_equal('Women Cat 4', women_cat_4.category.name, 'Senior women category')
    assert(women_cat_4.results.empty?, 'Senior women results.empty?')
  end
  
  def test_events
    wsba = WsbaBarr.create!(:date => Date.new(2006))
    assert_equal(0, wsba.source_events.count, 'Events for new WSBA BARR')
    
    wsba.source_events << events(:banana_belt_1)
    assert_equal(1, wsba.source_events.count, 'Events for new WSBA BARR')
    wsba.source_events << events(:kings_valley)
    assert_equal(2, wsba.source_events.count, 'Events for new WSBA BARR')
  end
  
  
end
