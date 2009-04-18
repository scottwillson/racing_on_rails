require "test_helper"

class CombinedTimeTrialResultsTest < ActiveSupport::TestCase
  def test_create
    CombinedTimeTrialResults.create!(:parent => events(:jack_frost_2002))
  end
  
  def test_time_trial_ironman
    jack_frost = events(:jack_frost_2002)
    jack_frost.discipline = 'Time Trial'
    jack_frost.bar_points = 2
    jack_frost.save!
    combined_results = jack_frost.combined_results
    assert_not_nil(combined_results, 'Jack Frost should have combined results')
    assert(jack_frost.ironman, 'Jack Frost should get ironman points')
    assert(!combined_results.ironman, 'Jack Frost combined results should not get ironman points')
    assert_equal(0, combined_results.bar_points, 'Combined results BAR points should be zero if time trial')
  end
  
  def test_should_ignore_tt_results_with_no_time
    jack_frost = events(:jack_frost_2002)
    jack_frost.bar_points = 3
    jack_frost.save!

    assert_equal("Time Trial", jack_frost.discipline, "Jack Frost discipline")
    pro_men = Category.find_or_create_by_name('Pro Men')
    pro_men_race = jack_frost.races.create!(:category => pro_men)
    pro_men_race.results.create!(:place => '4', :racer => racers(:weaver), :time => 1200)
    # Results with no time should not be included
    pro_men_race.results.create!(:place => '3', :racer => racers(:molly))

    # Trigger CombinedResults logic
    jack_frost.save!

    combined_results = jack_frost.combined_results(true)
    assert_not_nil(combined_results, 'Jack Frost should have combined results')
    combined_results.reload
    assert_equal(1, combined_results.races.size, 'Combined results races')
    men_combined_race = combined_results.races.first
    assert_equal(4, men_combined_race.results.size, 'Combined results men race results')
    assert_equal(0, combined_results.bar_points, 'Combined TT results should have no BAR points')
  end

  def test_should_replace_existing_results
    event = SingleDayEvent.create!(:discipline => "Time Trial")
    
    pro_men = Category.find_or_create_by_name('Pro Men')
    pro_men_race = event.races.create!(:category => pro_men, :distance => 40, :laps => 2)
    pro_men_1st_place = pro_men_race.results.create!(:place => 1, :time => 300, :racer => Racer.create!(:name => "pro_men_1st_place"))

    combined_results = event.combined_results(true)
    assert_not_nil(combined_results, 'TT results should have combined results')
    
    event.auto_combined_results = false
    event.save!
    
    combined_results = event.combined_results(true)
    assert_nil(combined_results, 'TT event should not have combined results')
    
    event.auto_combined_results = true
    event.save!

    combined_results = event.combined_results(true)
    assert_not_nil(combined_results, 'TT event should have combined results')
  end
end
