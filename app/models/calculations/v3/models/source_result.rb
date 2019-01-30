# frozen_string_literal: true

module Calculations
  module V3
    module Models
      # Result from event. Typically, from a rider crossing a finish line,
      # but could be calculated by another calculated event. For example, Road BAR
      # and Overall BAR.
      class SourceResult
        attr_reader :id
        attr_reader :event_category
        attr_reader :participant
        attr_accessor :place
        attr_writer :points

        def initialize(id: nil, event_category: nil, participant: nil, place: nil)
          @id = id
          @event_category = event_category
          @participant = participant
          @place = place
          @points = nil

          validate!
        end

        def numeric_place
          place&.to_i || 0
        end

        def points
          @points || 0
        end

        def rejected?
          false
        end

        def validate!
          raise(ArgumentError, "id is required") unless id
          raise(ArgumentError, "id must be a Numeric") unless id.is_a?(Numeric)
          raise(ArgumentError, "event_category is required") unless event_category
          raise(ArgumentError, "event_category must be an EventCategory") unless event_category.is_a?(Calculations::V3::Models::EventCategory)
        end
      end
    end
  end
end
