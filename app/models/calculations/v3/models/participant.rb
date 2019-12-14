# frozen_string_literal: true

# Person or team that owns a result. Teams can be permanent year-long teams,
# or event-only teams.
module Calculations
  module V3
    module Models
      class Participant
        attr_reader :id
        attr_reader :membership

        def initialize(id, membership: nil)
          @id = id
          @membership = membership

          validate!
        end

        def member?(year)
          return false unless membership

          membership.include? Date.new(year, 12, 31)
        end

        def validate!
          raise(ArgumentError, "id must be a Numeric") unless id.nil? || id.is_a?(Numeric)
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
