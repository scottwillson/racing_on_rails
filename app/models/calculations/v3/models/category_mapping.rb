# frozen_string_literal: true

module Calculations
  module V3
    module Models
      class CategoryMapping
        attr_reader :category, :discipline

        def initialize(category, discipline)
          @category = category
          @discipline = discipline
        end

        def ==(other)
          return false if other.nil?

          other.category == category && other.discipline == discipline
        end

        def eql?(other)
          self == other
        end

        def hash
          [category, discipline].hash
        end
      end
    end
  end
end
