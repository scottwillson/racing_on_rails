module Competitions
  module Calculations
    module Calculator
      def self.default_rules
        {
          break_ties:               false,
          dnf:                      false,
          field_size_bonus:         false,
          maximum_events:           UNLIMITED,
          members_only:             true,
          point_schedule:           nil,
          results_per_event:        UNLIMITED,
          results_per_race:         1,
          source_event_ids:         nil,
          team:                     false,
          use_source_result_points: false
        }
      end

      def self.default_rules_merge(rules)
        assert_valid_rules rules
        default_rules.merge(
          rules.reject { |key, value| value == nil }
        )
      end

      def self.assert_valid_rules(rules)
        return true if !rules || rules.size == 0

        invalid_rules = rules.keys - default_rules.keys
        if invalid_rules.size > 0
          raise ArgumentError, "Invalid rules: #{invalid_rules.map(", ")}. Valid: #{valid_rules}."
        end
      end
    end
  end
end
