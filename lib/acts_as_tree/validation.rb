module ActsAsTree
  module Validation
    extend ActiveSupport::Concern

    included do
      validate :valid_parent
    end

    def valid_parent
      if parent == self
        errors.add :parent, "can't be own parent"
        return false
      end

      true
    end
  end
end
