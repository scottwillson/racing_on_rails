# frozen_string_literal: true

module Competitions
  module PortlandShortTrackSeries
    class Overall < Competitions::Overall
      include PortlandShortTrackSeries::Common

      def maximum_events(_race)
        7
      end

      def after_calculate
        super
        MonthlyStandings.calculate! year
      end
    end
  end
end
