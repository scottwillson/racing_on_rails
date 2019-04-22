# frozen_string_literal: true

module Calculations
  module V3
    module Models
      class Association
        attr_reader :id

        def initialize(id: nil)
          @id = id
        end

        def ==(other)
          return false if other.nil?

          other.id == id
        end

        def eql?(other)
          self == other
        end

        def hash
          id&.hash
        end
      end
    end
  end
end
