require File.expand_path("../../../../test_helper", __FILE__)

module Competitions
  # :stopdoc:
  class CrossCrusadeCallupsTest < ActiveSupport::TestCase
    test "calculate" do
      result = FactoryBot.create(:result)
      series = CrossCrusadeCallups.create!
      series.source_events << result.event
      CrossCrusadeCallups.calculate!
    end
  end
end
