# frozen_string_literal: true

module Calculations
  module V3
    class Rules
      attr_reader :categories
      # end_date is calculated and set for each calculate!
      # breaks model fo simplicity and speed
      attr_reader :end_date
      attr_reader :points_for_place

      def initialize(categories: [], double_points_for_last_event: false, end_date: nil, points_for_place: nil)
        @categories = categories
        @double_points_for_last_event = double_points_for_last_event
        @end_date = end_date
        @points_for_place = points_for_place

        validate!
      end

      def double_points_for_last_event?
        @double_points_for_last_event
      end

      def validate!
        if double_points_for_last_event? && !end_date
          raise ArgumentError, "end_date is required when double_points_for_last_event is true"
        end
      end
    end
  end
end
