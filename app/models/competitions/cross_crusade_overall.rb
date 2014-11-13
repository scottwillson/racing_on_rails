module Competitions
  # Minimum three-race requirement
  # but ... should show not apply until there are at least three races
  class CrossCrusadeOverall < Overall
    before_create :set_notes, :set_name

    def self.parent_event_name
      "Cross Crusade"
    end

    def category_names
      [
        "Beginner Men",
        "Beginner Women",
        "Category A",
        "Category B",
        "Category C",
        "Clydesdale",
        "Junior Men 10-12",
        "Junior Men 13-14",
        "Junior Men 15-16",
        "Junior Men 17-18",
        "Junior Men",
        "Junior Women 10-12",
        "Junior Women 13-14",
        "Junior Women 15-16",
        "Junior Women 17-18",
        "Junior Women",
        "Masters 35+ A",
        "Masters 35+ B",
        "Masters 35+ C",
        "Masters 50+",
        "Masters 60+",
        "Masters Women 35+ A",
        "Masters Women 35+ B",
        "Masters Women 45+",
        "Singlespeed Women",
        "Singlespeed",
        "Unicycle",
        "Women A",
        "Women B",
        "Women C"
      ]
    end

    def point_schedule
      [ 26, 20, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ]
    end

    def minimum_events
      3
    end

    def maximum_events(race)
      6
    end

    def set_notes
      self.notes = %Q{ Three event minimum. Results that don't meet the minimum are listed in italics. See the <a href="http://crosscrusade.com/series.html">series rules</a>. }
    end

    def set_name
      self.name = "Series Overall"
    end
    
    # Use combined Junior results from race day. Don't combine all the age groups races into one.
    def category_ids_for(race)
      case race.name
      when "Junior Men", "Junior Women"
        [ Category.find_or_create_by(name: race.name).id ]
      else
        super race
      end
    end
  end
end
