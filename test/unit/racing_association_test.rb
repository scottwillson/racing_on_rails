require "test_helper"

# Check we can call these methods with errors.
# Actual values are going to differ between sites.
class RacingAssociationTest < ActiveSupport::TestCase
 def test_show_events_velodrome
   ASSOCIATION.show_events_velodrome?
 end
end