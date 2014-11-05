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

    def source_event_types
      [ MultiDayEvent, SingleDayEvent, Event ]
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

    def source_results_query(race)
      # Only consider results with categories that match +race+'s category
      if categories?
        super.where("races.category_id in (?)", category_ids_for(race))
      else
        super
      end
    end

    def after_source_results(results)
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
