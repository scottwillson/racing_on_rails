# frozen_string_literal: true

module Calculations::V3
  REJECTION_REASONS = %w[
    below_minimum_events
    calculated
    discipline
    dnf
    not_calculation_category
    rejected_category
    weekday
    worse_result
  ].freeze
end
