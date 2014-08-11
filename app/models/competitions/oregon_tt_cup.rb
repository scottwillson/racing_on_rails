module Competitions
  # Year-long OBRA TT competition
  class OregonTTCup < Competition
    include Competitions::CalculatorAdapter

    def friendly_name
      "OBRA Time Trial Cup"
    end

    def default_discipline
      "Time Trial"
    end

    def category_names
      [
        "Category 3 Men",
        "Category 3 Women",
        "Category 4/5 Men",
        "Category 4/5 Women",
        "Eddy Senior Men",
        "Eddy Senior Women",
        "Junior Men 10-12",
        "Junior Men 13-14",
        "Junior Men 15-16",
        "Junior Men 17-18",
        "Junior Women 10-14",
        "Junior Women 15-18",
        "Masters Men 30-39",
        "Masters Men 40-49",
        "Masters Men 50-59",
        "Masters Men 60+",
        "Masters Women 30-39",
        "Masters Women 40-49",
        "Masters Women 50-59",
        "Masters Women 60+",
        "Senior Men Pro/1/2",
        "Senior Women 1/2"
      ]
    end

    def point_schedule
      [ 20, 17, 15, 13, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ]
    end

    def source_events?
      true
    end

    def all_year?
      false
    end

    def maximum_events(race)
      9
    end

    def source_results(race)
      query = Result.
        select([
          "bar",
          "1 as multiplier",
          "events.date",
          "events.ironman",
          "events.sanctioned_by",
          "events.type",
          "people.date_of_birth",
          "people.member_from",
          "people.member_to",
          "person_id as participant_id",
          "place",
          "points",
          "races.category_id",
          "race_id",
          "results.event_id",
          "results.id as id",
          "year"
        ]).
        joins(race: :event).
        joins("left outer join people on people.id = results.person_id").
        joins("left outer join events parents_events on parents_events.id = events.parent_id").
        joins("left outer join events parents_events_2 on parents_events_2.id = parents_events.parent_id").
        where("place between 1 and ?", point_schedule.size).
        where(bar: true).
        where("races.category_id in (?)", category_ids_for(race)).
        where("events.sanctioned_by" => RacingAssociation.current.default_sanctioned_by).
        where("coalesce(races.bar_points, events.bar_points, parents_events.bar_points, parents_events_2.bar_points) > 0").
        where("results.year = ?", year)

      Result.connection.select_all query
    end

    def category_ids_for(race)
      ids = [ race.category_id ] + race.category.descendants.map(&:id)

      case race.category.name
      when "Masters Men 40-49"
        [ "Masters Men 40-44", "Masters Men 45-49" ]
      when "Masters Men 50-59"
        [ "Masters Men 50-54", "Masters Men 55-59" ]
      when "Masters Women 50-59"
        [ "Masters Women 50-54", "Masters Women 55-59" ]
      when "Senior Women 1/2"
        [ "Senior Women" ]
      when "Category 4/5 Women"
        [ "Women Category 4" ]
      when "Category 3 Women"
        [ "Women Category 3" ]
      when "Junior Women 10-14"
        [ "Junior Women 13-14" ]
      when "Junior Women 15-18"
        [ "Women Junior", "Junior Women 15-16", "Junior Women 17-18" ]
      else
        []
      end.each do |name|
        category = Category.where(name: name).first
        if category
          ids << category.id
        end
      end

      ids
    end
  end
end
