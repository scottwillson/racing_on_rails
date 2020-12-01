# frozen_string_literal: true

module Calculations
  module V3
    module Models
      # Result from event. Typically, from a rider crossing a finish line,
      # but could be calculated by another calculated event. For example, Road BAR
      # and Overall BAR.
      class SourceResult
        include Calculations::V3::Models::Results

        attr_reader :id, :age, :date, :event_category, :participant, :time
        attr_accessor :place, :rejection_reason, :team_size
        attr_writer :points

        def initialize(id: nil, age: nil, date: nil, event_category: nil, participant: nil, place: nil, points: nil, team_size: 1, time: nil)
          @id = id
          @age = age
          @date = date&.to_date
          @event_category = event_category
          @participant = participant
          @place = place
          @points = points
          @rejected = false
          @team_size = team_size
          @time = time

          validate!
        end

        def ability
          category&.ability
        end

        def category
          event_category&.category
        end

        def dnf?
          "DNF".casecmp(place) == 0
        end

        def new?
          id.nil?
        end

        def parent_date
          event&.parent&.date || date
        end

        def parent_end_date
          event&.parent&.end_date || date
        end

        def points
          @points || 0
        end

        # Cyclocross age are a year ahead, but need to a single age for each participant for the year
        def racing_age
          if age && event&.discipline&.cyclocross?
            return age - 1
          end

          age
        end

        def validate!
          raise(ArgumentError, "id must be a Numeric") if id && !id.is_a?(Numeric)
          raise(ArgumentError, "event_category is required") unless event_category
          raise(ArgumentError, "event_category must be an EventCategory, but was a #{event_category.class}") unless event_category.is_a?(EventCategory)
        end

        delegate :discipline, :event, :field_size, to: :event_category
        delegate :id, to: :participant, prefix: true
      end
    end
  end
end
