require "test_helper"

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
end
