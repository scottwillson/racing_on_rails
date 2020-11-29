# frozen_string_literal: true

module Teams
  module Membership
    extend ActiveSupport::Concern

    included do
      validates :member_from, presence: true, if: proc { |team| team.member_to }
      validate :member_from_before_member_to
      scope :member, lambda {
        where("member_to >= ?", RacingAssociation.current.effective_year)
          .where("(member_from is null || member_from <= ?)", RacingAssociation.current.effective_year)
      }
    end

    def member
      member?
    end

    def member?
      member_to.present? &&
        member_to >= RacingAssociation.current.effective_year &&
        (member_from.nil? || member_from <= RacingAssociation.current.effective_year)
    end

    def member=(value)
      if value
        self.member_from = RacingAssociation.current.effective_year
        self.member_to = RacingAssociation.current.effective_year
      else
        if member_from && member_from >= RacingAssociation.current.effective_year
          self.member_from = nil
        end

        if member_to && member_to >= RacingAssociation.current.effective_year
          if member_from.nil? || member_from == RacingAssociation.current.effective_year
            self.member_to = nil
          elsif member_from < RacingAssociation.current.effective_year
            self.member_to = RacingAssociation.current.effective_year - 1
          end
        end
      end
    end

    def member_from_before_member_to
      if member_from && member_to && member_from > member_to
        errors.add :member_from, "must be before member_to"
      end
    end
  end
end
