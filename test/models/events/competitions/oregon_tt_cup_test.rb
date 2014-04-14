require File.expand_path("../../../../test_helper", __FILE__)

module Competitions
  # :stopdoc:
  class OregonTTCupTest < ActiveSupport::TestCase
    test "recalc with one event" do
      event = FactoryGirl.create(:time_trial_event)
      competition = OregonTTCup.create!
      competition.source_events << event
      OregonTTCup.calculate!
    end
  end
end
