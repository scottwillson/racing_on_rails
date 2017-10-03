module Competitions
  module GrandPrixBradRoss
    class Overall < Competitions::Overall
      include GrandPrixBradRoss::Common

      before_create :set_name

      def minimum_events
        5
      end

      def maximum_events(race)
        6
      end

      def upgrade_points_multiplier
        0.25
      end

      def set_name
        self.name = "Series Overall"
      end
    end
  end
end
