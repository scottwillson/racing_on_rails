# frozen_string_literal: true

module Calculations
  module V3
    module Models
      class Discipline
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
