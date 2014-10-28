module Competitions
  class OregonWomensPrestigeSeries < Competition
    include Competitions::Calculations::CalculatorAdapter

    def friendly_name
      "Oregon Womens Prestige Series"
    end

    def category_names
      [ "Women 1/2/3", "Women 4" ]
    end

    # Decreasing points to 20th place, then 2 points for 21st through 100th
    def point_schedule
      [ 100, 80, 70, 60, 55, 50, 45, 40, 35, 30, 25, 20, 18, 16, 14, 12, 10, 8, 6, 4 ] + ([ 2 ] * 80)
    end

    def source_events?
      true
    end

    def categories?
      true
    end

    def source_event_ids(race)
      ids = nil
      if source_events? && source_events.present?
        ids = source_events.map(&:id)
        if race.category.name == "Women 4"
          ids.delete(21334)
          ids.delete(21148)
          ids.delete(21393)
          ids.delete(21146)
          ids.delete(21186)
        end
      end
      ids
    end

    # "Universal" results usable by all competitions once they use Calculator
    def source_results(race = nil)
      query = Result.
        select([
          "bar",
          "coalesce(races.bar_points, events.bar_points, parents_events.bar_points, parents_events_2.bar_points) as multiplier",
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
        where("year = ?", year)

      # Only consider results with categories that match +race+'s category
      if categories?
        query = query.where("races.category_id in (?)", category_ids_for(race))
      end

      results = Result.connection.select_all(query)
      # Ignore BAR points multiplier. Leave query "universal".
      set_multiplier results
      results
    end

    def set_multiplier(results)
      results.each do |result|
        if result["type"] == "MultiDayEvent"
          result["multiplier"] = 1.5
        else
          result["multiplier"] = 1
        end
      end
    end
  end
end
