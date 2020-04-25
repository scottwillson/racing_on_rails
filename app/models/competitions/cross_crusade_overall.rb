# frozen_string_literal: true

module Competitions
  # Minimum three-race requirement
  # but ... should show not apply until there are at least three races
  class CrossCrusadeOverall < Overall
    before_create :set_notes, :set_name

    def self.parent_event_name
      "Cyclocross Crusade"
    end

    def category_names
      [
        "Athenas",
        "Category 1/2 Masters 35+ Men",
        "Category 1/2 Masters 35+ Women",
        "Category 1/2 Men",
        "Category 1/2 Women",
        "Category 1/2/3 Junior Men",
        "Category 1/2/3 Junior Women",
        "Category 2/3 Men",
        "Category 2/3 Women",
        "Category 3 Masters 35+ Men",
        "Category 3 Masters 35+ Women",
        "Category 3/4/5 Junior Men",
        "Category 3/4/5 Junior Women",
        "Category 4 Masters Men 35+",
        "Category 4 Men",
        "Category 4 Women",
        "Category 5 Men",
        "Category 5 Women",
        "Clydesdale",
        "Junior Men 13-14",
        "Junior Men 15-16",
        "Junior Men 17-18",
        "Junior Men 9-12",
        "Junior Women 13-14",
        "Junior Women 15-16",
        "Junior Women 17-18",
        "Junior Women 9-12",
        "Masters 50+ Men",
        "Masters 50+ Women",
        "Masters 60+ Men",
        "Masters 60+ Women",
        "Masters 70+ Men",
        "Singlespeed Men",
        "Singlespeed Women"
      ]
    end

    def point_schedule
      [26, 20, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
    end

    def minimum_events
      3
    end

    def maximum_events(race)
      # Races canceled due to weather
      if year == 2018 && race.name.in?([
        "Elite Junior Women",
        "Masters Women 35+ 1/2",
        "Masters Women 35+ 3",
        "Masters Women 50+",
        "Masters Women 60+",
        "Women 2/3",
        "Women 4",
        "Women 5"
      ])
        return 6
      end

      7
    end

    def members_only?
      false
    end

    def set_notes
      self.notes = %( Three event minimum. Results that don't meet the minimum are listed in italics. See the <a href="http://www.crosscrusade.com/series-info-rules/">series rules</a>. )
    end

    def set_name
      self.name = "Series Overall"
    end

    def categories_for(race)
      result_categories_by_race[race.category]
    end

    def categories_clause(race)
      if race.name["Elite"] || race.name["3/4/5"]
        super
      else
        super.where.not("categories.name like ? or (ability_begin = 3 and ability_end = 5)", "%elite%")
      end
    end

    def after_calculate
      races.select { |race| race.name["Elite"] || race.name["3/4/5"] }
           .each do |race|
             race.update! bar_points: 0
           end

      super
    end
  end
end
