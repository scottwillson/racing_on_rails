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

        def member?
          return false unless membership

          Date.today.in? membership
        end

        def validate!
          raise(ArgumentError, "id must be a Numeric") unless id.nil? || id.is_a?(Numeric)
        end
      end
    end
  end
end
