# frozen_string_literal: true

module Competitions
  # Mount Tabor Overall Series results
  class TaborOverall < Overall
    def self.parent_event_name
      "Mt. Tabor Series"
    end

    def category_names
      [
        "Category 3 Men",
        "Category 4 Men",
        "Category 4/5 Women",
        "Category 5 Men",
        "Masters Men 50+",
        "Masters Men 40+",
        "Senior Men",
        "Senior Women"
      ]
    end

    def double_points_for_last_event?
      true
    end

    def default_bar_points
      1
    end

    def point_schedule
      [100, 90, 80, 70, 60, 50, 40, 30, 20, 16, 12, 8, 4, 2, 1]
    end
  end
end
