module Calculations::V3::Rejection
  extend ActiveSupport::Concern

  included do
    validate :reason_if_rejected
    validates :rejected, inclusion: [true, false]
    validates :rejection_reason, inclusion: { in: ::Calculations::V3::REJECTION_REASONS, allow_blank: true }
  end

  def reason_if_rejected
    if rejected? && rejection_reason.blank?
      errors.add(:rejection_reason, "must be present if rejected")
    elsif rejection_reason.present? && !rejected?
      errors.add(:rejected, "must be true if rejection reason")
    end
  end

  def rejection_reason=(value)
    self.rejected = value.present?
    super
  end
end
