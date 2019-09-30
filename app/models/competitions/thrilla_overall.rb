# frozen_string_literal: true

module Competitions
  class ThrillaOverall < Overall
    before_create :set_name

    def self.parent_event_name
      "MBSEF Thrilla Cyclocross Series"
    end

    def category_names
      [
        "Athena",
        "Category 1/2 Masters Men 35+",
        "Category 1/2 Masters Women 35+",
        "Category 1/2 Men",
        "Category 1/2 Women",
        "Category 3 Masters Men 35+",
        "Category 3 Masters Women 35+",
        "Category 3 Men",
        "Category 3 Women",
        "Category 3/4/5 Junior Men",
        "Category 3/4/5 Junior Women",
        "Category 4 Masters Men 35+",
        "Category 4 Men",
        "Category 4 Women",
        "Category 5 Men",
        "Category 5 Women",
        "Clydesdale",
        "Masters Men 50+",
        "Masters Men 60+",
        "Masters Men 70+",
        "Masters Women 50+",
        "Singlespeed Men",
        "Singlespeed Women"
      ]
    end

    def point_schedule
      [15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
    end

    def set_name
      self.name = "Series Overall"
    end
  end
end
