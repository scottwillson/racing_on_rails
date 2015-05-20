require "test_helper"

module Competitions
  # :stopdoc:
  class PortlandShortTrackSeriesTest < ActiveSupport::TestCase
    test "calculate" do
      PortlandShortTrackSeries::Overall.calculate!
      PortlandShortTrackSeries::MonthlyStandings.calculate!
    end
  end
end
