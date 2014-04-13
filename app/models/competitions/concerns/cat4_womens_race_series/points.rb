module Concerns
  module Cat4WomensRaceSeries
    module Points
      def point_schedule
        if association_point_schedule.present?
          @point_schedule ||= association_point_schedule
        else
          @point_schedule ||= [ 0, 100, 95, 90, 85, 80, 75, 72, 70, 68, 66, 64, 62, 60, 58, 56 ]
        end
      end

      def points_for(source_result, team_size = nil)
        if participation_points?
          # If it's a finish without a number, it's always 15 points
          return 15 if source_result.place.blank?

          event_ids = source_events.collect(&:id)
          place = source_result.place.to_i

          if event_ids.include?(source_result.event_id) ||
             (source_result.event.parent_id &&
              event_ids.include?(source_result.event.parent_id) &&
              source_result.event.parent.races.none? { |race| cat_4_categories.include?(race.category) })
            if place >= point_schedule.size
              return 25
            else
              return point_schedule[source_result.place.to_i] || 0
            end
          elsif place > 0
            return 15
          end
        else
          return 0 if source_result.place.blank?
          event_ids = source_events.collect(&:id)
          place = source_result.place.to_i

          if (event_ids.include?(source_result.event_id) ||
              (source_result.event.parent_id && event_ids.include?(source_result.event.parent_id) && source_result.event.parent.races.none?)) &&
               place < point_schedule.size
            return point_schedule[source_result.place.to_i] || 0
          end
        end

        0
      end
    end
  end
end
