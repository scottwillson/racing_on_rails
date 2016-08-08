module Competitions
  class BlindDateAtTheDairyOverall < Overall
    def self.parent_event_name
      "Blind Date at the Dairy"
    end

    def category_names
      [
        "Category 1/2 Men",
        "Category 2/3 Men",
        "Category 3/4 Men",
        "Category 5 Men",
        "Junior Men 14-18",
        "Junior Men 9-13",
        "Junior Women 14-18",
        "Junior Women 9-13",
        "Masters Men 1/2 40+",
        "Masters Men 2/3 40+",
        "Masters Men 3/4 40+",
        "Masters Men 50+",
        "Masters Men 60+",
        "Singlespeed",
        "Stampede",
        "Women 1/2",
        "Women 3",
        "Women 4",
        "Women 5",
      ]
    end

    def point_schedule
      [ 15, 12, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ]
    end

    def maximum_events(race)
      4
    end

    def after_calculate
      super

      race = races.detect { |r| r.name == "Beginner" }
      if race
        race.update_attributes! visible: false
      end

      BlindDateAtTheDairyMonthlyStandings.calculate!
    end
  end
end
