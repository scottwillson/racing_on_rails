# frozen_string_literal: true

module Calculations
  module V3
    class Rules
      attr_reader :category_rules
      attr_reader :disciplines
      attr_reader :maximum_events
      attr_reader :members_only
      attr_reader :minimum_events
      attr_reader :points_for_place
      attr_reader :specific_events
      attr_reader :source_events
      attr_reader :source_event_keys
      attr_reader :weekday_events

      def initialize(
        category_rules: [],
        disciplines: [],
        double_points_for_last_event: false,
        maximum_events: 0,
        members_only: false,
        minimum_events: 0,
        points_for_place: nil,
        specific_events: false,
        source_events: [],
        source_event_keys: [],
        weekday_events: true
      )

        @category_rules = category_rules
        @disciplines = disciplines
        @double_points_for_last_event = double_points_for_last_event
        @maximum_events = maximum_events
        @members_only = members_only
        @minimum_events = minimum_events
        @points_for_place = points_for_place
        @source_events = source_events
        @source_event_keys = source_event_keys
        @specific_events = specific_events
        @weekday_events = weekday_events

        validate!
      end

      def categories
        category_rules.reject(&:reject?).map(&:category)
      end

      def categories?
        !categories.empty?
      end

      def double_points_for_last_event?
        @double_points_for_last_event
      end

      def maximum_events?
        maximum_events.negative?
      end

      def members_only?
        members_only
      end

      def specific_events?
        specific_events
      end

      def rejected_categories
        category_rules.select(&:reject?).map(&:category)
      end

      def validate!
        if !maximum_events.is_a?(Integer) || maximum_events.to_i.positive?
          raise(ArgumentError, "maximum_events must be an integer < 1, but is #{maximum_events.class} #{maximum_events}")
        end
      end

      def weekday_events?
        @weekday_events
      end

      def to_h
        {
          categories: categories.map(&:name),
          disciplines: disciplines.map(&:name),
          double_points_for_last_event: double_points_for_last_event?,
          maximum_events: maximum_events,
          members_only: members_only?,
          minimum_events: minimum_events,
          points_for_place: points_for_place,
          source_events: source_events.map(&:id),
          source_event_keys: source_event_keys,
          specific_events: specific_events?,
          weekday_events: weekday_events?
        }
      end
    end
  end
end
