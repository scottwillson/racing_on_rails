require File.expand_path("../../test_helper", __FILE__)

# Check we can call these methods with errors.
# Actual values are going to differ between sites.
class RacingAssociationTest < ActiveSupport::TestCase
 def test_show_events_velodrome
   ASSOCIATION.show_events_velodrome?
 end
 
  def test_competitions
    default_competitions = ASSOCIATION.competitions
    ASSOCIATION.competitions.clear
    ASSOCIATION.competitions << :ironman
    ASSOCIATION.competitions << :ironman
    begin
      assert(ASSOCIATION.competitions.include?(:ironman), "Racing association competitions should include Ironman")
      assert(!ASSOCIATION.competitions.include?(:bar), "Racing association competitions should not include Bar")
      assert_equal(1, ASSOCIATION.competitions.size, "Should only include one instance of Ironman competition")
    ensure
      ASSOCIATION.competitions = default_competitions
    end
  end
  
  def test_now
    assert Time.now + 10 >= ASSOCIATION.now, "Default ASSOCIATION.now should be close to Time.now"

    ASSOCIATION.now = Time.local(2020, 4, 5, 23, 50, 55)
    assert_equal Time.local(2020, 4, 5, 23, 50, 55), ASSOCIATION.now, "Can override ASSOCIATION.now"

    ASSOCIATION.now = nil
    assert Time.now + 10 >= ASSOCIATION.now, "Default ASSOCIATION.now should be close to Time.now after set to nil"
  end
  
  def test_today
    assert_equal_dates Date.today, ASSOCIATION.today, "Default ASSOCIATION.today"

    ASSOCIATION.now = Time.local(2020, 4, 5, 23, 50, 55)
    assert_equal_dates Date.new(2020, 4, 5), ASSOCIATION.today, "Override ASSOCIATION.now to change ASSOCIATION.today"

    ASSOCIATION.now = nil
    assert_equal_dates Date.today, ASSOCIATION.today, "Default ASSOCIATION.today should be Date.today after ASSOCIATION.now is set to nil"
  end
  
  def test_effective_year
    ASSOCIATION.now = Time.local(2020, 1, 1)
    assert_equal 2020, ASSOCIATION.effective_year, "effective year for January 2020"

    ASSOCIATION.now = Time.local(2020, 11, 30)
    assert_equal 2020, ASSOCIATION.effective_year, "effective year for November 2020"

    ASSOCIATION.now = Time.local(2020, 12, 1)
    assert_equal 2021, ASSOCIATION.effective_year, "effective year for December 2020"

    ASSOCIATION.now = Time.local(2020, 12, 31)
    assert_equal 2021, ASSOCIATION.effective_year, "effective year for December 2020"
  end
  
  def test_next_year
    ASSOCIATION.now = Time.local(2020, 1, 1)
    assert_equal 2021, ASSOCIATION.next_year, "next_year for January 2020"

    ASSOCIATION.now = Time.local(2020, 11, 30)
    assert_equal 2021, ASSOCIATION.next_year, "next_year for November 2020"

    ASSOCIATION.now = Time.local(2020, 12, 1)
    assert_equal 2021, ASSOCIATION.next_year, "next_year for December 2020"

    ASSOCIATION.now = Time.local(2020, 12, 31)
    assert_equal 2021, ASSOCIATION.next_year, "next_year for December 2020"
  end
end
