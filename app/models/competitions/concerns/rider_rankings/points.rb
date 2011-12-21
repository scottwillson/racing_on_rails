module Concerns
  module RiderRankings
    module Points
      extend ActiveSupport::Concern

      def point_schedule
        @point_schedule ||= [ 0, 100, 70, 50, 40, 36, 32, 28, 24, 20, 16 ]
      end
        
      def consider_points_factor?
        false
      end
    end
  end
end
