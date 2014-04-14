module Competitions
  # Count pre-set list of series source_events + manually-entered non-series events
  class Cat4WomensRaceSeries < Competition
    include Cat4WomensRaceSeriesModules::Points

    def friendly_name
      "Cat 4 Women's Race Series"
    end

    def source_results(race)
      _start_date = RacingAssociation.current.cat4_womens_race_series_start_date || date.beginning_of_year
      _end_date = RacingAssociation.current.cat4_womens_race_series_end_date || self.end_date
      Result.
        includes(race: [ :category, :event ]).
        where("place > 0 or place is null or place = ''").
        where("results.name is not null").
        where("results.name != ''").
        where("categories.id" => category_ids_for(race)).
        where("(events.type = 'SingleDayEvent' or events.type is null or events.id in (?))", source_events.map(&:id)).
        where("(events.ironman is true or events.id in (?))", source_events.map(&:id)).
        where("events.date between ? and ?", _start_date, _end_date).
        order(:person_id).
        references(:category, :event)
    end

    def participation_points?
      RacingAssociation.current.award_cat4_participation_points?
    end

    def association_point_schedule
      RacingAssociation.current.cat4_womens_race_series_points
    end

    def members_only?
      false
    end

    def create_races
      races.create category: category
    end

    def cat_4_categories
      [ category ] + category.descendants
    end

    def category
      @category ||=
        RacingAssociation.current.cat4_womens_race_series_category ||
        Category.find_or_create_by(name: "Women Cat 4")
    end
  end
end
