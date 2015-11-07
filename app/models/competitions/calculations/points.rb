module Competitions
  module Calculations
    module Points
      def points(result, rules)
        if rules[:use_source_result_points]
          result.points

        elsif result.upgrade
          upgrade_points(result, rules)

        elsif numeric_place?(result)
          points_from_point_schedule result, rules

        elsif rules[:dnf_points] && result.place == "DNF"
          rules[:dnf_points]

        else
          0
        end
      end

      def upgrade_points(result, rules)
        [ result.points / 2.0, rules[:maximum_upgrade_points] ].min
      end

      def numeric_place?(result)
        numeric_place(result) < Float::INFINITY
      end

      def points_from_point_schedule(result, rules)
        if !point_schedule?(rules)
          return 1
        end

        if rules[:missing_result_penalty] && numeric_place(result) > rules[:missing_result_penalty]
          return rules[:missing_result_penalty]
        end

        points = points_from_place(result, rules) || 0
        bonus = place_bonus_points(result, rules)
        team_size = (result.team_size || 1.0).to_f

        ((points + bonus) / team_size) *
        multiplier(result) *
        last_event_multiplier(result, rules) *
        field_size_multiplier(result, rules)
      end

      def point_schedule?(rules)
        rules[:point_schedule] || rules[:points_schedule_from_field_size]
      end

      # Basic: this place is worth this many points
      def points_from_place(result, rules)
        if rules[:points_schedule_from_field_size]
          (result.field_size - numeric_place(result)) + 1
        else
          rules[:point_schedule][numeric_place(result) - 1]
        end
      end

      def place_bonus_points(result, rules)
        if rules[:place_bonus] && numeric_place(result) > 0 && numeric_place?(result)
          (rules[:place_bonus][numeric_place(result) - 1]) || 0
        else
          0
        end
      end

      def multiplier(result)
        (result.multiplier || 1 ).to_f
      end

      def last_event_multiplier(result, rules)
        if rules[:double_points_for_last_event] && last_event?(result, rules)
          2
        else
          1
        end
      end

      def last_event?(result, rules)
        raise(ArgumentError, "End date required to check for last event") unless rules[:end_date]
        result.date == rules[:end_date]
      end

      def field_size_multiplier(result, rules)
        field_size_bonus = rules[:field_size_bonus]
        if (result.multiplier.nil? || result.multiplier == 1) && field_size_bonus && result.field_size >= 75
          1.5
        else
          1.0
        end
      end
    end
  end
end
