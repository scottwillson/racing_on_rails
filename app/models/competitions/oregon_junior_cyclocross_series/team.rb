module Competitions
  module OregonJuniorCyclocrossSeries
    class Team < Competition
      def friendly_name
        "Oregon Junior Cyclocross Team Series"
      end

      def create_slug
        "ojcs_team"
      end

      def event_teams?
        true
      end

      def source_events?
        true
      end
    end
  end
end
