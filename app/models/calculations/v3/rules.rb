# frozen_string_literal: true

module Calculations
  module V3
    class Rules
      attr_reader :association
      attr_reader :association_sanctioned_only
      attr_reader :category_rules
      attr_reader :disciplines
      attr_reader :maximum_events
      attr_reader :members_only
      attr_reader :minimum_events
      attr_reader :missing_result_penalty
      attr_reader :place_by
      attr_reader :points_for_place
      attr_reader :results_per_event
      attr_reader :specific_events
      attr_reader :source_events
      attr_reader :source_event_keys
      attr_reader :team

      # If true, only include weekend events
      # If false, reject all weekday events except series overall
      attr_reader :weekday_events

      def initialize(
        association: nil,
        association_sanctioned_only: false,
        category_rules: [],
        disciplines: [],
        double_points_for_last_event: false,
        maximum_events: 0,
        members_only: false,
        minimum_events: 0,
        missing_result_penalty: nil,
        place_by: "points",
        points_for_place: nil,
        results_per_event: nil,
        specific_events: false,
        source_events: [],
        source_event_keys: [],
        team: false,
        weekday_events: true
      )

        @association = association
        @association_sanctioned_only = association_sanctioned_only
        @category_rules = category_rules
        @disciplines = disciplines
        @double_points_for_last_event = double_points_for_last_event
        @maximum_events = maximum_events
        @members_only = members_only
        @minimum_events = minimum_events
        @missing_result_penalty = missing_result_penalty
        @place_by = place_by
        @points_for_place = points_for_place
        @results_per_event = results_per_event
        @source_events = source_events
        @source_event_keys = source_event_keys
        @specific_events = specific_events
        @team = team
        @weekday_events = weekday_events

        validate!
      end

      def association_sanctioned_only?
        @association_sanctioned_only
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

      def missing_result_penalty?
        missing_result_penalty
      end

      def specific_events?
        specific_events
      end

      def rejected_categories
        category_rules.select(&:reject?).map(&:category)
      end

      def team?
        team
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
          association: association&.id,
          association_sanctioned_only: association_sanctioned_only,
          categories: categories.map(&:name),
          disciplines: disciplines.map(&:name),
          double_points_for_last_event: double_points_for_last_event?,
          maximum_events: maximum_events,
          members_only: members_only?,
          minimum_events: minimum_events,
          place_by: place_by,
          missing_result_penalty: missing_result_penalty,
          points_for_place: points_for_place,
          results_per_event: results_per_event,
          source_events: source_events.map(&:id),
          source_event_keys: source_event_keys,
          specific_events: specific_events?,
          team: team?,
          weekday_events: weekday_events?
        }
      end
    end
  end
end
