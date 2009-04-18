require "test_helper"

class IronmanTest < ActiveSupport::TestCase
  def test_calculate
    original_results_count = Result.count
    assert_equal(0, Ironman.count, "Ironman events before calculate!")
    Ironman.calculate!(2004)
    ironman = Ironman.find(:first, :conditions => ['date = ?', Date.new(2004, 1, 1)])
    assert_not_nil(ironman, "2004 Ironman after calculate!")
    assert_equal(1, Ironman.count, "Ironman events after calculate!")
    assert_equal(original_results_count + 5, Result.count, "Total count of results in DB")
    # Should delete old Ironman
    Ironman.calculate!(2004)
    assert_equal(1, Ironman.count, "Ironman events after successive calculate!")
    ironman = Ironman.find(:first, :conditions => ['date = ?', Date.new(2004, 1, 1)])
    assert_not_nil(ironman, "2004 Ironman after calculate!")
    assert_equal(Date.new(2004, 1, 1), ironman.date, "2004 Ironman date")
    assert_equal("2004 Ironman", ironman.name, "2004 Ironman name")
    assert_equal_dates(Date.today, ironman.updated_at, "Ironman last updated")
    assert_equal(original_results_count + 5, Result.count, "Total count of results in DB")
    
    results = ironman.races.first.results.sort
    assert_equal("1", results[0].place, 'place')
    assert_equal(racers(:molly), results[0].racer, 'racer')

    assert_equal(2, results[0].points, 'points')
    for index in 1..4
      assert_equal('2', results[index].place, "place #{index + 1}")
    end
  end
end
