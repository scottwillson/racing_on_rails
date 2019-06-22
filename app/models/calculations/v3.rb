# frozen_string_literal: true

module Calculations::V3
  REJECTION_REASONS = %w[
    below_minimum_events
    calculated
    discipline
    dnf
    members_only
    not_calculation_category
    sanctioned_by
    rejected_category
    results_per_event
    weekday
    worse_result
  ].freeze
end
