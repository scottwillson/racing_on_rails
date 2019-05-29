# frozen_string_literal: true

class ResultSource < ApplicationRecord
  belongs_to :calculated_result, class_name: "Result"
  belongs_to :source_result, class_name: "Result"

  validates :rejection_reason, inclusion: { in: ::Calculations::V3::REJECTION_REASONS, allow_blank: true }

  def rejected?
    rejection_reason.present?
  end

  def hash
    [
      points,
      source_result_id,
      rejection_reason
    ].hash
  end

  def <=>(other)
    return 0 if id.present? && (id == other&.id)

    if points == 0 && other.points > 0
      return 1
    elsif points > 0 && other.points == 0
      return -1
    end

    if rejected? && !other.rejected?
      return 1
    elsif !rejected? && other.rejected?
      return -1
    end

    date <=> other.date
  end

  delegate :date, to: :source_result
end
