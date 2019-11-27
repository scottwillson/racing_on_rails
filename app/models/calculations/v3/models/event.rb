# frozen_string_literal: true

module Calculations
  module V3
    module Models
      class Event
        attr_reader :children
        attr_reader :date
        attr_reader :discipline
        attr_reader :event_categories
        attr_reader :end_date
        attr_reader :id
        attr_reader :multiplier
        attr_accessor :parent
        attr_reader :sanctioned_by

        def initialize(
          id: nil,
          calculated: false,
          date: nil,
          discipline: Models::Discipline.new("Road"),
          end_date: nil,
          multiplier: 1,
          sanctioned_by: nil
        )

          @id = id
          @calculated = calculated
          @date = date
          @discipline = discipline
          @end_date = end_date || date
          @multiplier = multiplier
          @sanctioned_by = sanctioned_by

          @children = []
          @event_categories = []

          validate!
        end

        def add_category(category)
          event_category = Models::EventCategory.new(category, self)
          event_categories << event_category unless event_categories.include?(event_category)
          event_category
        end

        def add_child(event)
          event.parent = self
          children << event unless children.include?(event)
          event
        end

        def calculated?
          @calculated
        end

        def categories
          event_categories.map(&:category)
        end

        def dates
          start_date..end_date
        end

        def days
          children.map(&:date).sort.uniq
        end

        def start_date
          date
        end

        def validate!
          raise(ArgumentError, "Discipline is nil") unless discipline
          raise(ArgumentError, "discipline must be a Models::Discipline, but is a #{discipline.class}") unless discipline.is_a?(Models::Discipline)
          raise(ArgumentError, "end_date #{end_date} cannot be before date #{date}") if end_date && end_date < date
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
