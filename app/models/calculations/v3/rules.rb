# frozen_string_literal: true

module Calculations
  module V3
    class Rules
      attr_reader :categories
      attr_reader :points_for_place

      def initialize(categories: [], double_points_for_last_event: false, points_for_place: nil)
        @categories = categories
        @double_points_for_last_event = double_points_for_last_event
        @points_for_place = points_for_place
      end

      def double_points_for_last_event?
        @double_points_for_last_event
      end
    end
  end
end
