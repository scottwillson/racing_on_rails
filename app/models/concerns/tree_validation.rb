module Concerns
  module TreeValidation
    extend ActiveSupport::Concern
    
    included do
      validate :valid_parent
    end
  
    def valid_parent
      if parent == self || descendants.include?(parent)
        errors.add :parent, "can't include self"
        false
      else
        true
      end
    end
  end
end
