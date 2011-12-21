module Concerns
  module Bar
    module Points
      extend ActiveSupport::Concern

      def point_schedule
        @point_schedule ||= [ 0, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ]
      end

      # Apply points from point_schedule, and adjust for field size
      def points_for(source_result, team_size = nil)
        points = 0
        team_size ||= source_result.team_size
        points = (point_schedule[source_result.place.to_i] || 0) * source_result.race.bar_points / team_size.to_f
        if source_result.race.bar_points == 1 && source_result.race.field_size >= 75
          points = points * 1.5
        end
        points
      end
    end
  end
end
