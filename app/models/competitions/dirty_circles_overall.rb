module Competitions
  class DirtyCirclesOverall < Overall
    before_create :set_name

    def self.parent_event_name
      "Dirty Circles"
    end

    def category_names
      [
        "Junior Men",
        "Junior Women",
        "Masters Men 1/2/3 35+",
        "Masters Men 3/4 35+",
        "Masters Men 3/4 50+",
        "Masters Men 4/5 35+",
        "Men 1/2/3",
        "Men 4/5",
        "Women 1/2/3",
        "Women 4/5"
      ]
    end

    def point_schedule
      _points_schedule = Hash.new
      source_events.each do |event|
        _points_schedule[event.id] = [ 100, 80, 60, 50, 45, 40, 36, 32, 29, 26, 24, 22, 20, 18, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ]
      end
      hot_spots.each do |event|
        _points_schedule[event.id] = [ 18, 16, 14, 12, 10 ]
      end
      _points_schedule
    end

    def hot_spots
      parent.children.map(&:children).flatten.select { |e| e.name[/hot/i] }
    end

    def add_source_events
      self.source_events = parent.children + hot_spots
    end

    def set_name
      self.name = "Series Overall"
    end
  end
end
