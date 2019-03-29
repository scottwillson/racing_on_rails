# frozen_string_literal: true

module Calculations
  module V3
    module Models
      class Event
        attr_reader :children
        attr_reader :date
        attr_reader :discipline
        attr_reader :end_date
        attr_reader :id
        attr_accessor :parent

        def initialize(id: nil, date: nil, discipline: Models::Discipline.new("Road"), end_date: nil)
          @id = id
          @date = date
          @discipline = discipline
          @end_date = end_date || date

          @children = []

          validate!
        end

        def add_child(event)
          event.parent = self
          children << event
          event
        end

        def dates
          start_date..end_date
        end

        def start_date
          date
        end

        def validate!
          raise(ArgumentError, "Discipline is nil") unless discipline
          raise(ArgumentError, "discipline must be a Models::Discipline, but is a #{discipline.class}") unless discipline.is_a?(Models::Discipline)
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
