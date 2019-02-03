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
        attr_accessor :rejection_reason

        def initialize(id: nil, event_category: nil, participant: nil, place: nil)
          @id = id
          @event_category = event_category
          @participant = participant
          @place = place
          @points = nil
          @rejected = false

          validate!
        end

        def category
          event_category&.category
        end

        def numeric_place
          place&.to_i || 0
        end

        def points
          @points || 0
        end

        def reject(reason)
          @rejection_reason = reason
          @rejected = true
        end

        def rejected?
          @rejected
        end

        def validate!
          raise(ArgumentError, "id is required") unless id
          raise(ArgumentError, "id must be a Numeric") unless id.is_a?(Numeric)
          raise(ArgumentError, "event_category is required") unless event_category
          raise(ArgumentError, "event_category must be an EventCategory, but was a #{event_category.class}") unless event_category.is_a?(EventCategory)
        end
      end
    end
  end
end
