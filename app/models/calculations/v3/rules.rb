# frozen_string_literal: true

module Calculations
  module V3
    class Rules
      attr_reader :categories
      attr_reader :minimum_events
      attr_reader :points_for_place
      attr_reader :reject_worst_results
      attr_reader :rejected_categories
      attr_reader :source_events

      def initialize(
        categories: [],
        double_points_for_last_event: false,
        minimum_events: 0,
        points_for_place: nil,
        rejected_categories: [],
        reject_worst_results: 0,
        source_events: []
      )

        @categories = categories
        @double_points_for_last_event = double_points_for_last_event
        @minimum_events = minimum_events
        @points_for_place = points_for_place
        @reject_worst_results = reject_worst_results
        @rejected_categories = rejected_categories
        @source_events = source_events

        validate!
      end

      def double_points_for_last_event?
        @double_points_for_last_event
      end

      def reject_worst_results?
        reject_worst_results.positive?
      end

      def validate!
        if !reject_worst_results.is_a?(Integer) || reject_worst_results.to_i.negative?
          raise(ArgumentError, "reject_worst_results must be a positive integer, but is #{reject_worst_results.class} #{reject_worst_results}")
        end
      end

      def to_h
        {
          categories: categories.map(&:name),
          double_points_for_last_event: double_points_for_last_event?,
          minimum_events: minimum_events,
          points_for_place: points_for_place,
          reject_worst_results: reject_worst_results,
          rejected_categories: rejected_categories.map(&:name),
          source_events: source_events.map(&:id)
        }
      end
    end
  end
end
