module Competitions
  # Minimum three-race requirement
  # but ... should show not apply until there are at least three races
  class CrossCrusadeOverall < Overall
    before_create :set_notes, :set_name

    def self.parent_event_name
      "Cross Crusade"
    end

    def create_races
      races.create!(category: Category.find_or_create_by(name: "Category A"))
      races.create!(category: Category.find_or_create_by(name: "Category B"))
      races.create!(category: Category.find_or_create_by(name: "Category C"))
      races.create!(category: Category.find_or_create_by(name: "Masters 35+ A"))
      races.create!(category: Category.find_or_create_by(name: "Masters 35+ B"))
      races.create!(category: Category.find_or_create_by(name: "Masters 35+ C"))
      races.create!(category: Category.find_or_create_by(name: "Masters 50+"))
      races.create!(category: Category.find_or_create_by(name: "Masters 60+"))
      races.create!(category: Category.find_or_create_by(name: "Junior Men"))
      races.create!(category: Category.find_or_create_by(name: "Junior Women"))
      races.create!(category: Category.find_or_create_by(name: "Women A"))
      races.create!(category: Category.find_or_create_by(name: "Women B"))
      races.create!(category: Category.find_or_create_by(name: "Women C"))
      races.create!(category: Category.find_or_create_by(name: "Beginner Women"))
      races.create!(category: Category.find_or_create_by(name: "Masters Women 35+ A"))
      races.create!(category: Category.find_or_create_by(name: "Masters Women 35+ B"))
      races.create!(category: Category.find_or_create_by(name: "Masters Women 45+"))
      races.create!(category: Category.find_or_create_by(name: "Beginner Men"))
      races.create!(category: Category.find_or_create_by(name: "Singlespeed"))
      races.create!(category: Category.find_or_create_by(name: "Unicycle"))
      races.create!(category: Category.find_or_create_by(name: "Clydesdale"))
    end

    def point_schedule
      [0, 26, 20, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
    end

    # Apply points from point_schedule, and split across team
    def points_for(source_result, team_size = nil)
      point_schedule[source_result.place.to_i].to_f
    end

    def default_bar_points
      0
    end

    def minimum_events
      3
    end

    def maximum_events(race)
      7
    end

    def set_notes
      self.notes = %Q{ Three event minimum. Results that don't meet the minimum are listed in italics. See the <a href="http://crosscrusade.com/series.html">series rules</a>. }
    end

    def set_name
      self.name = "Series Overall"
    end
  end
end
