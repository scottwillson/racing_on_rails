require File.expand_path("../../../test_helper", __FILE__)

# :stopdoc:
class CombinedTimeTrialResultsTest < ActiveSupport::TestCase
  def test_create
    combined_results = CombinedTimeTrialResults.create!(:parent => FactoryGirl.create(:time_trial_event))
    assert_equal(false, combined_results.notification?, "CombinedTimeTrialResults should not send notification updates")
  end

  def test_combined_tt
    event = FactoryGirl.create(:time_trial_event)
    race_1 = FactoryGirl.create(:race, :event => event)
    race_2 = FactoryGirl.create(:race, :event => event)
    result_1 = FactoryGirl.create(:result, :race => race_1, :place => "1", :time => "1800")
    result_2 = FactoryGirl.create(:result, :race => race_1, :place => "2", :time => "2112")
    result_3 = FactoryGirl.create(:result, :race => race_2, :place => "9", :time => "1801")

    # Results with no time should not be included
    FactoryGirl.create(:result, :race => race_2, :place => "10")
    
    # Only include finishers
    FactoryGirl.create(:result, :race => race_1, :place => "DNF")
    FactoryGirl.create(:result, :race => race_1, :place => "DNF", :time => 0)
    FactoryGirl.create(:result, :race => race_1, :place => "DQ", :time => 12)

    event.save!    
    combined_results = event.combined_results(true)
    assert_equal(false, combined_results.ironman, 'Ironman')    
    assert_equal('Combined', combined_results.name, 'name')
    assert_equal(0, combined_results.bar_points, 'bar points')
    assert_equal(1, combined_results.races.size, 'combined_results.races')
    combined = combined_results.races.first
    assert_equal(3, combined.results.size, 'combined.results')
    combined.results.sort!

    result = combined.results[0]
    assert_equal('1', result.place, 'place')
    assert_equal(result_1.person, result.person, 'person')
    assert_equal(race_1.category, result.category, 'category')
    assert_equal('30:00.00', result.time_s, 'time_s')

    result = combined.results[1]
    assert_equal('2', result.place, 'place')
    assert_equal(result_3.person, result.person, 'person')
    assert_equal(race_2.category, result.category, 'category')
    assert_equal('30:01.00', result.time_s, 'time_s')

    result = combined.results[2]
    assert_equal('3', result.place, 'place')
    assert_equal(result_2.person, result.person, 'person')
    assert_equal(race_1.category, result.category, 'category')
    assert_equal('35:12.00', result.time_s, 'time_s')
  end

  def test_honor_auto_combined_results    
    event = FactoryGirl.create(:time_trial_event)
    race = FactoryGirl.create(:race, :event => event)
    FactoryGirl.create(:result, :race => race, :place => "1", :time => 1800)

    assert(event.combined_results(true), "TT event should have combined results")
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
    event = FactoryGirl.create(:time_trial_event)

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

    FactoryGirl.create(:result, :race => FactoryGirl.create(:race, :event => ten_mile), :place => "1", :time => 1000)
    FactoryGirl.create(:result, :race => FactoryGirl.create(:race, :event => twenty_mile), :place => "1", :time => 1000)

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
    assert_equal true, series.notification?, "event notification?"
    assert_equal true, series.notification_enabled?, "event notification_enabled?"
    FactoryGirl.create(:result, :race => FactoryGirl.create(:race, :event => series), :place => "1", :time => 1000)
    
    event = series.children.create!
    FactoryGirl.create(:result, :race => FactoryGirl.create(:race, :event => event), :place => "1", :time => 500)
    assert_equal true, event.notification?, "event notification?"
    
    assert_not_nil(series.combined_results(true), "Series parent should have combined results")
    assert_not_nil(event.combined_results(true), "Series child event parent should have combined results")
    
    series.reload
    event.reload
    assert_equal true, series.notification?, "event notification?"
    assert_equal true, series.notification?, "event notification_enabled?"
    assert_equal true, event.notification?, "event notification?"
    assert_equal true, event.notification_enabled?, "event notification_enabled?"
    event.destroy_races
    event.combined_results.destroy_races
    assert_nil(event.combined_results(true), "Series child event parent should not have combined results")
  end
  
  def test_should_not_calculate_combined_results_for_combined_results
    event = FactoryGirl.create(:time_trial_event)
    race = FactoryGirl.create(:race, :event => event)
    FactoryGirl.create(:result, :race => race, :place => "1", :time => 1800)
    
    assert_not_nil(event.combined_results(true), "TT event should have combined results")
    result_id = event.combined_results.races.first.results.first.id
    
    race.reload
    race.calculate_members_only_places!
    event.reload
    result_id_after_member_place = event.combined_results(true).races.first.results.first.id
    assert_equal(result_id, result_id_after_member_place, "calculate_members_only_places! should not trigger combined results recalc")
  end
end
