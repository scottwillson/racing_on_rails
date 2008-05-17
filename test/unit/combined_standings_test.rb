require File.dirname(__FILE__) + '/../test_helper'

class CombinedStandingsTest < ActiveSupport::TestCase
  def test_time_trial_ironman
    CombinedMountainBikeStandings.reset
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
    CombinedMountainBikeStandings.reset
    event = SingleDayEvent.create!(:discipline => "Mountain Bike")
    standings = event.standings.create!(:bar_points => 3)

    pro_men = Category.find_or_create_by_name('Pro Men')
    pro_men_race = standings.races.create!(:category => pro_men)
    pro_men_race.results.create!(:place => '4', :racer => racers(:weaver), :time => 1200)
    # Results with no time should not be included
    pro_men_race.results.create!(:place => '3', :racer => racers(:molly))
    
    # Trigger CombinedStandings logic
    standings.save!

    combined_standings = standings.combined_standings(true)
    assert_not_nil(combined_standings, 'MTB standings should have combined standings')
    assert(standings.ironman, 'MTB standings should get ironman points')
    assert(!combined_standings.ironman, 'MTB standings combined standings should not get ironman points')
    assert_equal(2, combined_standings.races.size, 'Combined standings races')

    men_combined_race = combined_standings.races(true).detect {|race| race.category == Category.find_by_name("Pro, Semi-Pro Men")}
    assert_not_nil(men_combined_race, 'men_combined_race')
    assert_equal(1, men_combined_race.results(true).size, 'Combined standings men race results')
    assert_equal(racers(:weaver), men_combined_race.results.first.racer, 'Combined standings men race results racer')

    other_combined_race = combined_standings.races.detect {|race| race.category != combined_standings.men_combined}
    assert_not_nil(other_combined_race, 'other_combined_race')
    assert_equal(0, other_combined_race.results.size, 'Combined standings other race results')

    assert_equal(3, combined_standings.bar_points, 'Combined standings BAR points should match parent')
  end
  
  def test_should_ignore_tt_results_with_no_time
    CombinedMountainBikeStandings.reset
    jack_frost = standings(:jack_frost)
    jack_frost.bar_points = 3
    jack_frost.save!
    
    assert_equal("Time Trial", jack_frost.discipline, "Jack Frost discipline")
    pro_men = Category.find_or_create_by_name('Pro Men')
    pro_men_race = jack_frost.races.create!(:category => pro_men)
    pro_men_race.results.create!(:place => '4', :racer => racers(:weaver), :time => 1200)
    # Results with no time should not be included
    pro_men_race.results.create!(:place => '3', :racer => racers(:molly))
    
    # Trigger CombinedStandings logic
    jack_frost.save!

    combined_standings = jack_frost.combined_standings(true)
    assert_not_nil(combined_standings, 'Jack Frost should have combined standings')
    combined_standings.reload
    assert_equal(1, combined_standings.races.size, 'Combined standings races')
    men_combined_race = combined_standings.races.first
    assert_not_nil(men_combined_race, 'men_combined_race')
    assert_equal(4, men_combined_race.results.size, 'Combined standings men race results')
    assert_equal(0, combined_standings.bar_points, 'Combined TT standings should have no BAR points')
  end
end