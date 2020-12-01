# frozen_string_literal: true

module Competitions::Calculations::Rules
  def default_rules
    {
      break_ties: false,
      completed_events: nil,
      double_points_for_last_event: false,
      end_date: nil,
      dnf_points: 0,
      field_size_bonus: false,
      group_by: "category",
      maximum_events: Competitions::Calculations::Calculator::UNLIMITED,
      maximum_upgrade_points: Competitions::Calculations::Calculator::UNLIMITED,
      minimum_events: nil,
      missing_result_penalty: nil,
      members_only: true,
      most_points_win: true,
      place_bonus: [],
      point_schedule: nil,
      points_schedule_from_field_size: false,
      results_per_event: Competitions::Calculations::Calculator::UNLIMITED,
      results_per_race: 1,
      source_event_ids: nil,
      team: false,
      use_source_result_points: false,
      upgrade_points_multiplier: 0.50
    }
  end

  def default_rules_merge(rules)
    assert_valid_rules rules
    default_rules.merge(
      rules.compact
    )
  end

  def assert_valid_rules(rules)
    return true if rules.blank?

    raise_if_any_invalid rules, default_rules
    raise_if_inconsistent rules
  end

  def raise_if_any_invalid(rules, default_rules)
    invalid_rules = rules.keys - default_rules.keys
    raise ArgumentError, "Invalid rules: #{invalid_rules.join(', ')}. Valid: #{default_rules.keys}." unless invalid_rules.empty?
  end

  def raise_if_inconsistent(rules)
    if rules[:break_ties] == true && !rules[:most_points_win].nil? && rules[:most_points_win] == false
      raise ArgumentError, "Can only break ties if most points win"
    end
  end
end
