module Competitions
  module Calculations
    module Rules
      def default_rules
        {
          ascending_points:             true,
          break_ties:                   false,
          completed_events:             nil,
          double_points_for_last_event: false,
          end_date:                     nil,
          dnf:                          false,
          field_size_bonus:             false,
          maximum_events:               UNLIMITED,
          minimum_events:               nil,
          missing_result_penalty:       nil,
          members_only:                 true,
          point_schedule:               nil,
          results_per_event:            UNLIMITED,
          results_per_race:             1,
          source_event_ids:             nil,
          team:                         false,
          use_source_result_points:     false
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
        
        if rules[:break_ties] == true && !rules[:ascending_points].nil? && rules[:ascending_points] == false
          raise ArgumentError, "Can't combine break_ties and descending_points"
        end
      end
    end
  end
end
