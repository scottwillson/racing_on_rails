require File.dirname(__FILE__) + '/../test_helper'

class CombinedStandingsTest < Test::Unit::TestCase
  def test_time_trial_ironman
    jack_frost = standings(:jack_frost)
    jack_frost.discipline = 'Time Trial'
    jack_frost.bar_points = 2
    jack_frost.save!
    combined_standings = jack_frost.combined_standings
    assert_not_nil(combined_standings, 'Jack Frost should have combined standings')
    assert(jack_frost.ironman, 'Jack Frost should get ironman points')
    assert(!combined_standings.ironman, 'Jack Frost combined standings should not get ironman points')
    assert_equal(0, combined_standings.bar_points, 'Combined standings BAR points should be zero if time trial')
  end

  def test_mtb
    jack_frost = standings(:jack_frost)
    jack_frost.discipline = 'Mountain Bike'
    jack_frost.bar_points = 3
    pro_men = Category.find_or_create_by_name('Pro Men')
    pro_men_race = jack_frost.races.create(:category => pro_men)
    pro_men_race.results.create(:place => '4', :racer => racers(:weaver))
    jack_frost.save!
    combined_standings = jack_frost.combined_standings
    assert_not_nil(combined_standings, 'Jack Frost should have combined standings')
    combined_standings.reload
    assert(jack_frost.ironman, 'Jack Frost should get ironman points')
    assert(!combined_standings.ironman, 'Jack Frost combined standings should not get ironman points')
    assert_equal(2, combined_standings.races.size, 'Combined standings races')
    men_combined_race = combined_standings.races.detect {|race| race.category == combined_standings.men_combined}
    assert_not_nil(men_combined_race, 'men_combined_race')
    assert_equal(1, men_combined_race.results.size, 'Combined standings men race results')
    assert_equal(3, combined_standings.bar_points, 'Combined standings BAR points should match parent')
  end
end