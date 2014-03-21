require File.expand_path("../../../../test_helper", __FILE__)

# :stopdoc:
class OBRATTCupTest < ActiveSupport::TestCase  
  def test_recalc_with_one_event
    event = FactoryGirl.create(:time_trial_event)
    competition = OBRATTCup.create!
    competition.source_events << event
    OBRATTCup.calculate!
  end
end
