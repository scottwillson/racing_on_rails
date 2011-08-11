require File.expand_path("../../../test_helper", __FILE__)

# :stopdoc:
class WsbaBarrTest < ActiveSupport::TestCase
  def test_calculate
    assert_nil(WsbaBarr.find_for_year(2006), 'Should have no Wsba Barr for 2006')
    WsbaBarr.calculate!(2006)
    wsba = WsbaBarr.find_for_year(2006)
    assert(wsba.errors.empty?, "New WSBA BARR should have no errors, but has: #{wsba.errors.full_messages}")
    assert_equal(13, wsba.races.size, 'races')
    wsba.races.sort_by {|s| s.name }

    men_1_2 = wsba.races.first
    assert_equal('Men Cat 1-2', men_1_2.category.name, 'Senior men category')
    assert(men_1_2.results.empty?, 'Senior men results.empty?')

    women_cat_4 = wsba.races.last
    assert_equal("Master Women 35+ Cat 4", women_cat_4.category.name, "Master Women 35+ Cat 4")
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
  
  def test_points
    wsba = WsbaBarr.create!(:date => Date.new(2004))

    banana_belt = events(:banana_belt_1)
    category_men_1_2 = Category.find_or_create_by_name("Men Cat 1-2")
    sr_men = Category.find_by_name("Senior Men Pro 1/2")
    sr_men_race = banana_belt.races.detect { |race| race.category == sr_men }
    # Set Race Category to a WSBA BARR-recognized Category. Could have mapped it instead.
    sr_men_race.category = category_men_1_2
    sr_men_race.save!
    wsba.source_events << banana_belt 
    banana_belt.set_points_for(wsba, 1.5)

    # Default to 1 point
    kings_valley = events(:kings_valley_2004)
    sr_men_race = kings_valley.races.detect { |race| race.category == sr_men }
    sr_men_race.category = category_men_1_2
    sr_men_race.save!
    wsba.source_events << kings_valley    
    result = sr_men_race.results.create!(:place => "10", :person => people(:tonkin))
    result.place = 10
    result.save!
    fill_in_missing_results
    WsbaBarr.calculate!(2004)

    wsba = WsbaBarr.find_for_year(2004)

    men_1_2 = wsba.races.detect { |race| race.category == category_men_1_2 }
    assert_not_nil(men_1_2, "Should have Men Cat 1-2 race")
    assert_equal(3, men_1_2.results.count, "Senior men results")
    
    men_1_2.results.sort!
    assert_equal(37, men_1_2.results[0].points, "Result 0 points")
    assert_equal(25.5, men_1_2.results[1].points, "Result 1 points")
    assert_equal(22.5, men_1_2.results[2].points, "Result 2 points")
  end
end
