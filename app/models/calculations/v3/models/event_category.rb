# frozen_string_literal: true

module Calculations
  module V3
    module Models
      # A Category with results (CalculatedResult or SourceResult?).
      # A "Race" in the older domain model.
      class EventCategory
        attr_reader :category
        attr_reader :event
        attr_accessor :rejection_reason

        def initialize(category, event = nil, discipline: nil)
          @category = category
          @discipline = discipline
          @event = event
          @rejected = false

          validate!
        end

        def discipline
          @discipline || event&.discipline
        end

        def event_id
          event&.id
        end

        def field_size
          results.size
        end

        def name # rubocop:disable Rails/Delegate
          category.name
        end

        def source_results
          results.flat_map(&:source_results)
        end

        def reject(reason)
          raise(ArgumentError, "already rejected because #{rejection_reason}") if rejected?

          @rejection_reason = reason
          @rejected = true
        end

        def rejected?
          @rejected
        end

        def results
          @results ||= []
        end

        def unrejected_results
          results.reject(&:rejected?)
        end

        def unrejected_source_results
          source_results.reject(&:rejected?)
        end

        def validate!
          raise(ArgumentError, "category is required") unless category
          raise(ArgumentError, "category must be a Models::Category, but is a #{category.class}") unless category.is_a?(Models::Category)
          raise(ArgumentError, "discipline must be a Models::Discipline, but is a #{discipline.class}") unless discipline.nil? || discipline.is_a?(Models::Discipline)
          raise(ArgumentError, "event must be a Models::Event, but is a #{event.class}") unless event.nil? || event.is_a?(Models::Event)
        end

        def ==(other)
          return false if other.nil?

          other.category == category && other.event == event
        end

        def eql?(other)
          self == other
        end

        def hash
          [category, event].compact.hash
        end
      end
    end
  end
end
