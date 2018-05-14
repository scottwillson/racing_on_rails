# frozen_string_literal: true

module Competitions
  module WillametteValleyClassicsTour
    class Overall < Competitions::Overall
      def self.parent_event_name
        "Willamette Valley Classics Tour"
      end

      def after_source_results(results, race)
        super

        results.select { |result| result["category_name"].in? category_names }
      end

      def category_names
        [
          "Category 3 Men",
          "Category 4/5 Men",
          "Junior Men",
          "Junior Women",
          "Masters Men 40-49 3/4/5",
          "Masters Men 50-59 3/4/5",
          "Masters Men 60+ 3/4/5",
          "Masters Women 40+ 3/4/5",
          "Pro/1/2",
          "Pro/1/2 40+",
          "Pro/1/2 50+",
          "Women 1/2",
          "Women 3",
          "Women 4/5"
        ]
      end

      def minimum_events
        3
      end

      def point_schedule
        [100, 80, 60, 50, 45, 40, 36, 32, 29, 26, 24, 22, 20, 18, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
      end

      def upgrade_points_multiplier
        0.25
      end
    end
  end
end
