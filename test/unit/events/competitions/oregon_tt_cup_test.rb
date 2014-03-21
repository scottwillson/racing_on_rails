require File.expand_path("../../../../test_helper", __FILE__)

# :stopdoc:
class OregonTTCupTest < ActiveSupport::TestCase  
  def test_recalc_with_one_event
    event = FactoryGirl.create(:time_trial_event)
    competition = OregonTTCup.create!
    competition.source_events << event
    OregonTTCup.calculate!
  end
end
