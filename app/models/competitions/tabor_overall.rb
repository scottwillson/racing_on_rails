module Competitions
  # Mount Tabor Overall Series results
  class TaborOverall < Overall
    def self.parent_event_name
      "Mt. Tabor Series"
    end

    def create_races
      races.create! category: Category.find_or_create_by(name: "Fixed Gear")
      races.create! category: Category.find_or_create_by(name: "Category 4 Women")
      races.create! category: Category.find_or_create_by(name: "Masters Women")
      races.create! category: Category.find_or_create_by(name: "Senior Women")
      races.create! category: Category.find_or_create_by(name: "Masters Men")
      races.create! category: Category.find_or_create_by(name: "Category 4 Men")
      races.create! category: Category.find_or_create_by(name: "Category 5 Men")
      races.create! category: Category.find_or_create_by(name: "Category 3 Men")
      races.create! category: Category.find_or_create_by(name: "Senior Men")
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
