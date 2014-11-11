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
        "Category 4 Women",
        "Category 5 Men",
        "Fixed Gear",
        "Masters Men",
        "Masters Women",
        "Senior Men",
        "Senior Women"
      ]
    end

    def maximum_events(race)
      if race.name == "Category 4 Men" || race.name == "Masters Women"
        4
      else
        5
      end
    end

    def double_points_for_last_event?
      true
    end

    def default_bar_points
      1
    end

    def point_schedule
      [ 100, 70, 50, 40, 36, 32, 28, 24, 20, 16, 15, 14, 13, 12, 11 ]
    end
  end
end
