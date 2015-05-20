module Competitions
  class PortlandShortTrackSeriesOverall < Overall
    include PortlandShortTrackSeries::Common

    def maximum_events(race)
      7
    end

    def after_calculate
      super
      PortlandShortTrackSeriesMonthlyStandings.calculate! year
    end
  end
end
