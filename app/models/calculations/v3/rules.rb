# frozen_string_literal: true

module Calculations
  module V3
    class Rules
      attr_reader :category_rules
      attr_reader :maximum_events
      attr_reader :minimum_events
      attr_reader :points_for_place
      attr_reader :source_events

      def initialize(
        category_rules: [],
        double_points_for_last_event: false,
        maximum_events: 0,
        minimum_events: 0,
        points_for_place: nil,
        source_events: []
      )

        @category_rules = category_rules
        @double_points_for_last_event = double_points_for_last_event
        @maximum_events = maximum_events
        @minimum_events = minimum_events
        @points_for_place = points_for_place
        @source_events = source_events

        validate!
      end

      def categories
        category_rules.reject(&:reject?).map(&:category)
      end

      def double_points_for_last_event?
        @double_points_for_last_event
      end

      def maximum_events?
        maximum_events.negative?
      end

      def rejected_categories
        category_rules.select(&:reject?).map(&:category)
      end

      def validate!
        if !maximum_events.is_a?(Integer) || maximum_events.to_i.positive?
          raise(ArgumentError, "maximum_events must be an integer < 1, but is #{maximum_events.class} #{maximum_events}")
        end
      end

      def to_h
        {
          categories: categories.map(&:name),
          double_points_for_last_event: double_points_for_last_event?,
          maximum_events: maximum_events,
          minimum_events: minimum_events,
          points_for_place: points_for_place,
          source_events: source_events.map(&:id)
        }
      end
    end
  end
end
