module Sanctioned
  extend ActiveSupport::Concern

  included do
    validate :inclusion_of_sanctioned_by

    scope :default_sanctioned_by, lambda {
      where sanctioned_by: RacingAssociation.current.default_sanctioned_by
    }
  end

  def inclusion_of_sanctioned_by
    if sanctioned_by && !RacingAssociation.current.sanctioning_organizations.include?(sanctioned_by)
      errors.add :sanctioned_by, "'#{sanctioned_by}' must be in #{RacingAssociation.current.sanctioning_organizations.join(', ')}"
    end
  end
end
