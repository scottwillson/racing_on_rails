module Concerns
  module Competition
    module Points
      extend ActiveSupport::Concern

      module InstanceMethods
        def point_schedule
          @point_schedule ||= []
        end
        
        def point_schedule=(value)
          @point_schedule = value
        end
        
        # Apply points from point_schedule, and split across team
        def points_for(source_result, team_size = nil)
          points = 0
          
          if place_members_only?
            points = point_schedule[source_result.members_only_place.to_i].to_f || 0
          else
            points = point_schedule[source_result.place.to_i].to_f || 0
          end

          if points > 0
            factor = 1
            if consider_points_factor?
              factor = points_factor(source_result)
            end

            if consider_team_size?
              team_size = team_size || team_size_from_result(source_result)
              points = points * factor / team_size.to_f
            else
              points = points * factor
            end
            
            if double_points_for_last_event? && source_result.last_event?
              points = points * 2
            end
          end
          
          points
        end

        # multiplier from the CompetitionEventsMembership if it exists
        # FIXME inefficient
        def points_factor(source_result)
          cem = source_result.event.competition_event_memberships.detect{|comp| comp.competition_id == self.id}
          # factor is one if membership is not found
          cem ? cem.points_factor : 1
        end

        def team_size_from_result(source_result)
          ::Result.count(:conditions => ["race_id =? and place = ?", source_result.race_id, source_result.place])
        end

        def ascending_points?
          true
        end

        def consider_team_size?
          true
        end

        def consider_points_factor?
          true
        end
        
        def double_points_for_last_event?
          false
        end

        def default_bar_points
          0
        end

        # Use the recorded place with all finishers? Or only place with just Assoication member finishers?
        def place_members_only?
          false
        end

        # Only members can score points?
        def members_only?
          true
        end

        # Member this +date+ year?
        def member?(person_or_team, date)
          person_or_team && person_or_team.member_in_year?(date)
        end
      end
    end
  end
end
