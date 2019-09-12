# frozen_string_literal: true

module Competitions
  class PortlandTrophyCup < Competitions::Overall
    before_create :set_name

    def self.parent_event_name
      "Portland Trophy Cup"
    end

    def category_names
      [
        "Beginner Women",
        "Junior Open",
        "Junior Women",
        "Open 1/2 35+",
        "Open 1/2",
        "Open 3/4",
        "Open 50+",
        "Open 60+",
        "Open Beginner",
        "Open Masters 3/4",
        "Open Singlespeed",
        "Singlespeed Women",
        "Women 1/2",
        "Women 3/4"
      ]
    end

    def double_points_for_last_event?
      true
    end

    def point_schedule
      [25, 20, 16, 13, 11, 10, 9, 8, 7, 6, 5, 4, 3, 1]
    end

    def set_name
      self.name = "Series Overall"
    end
  end
end
