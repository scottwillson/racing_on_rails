# frozen_string_literal: true

module Calculations::V3
  REJECTION_REASONS = %w[
    below_minimum_events
    calculated
    category_worst_result
    discipline
    dnf
    members_only
    no_source_results
    not_calculation_category
    sanctioned_by
    rejected_category
    results_per_event
    weekday
    worse_result
  ].freeze
end
