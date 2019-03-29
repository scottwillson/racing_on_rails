# frozen_string_literal: true

module Calculations::V3
  REJECTION_REASONS = %w[
    below_minimum_events
    discipline
    dnf
    not_calculation_category
    rejected_category
    worse_result
  ].freeze
end
