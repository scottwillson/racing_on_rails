require File.dirname(__FILE__) + '/../test_helper'

class CombinedStandingsTest < Test::Unit::TestCase
  def test_time_trial_ironman
    jack_frost = standings(:jack_frost)
    jack_frost.discipline = 'Time Trial'
    jack_frost.save!
    combined_standings = jack_frost.combined_standings
    assert_not_nil(combined_standings, 'Jack Frost should have combined standings')
    assert(jack_frost.ironman, 'Jack Frost should get ironman points')
    assert(!combined_standings.ironman, 'Jack Frost combined standings should not get ironman points')
  end

  def test_mtb_ironman
    jack_frost = standings(:jack_frost)
    jack_frost.discipline = 'Mountain Bike'
    jack_frost.save!
    combined_standings = jack_frost.combined_standings
    assert_not_nil(combined_standings, 'Jack Frost should have combined standings')
    assert(jack_frost.ironman, 'Jack Frost should get ironman points')
    assert(!combined_standings.ironman, 'Jack Frost combined standings should not get ironman points')
  end
end