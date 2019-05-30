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

  def ==(other)
    return false if other.nil?

    other.hash == hash
  end

  def eql?(other)
    self == other
  end

  def <=>(other)
    if rejected? && !other.rejected?
      return 1
    elsif !rejected? && other.rejected?
      return -1
    end

    if points == 0 && other.points > 0
      return 1
    elsif points > 0 && other.points == 0
      return -1
    end

    if date != other.date
      return date <=> other.date
    end

    0
  end

  delegate :date, to: :source_result
end
