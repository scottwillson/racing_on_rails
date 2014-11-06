module Competitions
  class OregonWomensPrestigeSeries < Competition
    include Competitions::Calculations::CalculatorAdapter
    include Competitions::OregonWomensPrestigeSeriesModules::Common

    def friendly_name
      "Oregon Womens Prestige Series"
    end

    def category_names
      [ "Women 1/2/3", "Women 4" ]
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
      if women_4?(race)
        source_events.map(&:id) - cat_123_only_event_ids
      else
        source_events.map(&:id) 
      end
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


    private
    
    def women_4?(race)
      race.category.name == "Women 4"
    end
  end
end
