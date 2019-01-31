# frozen_string_literal: true

module Calculations
  module V3
    module Models
      # A Category with results (CalculatedResult or SourceResult?).
      # A "Race" in the older domain model.
      class EventCategory
        attr_reader :category

        def initialize(category)
          @category = category
          validate!
        end

        def name # rubocop:disable Rails/Delegate
          category.name
        end

        def results
          @results ||= []
        end

        def validate!
          raise(ArgumentError, "category is required") unless category
          raise(ArgumentError, "category must be a Models::Category, but is a #{category.class}") unless category.is_a?(Models::Category)
        end

        def ==(other)
          return false if other.nil?

          other.category == category
        end

        def eql?(other)
          self == other
        end

        def hash
          category&.hash
        end
      end
    end
  end
end
