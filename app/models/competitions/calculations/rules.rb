module Competitions
  module Calculations
    module Rules
      def default_rules
        {
          break_ties:                      false,
          completed_events:                nil,
          double_points_for_last_event:    false,
          end_date:                        nil,
          dnf_points:                      0,
          field_size_bonus:                false,
          maximum_events:                  UNLIMITED,
          maximum_upgrade_points:          UNLIMITED,
          minimum_events:                  nil,
          missing_result_penalty:          nil,
          members_only:                    true,
          most_points_win:                 true,
          place_bonus:                     [],
          point_schedule:                  nil,
          points_schedule_from_field_size: false,
          results_per_event:               UNLIMITED,
          results_per_race:                1,
          source_event_ids:                nil,
          team:                            false,
          use_source_result_points:        false
        }
      end

      def default_rules_merge(rules)
        assert_valid_rules rules
        default_rules.merge(
          rules.reject { |key, value| value == nil }
        )
      end

      def assert_valid_rules(rules)
        return true if !rules || rules.size == 0

        invalid_rules = rules.keys - default_rules.keys
        if invalid_rules.size > 0
          raise ArgumentError, "Invalid rules: #{invalid_rules.join(", ")}. Valid: #{default_rules.keys}."
        end

        if rules[:break_ties] == true && !rules[:most_points_win].nil? && rules[:most_points_win] == false
          raise ArgumentError, "Can only break ties if most points win"
        end
      end
    end
  end
end
