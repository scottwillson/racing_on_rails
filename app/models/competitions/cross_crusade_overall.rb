module Competitions
  # Minimum three-race requirement
  # but ... should show not apply until there are at least three races
  class CrossCrusadeOverall < Overall
    include Competitions::CrossCrusade::Common

    before_create :set_notes, :set_name

    def self.parent_event_name
      "River City Bicycles Cyclocross Crusade"
    end

    def point_schedule
      [ 26, 20, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ]
    end

    def minimum_events
      3
    end

    def maximum_events(race)
      7
    end

    def set_notes
      self.notes = %Q{ Three event minimum. Results that don't meet the minimum are listed in italics. See the <a href="http://www.crosscrusade.com/series-info-rules/">series rules</a>. }
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
             race.update_attributes! bar_points: 0
           end

      super
    end
  end
end
