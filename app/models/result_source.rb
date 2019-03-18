# frozen_string_literal: true

class ResultSource < ApplicationRecord
  REJECTION_REASONS = %w[ not_calculation_category worse_result].freeze

  belongs_to :calculated_result, class_name: "Result"
  belongs_to :source_result, class_name: "Result"

  validates :rejection_reason, inclusion: { in: REJECTION_REASONS, allow_blank: true }
end
