require File.expand_path("../../../../test_helper", __FILE__)

# :stopdoc:
class IronmanTest < ActiveSupport::TestCase
  def test_count_single_day_events
    person = FactoryGirl.create(:person)
    series = Series.create!
    senior_men = FactoryGirl.create(:category)
    series.races.create!(:category => senior_men).results.create(:place => "1", :person => person)

    Ironman.calculate!
    
    ironman = Ironman.find_for_year
    assert_equal(0, ironman.races.first.results.count, "Should have no Ironman result for a Series result")
    
    event = series.children.create!
    event.races.create!(:category => senior_men).results.create(:place => "1", :person => person)

    Ironman.calculate!
    
    ironman.reload
    assert_equal(1, ironman.races.first.results.count, "Should have one Ironman result for a SingleDayEvent result")
    assert_equal(1, ironman.races.first.results.first.scores.count, "Should have one Ironman score for a SingleDayEvent result")

    # Check that we can calculate again
    Ironman.calculate!
    
    ironman.reload
    assert_equal(1, ironman.races.first.results.count, "Should have one Ironman result for a SingleDayEvent result")
    assert_equal(1, ironman.races.first.results.first.scores.count, "Should have one Ironman score for a SingleDayEvent result")
  end
  
  def test_count_child_events
    person = FactoryGirl.create(:person)
    event = SingleDayEvent.create!
    child = event.children.create!
    senior_men = FactoryGirl.create(:category)
    child.races.create!(:category => senior_men).results.create(:place => "1", :person => person)
    assert(child.ironman?, "Child event should count towards Ironman")

    Ironman.calculate!

    ironman = Ironman.find_for_year
    assert_equal(1, ironman.races.first.results.count, "Should have one Ironman result for a child Event result")
    assert_equal(1, ironman.races.first.results.first.scores.count, "Should have one Ironman score for a child Event result")
  end
  
  def test_skip_anything_other_than_single_day_event
    person = FactoryGirl.create(:person)
    event = FactoryGirl.create(:time_trial_event)
    senior_men = FactoryGirl.create(:category)
    event.races.create!(:category => senior_men).results.create(:place => "99", :person => person)
    combined_results = CombinedTimeTrialResults.create!(:parent => event)
    assert(!combined_results.ironman?, "CombinedTimeTrialResults event should not count towards Ironman")

    Ironman.calculate!

    ironman = Ironman.find_for_year
    assert_equal(1, ironman.races.first.results.count, "Should have one Ironman result for a TT result")
    assert_equal(1, ironman.races.first.results.first.scores.count, "Should have one Ironman score for a TT result")
  end
  
  def test_parent_event_results_do_not_count
    person = FactoryGirl.create(:person)
    senior_men = FactoryGirl.create(:category)
    series = Series.create!
    series.races.create!(:category => senior_men).results.create(:place => "1", :person => person)

    # Only way to exclude these results is to manually set ironman? to false
    event = series.children.create!(:ironman => false)
    event.races.create!(:category => senior_men).results.create(:place => "1", :person => person)

    child = event.children.create!
    child.races.create!(:category => senior_men).results.create(:place => "1", :person => person)

    Ironman.calculate!

    ironman = Ironman.find_for_year
    assert_equal(1, ironman.races.first.results.count, "Should have one Ironman result for a child Event result, but no others")
    assert_equal(1, ironman.races.first.results.first.scores.count, "Should have one Ironman score for a child Event result, but no others")
  end
end
