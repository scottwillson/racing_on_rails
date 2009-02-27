require File.dirname(__FILE__) + '/../test_helper'

class CombinedStandingsTest < ActiveSupport::TestCase
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
  
  def test_should_ignore_tt_results_with_no_time
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

  def test_should_replace_existing_standings
    event = SingleDayEvent.create!(:discipline => "Time Trial")
    standings = event.standings.create!
    
    pro_men = Category.find_or_create_by_name('Pro Men')
    pro_men_race = standings.races.create!(:category => pro_men, :distance => 40, :laps => 2)
    pro_men_1st_place = pro_men_race.results.create!(:place => 1, :time => 300, 
      :racer => Racer.create!(:name => "pro_men_1st_place"))

    combined_standings = standings.combined_standings(true)
    assert_not_nil(combined_standings, 'TT standings should have combined standings')
    
    standings.auto_combined_standings = false
    standings.save!
    
    combined_standings = standings.combined_standings(true)
    assert_nil(combined_standings, 'TT standings should not have combined standings')
    
    standings.auto_combined_standings = true
    standings.save!

    combined_standings = standings.combined_standings(true)
    assert_not_nil(combined_standings, 'TT standings should have combined standings')
  end
end