# frozen_string_literal: true

module Competitions
  class OregonWomensPrestigeSeries < Competition
    include Competitions::OregonWomensPrestigeSeriesModules::Common

    def friendly_name
      "Oregon Womens Prestige Series"
    end

    def category_names
      [ "Women 1/2", "Women 3", "Women 4/5" ]
    end

    def categories_for(race)
      if race.name == "Women 1/2"
        super + [ Category.find_by(name: "Pro/1/2 Women"), Category.find_by(name: "Women Category 1/2") ]
      elsif race.name == "Women 3"
        super + [ Category.find_by(name: "Category 3 Women"), Category.find_by(name: "Women Category 3") ]
      elsif race.name == "Women 4/5"
        super + [ Category.find_by(name: "Category 4/5 Women"),
                  Category.find_by(name: "Women 4"),
                  Category.find_by(name: "Women Category 4/5") ]
      else
        super
      end
    end

    def source_events?
      true
    end

    def source_event_types
      [ MultiDayEvent, SingleDayEvent, Event ]
    end

    def source_event_ids(race)
      if women_4_5?(race)
        source_events.map(&:id) - cat_123_only_event_ids
      else
        source_events.map(&:id)
      end
    end

    def after_source_results(results, _)
      # Ignore BAR points multiplier. Leave query "universal".
      set_multiplier results
      results
    end

    private

    def women_4_5?(race)
      race.category.name == "Women 4/5"
    end
  end
end
