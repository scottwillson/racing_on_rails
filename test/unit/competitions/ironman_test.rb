require File.expand_path("../../../test_helper", __FILE__)

# :stopdoc:
class IronmanTest < ActiveSupport::TestCase
  def test_calculate
    original_results_count = Result.count
    assert_equal(0, Ironman.count, "Ironman events before calculate!")
    Ironman.calculate!(2004)
    ironman = Ironman.first(:conditions => ['date = ?', Date.new(2004, 1, 1)])
    assert_not_nil(ironman, "2004 Ironman after calculate!")
    assert_equal(1, Ironman.count, "Ironman events after calculate!")
    assert_equal(original_results_count + 5, Result.count, "Total count of results in DB")
    # Should delete old Ironman
    Ironman.calculate!(2004)
    assert_equal(1, Ironman.count, "Ironman events after successive calculate!")
    ironman = Ironman.first(:conditions => ['date = ?', Date.new(2004, 1, 1)])
    assert_not_nil(ironman, "2004 Ironman after calculate!")
    assert_equal(Date.new(2004, 1, 1), ironman.date, "2004 Ironman date")
    assert_equal("2004 Ironman", ironman.name, "2004 Ironman name")
    assert_equal_dates(Date.today, ironman.updated_at, "Ironman last updated")
    assert_equal(original_results_count + 5, Result.count, "Total count of results in DB")
    
    results = ironman.races.first.results.sort
    assert_equal("1", results[0].place, 'place')
    assert_equal(people(:molly), results[0].person, 'person')

    assert_equal(2, results[0].points, 'points')
    for index in 1..4
      assert_equal('2', results[index].place, "place #{index + 1}")
    end
  end
  
  def test_count_single_day_events
    person = people(:tonkin)
    series = Series.create!
    series.races.create!(:category => categories(:senior_men)).results.create(:place => "1", :person => person)

    Ironman.calculate!
    
    ironman = Ironman.find_for_year
    assert_equal(0, ironman.races.first.results.count, "Should have no Ironman result for a Series result")
    
    event = series.children.create!
    event.races.create!(:category => categories(:senior_men)).results.create(:place => "1", :person => person)

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
    person = people(:tonkin)
    event = SingleDayEvent.create!
    child = event.children.create!
    child.races.create!(:category => categories(:senior_men)).results.create(:place => "1", :person => person)
    assert(child.ironman?, "Child event should count towards Ironman")

    Ironman.calculate!

    ironman = Ironman.find_for_year
    assert_equal(1, ironman.races.first.results.count, "Should have one Ironman result for a child Event result")
    assert_equal(1, ironman.races.first.results.first.scores.count, "Should have one Ironman score for a child Event result")
  end
  
  def test_parent_event_results_do_not_count
    person = people(:tonkin)
    series = Series.create!
    series.races.create!(:category => categories(:senior_men)).results.create(:place => "1", :person => person)

    # Only way to exclude these results is to manually set ironman? to false
    event = series.children.create!(:ironman => false)
    event.races.create!(:category => categories(:senior_men)).results.create(:place => "1", :person => person)

    child = event.children.create!
    child.races.create!(:category => categories(:senior_men)).results.create(:place => "1", :person => person)

    Ironman.calculate!

    ironman = Ironman.find_for_year
    assert_equal(1, ironman.races.first.results.count, "Should have one Ironman result for a child Event result, but no others")
    assert_equal(1, ironman.races.first.results.first.scores.count, "Should have one Ironman score for a child Event result, but no others")
  end
end
