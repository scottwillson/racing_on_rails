module Competitions
  module OregonJuniorCyclocrossSeries
    class Team < Competition
      def friendly_name
        "Oregon Junior Cyclocross Team Series"
      end

      def create_slug
        "ojcs_team"
      end
    end
  end
end
