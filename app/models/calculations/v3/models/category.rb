# frozen_string_literal: true

# Canonical category with name, ability, age, etc. Not associated with an individual event.
# EventCategory joins a Category with an event.
module Calculations
  module V3
    module Models
      class Category
        attr_reader :name

        def initialize(name)
          @name = name
        end

        def ==(other)
          return false if other.nil?

          other.name == name
        end

        def eql?(other)
          self == other
        end

        def hash
          name&.hash
        end
      end
    end
  end
end
