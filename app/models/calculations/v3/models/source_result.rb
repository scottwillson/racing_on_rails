# frozen_string_literal: true

module Calculations
  module V3
    module Models
      # Result from event. Typically, from a rider crossing a finish line,
      # but could be calculated by another calculated event. For example, Road BAR
      # and Overall BAR.
      class SourceResult
        attr_reader :id
        attr_reader :date
        attr_reader :event_category
        attr_reader :participant
        attr_accessor :place
        attr_writer :points
        attr_accessor :rejection_reason

        def initialize(id: nil, date: nil, event_category: nil, participant: nil, place: nil, points: nil)
          @id = id
          @date = date
          @event_category = event_category
          @participant = participant
          @place = place
          @points = points
          @rejected = false

          validate!
        end

        def category
          event_category&.category
        end

        def dnf?
          "DNF".casecmp(place) == 0
        end

        def last_event_date
          event_category.event.parent.end_date
        end

        # Opposite convention of ::Result (for now)
        def numeric_place
          case place&.to_i
          when nil, 0
            Float::INFINITY
          else
            place.to_i
          end
        end

        def placed?
          numeric_place != Float::INFINITY
        end

        def points
          @points || 0
        end

        def points?
          points.positive?
        end

        def reject(reason)
          @rejection_reason = reason
          @rejected = true
          @points = 0
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

        delegate :discipline, to: :event_category
      end
    end
  end
end
