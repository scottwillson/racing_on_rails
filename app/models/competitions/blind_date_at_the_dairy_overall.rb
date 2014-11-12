module Competitions
  class BlindDateAtTheDairyOverall < Overall
    def self.parent_event_name
      "Blind Date at the Dairy"
    end

    def category_names
      [
        "Beginner Men",
        "Beginner Women",
        "Junior Men 10-13",
        "Junior Men 14-18",
        "Junior Women 10-13",
        "Junior Women 14-18",
        "Masters Men A 40+",
        "Masters Men B 35+",
        "Masters Men C 35+",
        "Men A",
        "Men B",
        "Men C",
        "Singlespeed",
        "Stampede",
        "Women A",
        "Women B",
        "Women C"
      ]
    end

    def point_schedule
      [ 15, 12, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ]
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
