# frozen_string_literal: true

# Category-specific rules
module Calculations
  module V3
    module Models
      class CategoryRule
        attr_reader :category, :mappings, :maximum_events, :reject

        def initialize(category, mappings: [], maximum_events: nil, reject: false)
          @category = category
          @mappings = mappings
          @maximum_events = maximum_events
          @reject = reject

          validate!
        end

        delegate :name, to: :category

        def reject?
          !@reject.nil? && reject
        end

        def validate!
          raise(ArgumentError, "category is required") unless category
          raise(ArgumentError, "category must be a Models::Category, but is a #{category.class}") unless category.is_a?(Models::Category)
        end
      end
    end
  end
end
