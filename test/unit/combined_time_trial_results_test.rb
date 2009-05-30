require "test_helper"

class CombinedTimeTrialResultsTest < ActiveSupport::TestCase
  def test_create
    combined_results = CombinedTimeTrialResults.create!(:parent => events(:jack_frost_2002))
    assert_equal(false, combined_results.notification?, "CombinedTimeTrialResults should not send notification updates")
  end

  def test_combined_tt
    jack_frost = events(:jack_frost_2002)
    assert_equal(0, jack_frost.children.size, 'children.size')
    assert_equal(2, jack_frost.races.size, 'races')
    assert_equal(3, jack_frost.races.first.results.size + jack_frost.races.last.results.size, 'total number of results')
    
    jack_frost.save
    
    combined_results = jack_frost.combined_results(true)
    assert_equal(false, combined_results.ironman, 'Ironman')
    
    assert_equal('Combined', combined_results.name, 'name')
    assert_equal(0, combined_results.bar_points, 'bar points')
    assert_equal(1, combined_results.races.size, 'combined_results.races')
    combined = combined_results.races.first
    assert_equal(3, combined.results.size, 'combined.results')
    combined.results.sort!

    result = combined.results[0]
    assert_equal('1', result.place, 'place')
    assert_equal(racers(:molly), result.racer, 'racer')
    assert_equal(categories(:masters_35_plus_women), result.category, 'category')
    assert_equal('30:00.00', result.time_s, 'time_s')

    result = combined.results[1]
    assert_equal('2', result.place, 'place')
    assert_equal(racers(:weaver), result.racer, 'racer')
    assert_equal(categories(:sr_p_1_2), result.category, 'category')
    assert_equal('30:01.00', result.time_s, 'time_s')

    result = combined.results[2]
    assert_equal('3', result.place, 'place')
    assert_equal(racers(:alice), result.racer, 'racer')
    assert_equal(categories(:masters_35_plus_women), result.category, 'category')
    assert_equal('35:12.00', result.time_s, 'time_s')
  end

  def test_time_trial_ironman
    assert_equal(0, CombinedTimeTrialResults.count, "CombinedTimeTrialResults in DB")
    jack_frost = events(:jack_frost_2002)
    jack_frost.discipline = "Time Trial"
    jack_frost.bar_points = 2
    jack_frost.save!
    combined_results = jack_frost.combined_results
    assert_not_nil(combined_results, 'Jack Frost should have combined results')
    assert(jack_frost.ironman, 'Jack Frost should get ironman points')
    assert(!combined_results.ironman, 'Jack Frost combined results should not get ironman points')
    assert_equal(0, combined_results.bar_points, 'Combined results BAR points should be zero if time trial')
    assert_equal(1, CombinedTimeTrialResults.count, "CombinedTimeTrialResults in DB")
  end

  def test_should_ignore_tt_results_with_no_time
    jack_frost = events(:jack_frost_2002)
    jack_frost.bar_points = 3
    jack_frost.save!
    
    assert(CombinedTimeTrialResults.requires_combined_results?(jack_frost), "Requires combined results?")

    assert_equal("Time Trial", jack_frost.discipline, "Jack Frost discipline")
    pro_men = Category.find_or_create_by_name('Pro Men')
    pro_men_race = jack_frost.races.create!(:category => pro_men)
    pro_men_race.results.create!(:place => '4', :racer => racers(:weaver), :time => 1200)
    # Results with no time should not be included
    pro_men_race.results.create!(:place => '3', :racer => racers(:molly))
    # Results with DNF should not be included
    pro_men_race.results.create!(:place => "DNF", :racer => racers(:alice))
    pro_men_race.results.create!(:place => "DNF", :racer => racers(:alice), :time => 0)
    pro_men_race.results.create!(:place => "DQ", :racer => Racer.create!, :time => 12)

    combined_results = jack_frost.combined_results(true)
    assert_not_nil(combined_results, 'Jack Frost should have combined results')
    combined_results.reload
    assert_equal(1, combined_results.races.size, 'Combined results races')
    men_combined_race = combined_results.races.first
    assert_equal(4, men_combined_race.results.size, 'Combined results men race results')
    assert_equal(0, combined_results.bar_points, 'Combined TT results should have no BAR points')
  end

  def test_honor_auto_combined_results
    event = SingleDayEvent.create!(:discipline => "Time Trial")

    pro_men = Category.find_or_create_by_name('Pro Men')
    pro_men_race = event.races.create!(:category => pro_men, :distance => 40, :laps => 2)
    pro_men_1st_place = pro_men_race.results.create!(:place => 1, :time => 300, :racer => Racer.create!(:name => "pro_men_1st_place"))

    assert(!event.combined_results(true).nil?, "TT event should have combined results")
    event.reload
    assert(CombinedTimeTrialResults.requires_combined_results?(event), "requires_combined_results?")
    assert(!CombinedTimeTrialResults.destroy_combined_results?(event), "destroy_combined_results?")
    assert_equal(true, event.notification?, "Event notification should be enabled")
    
    event.auto_combined_results = false
    assert(CombinedTimeTrialResults.destroy_combined_results?(event), "destroy_combined_results?")
    event.save!
    assert(CombinedTimeTrialResults.destroy_combined_results?(event), "destroy_combined_results?")

    event.reload
    assert_equal(true, event.notification?, "Event notification should be enabled")
    assert(!event.auto_combined_results, "auto_combined_results")
    assert(event.combined_results(true).nil?, "TT event should not have combined results")

    event.auto_combined_results = true
    event.save!

    event.reload
    assert_equal(true, event.notification?, "Event notification should be enabled")
    assert(event.auto_combined_results, "auto_combined_results")
    assert(!event.combined_results(true).nil?, "TT event should have combined results")
  end

  def test_requires_combined_results_for_children
    event = SingleDayEvent.create!(:discipline => "Time Trial")
    event.reload
    assert_equal(true, event.notification?, "event notification?")
    ten_mile = event.children.create!(:name => "10 mile")
    twenty_mile = event.children.create!(:name => "20 mile")
    
    ten_mile.reload
    assert_equal("Time Trial", ten_mile.discipline, "10 mile child event discipline")
    assert_equal(true, ten_mile.notification?, "10 mile child event notification?")
    twenty_mile.reload
    assert_equal("Time Trial", twenty_mile.discipline, "20 mile child event discipline")
    assert_equal(true, twenty_mile.notification?, "20 mile child event notification?")

    ten_mile.races.create!(:category => categories(:senior_men)).results.create!(:time => 1000, :place => "1")
    twenty_mile.races.create!(:category => categories(:men_4_5)).results.create!(:time => 1000, :place => "1")

    assert_equal("Time Trial", ten_mile.discipline, "10 mile child event discipline")
    assert(ten_mile.auto_combined_results?, "ten_mile auto_combined_results?")
    assert(ten_mile.has_results?(true), "ten_mile has_results?")
    assert(CombinedTimeTrialResults.requires_combined_results?(ten_mile), "10 mile requires_combined_results?")
    assert(CombinedTimeTrialResults.requires_combined_results?(twenty_mile), "20 mile requires_combined_results?")

    assert_not_nil(ten_mile.combined_results(true), "10 mile should have combined_results")
    assert_not_nil(twenty_mile.combined_results(true), "20 mile should have combined_results")
    assert_nil(event.combined_results(true), "Parent event should not have combined_results")

    assert_equal("Combined", ten_mile.combined_results.name, "10 mile combined results")
    assert_equal("Combined", twenty_mile.combined_results.name, "20 mile combined results")
  end
  
  def test_destroy
    series = Series.create!(:discipline => "Time Trial")
    series.races.create!(:category => categories(:senior_men)).results.create!(:time => 1000, :place => "1")
    
    event = series.children.create!
    event.races.create!(:category => categories(:senior_men)).results.create!(:time => 500, :place => "1")
    
    assert_not_nil(series.combined_results(true), "Series parent should have combined results")
    assert_not_nil(event.combined_results(true), "Series child event parent should have combined results")
    
    series.reload
    event.reload
    event.destroy_races
    event.combined_results.destroy_races
    event.combined_results.destroy
    assert_nil(event.combined_results(true), "Series child event parent should not have combined results")
  end
end
