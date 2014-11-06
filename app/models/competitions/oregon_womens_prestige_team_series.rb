module Competitions
  class OregonWomensPrestigeTeamSeries < Competition
    include Competitions::Calculations::CalculatorAdapter
    include Competitions::OregonWomensPrestigeSeriesModules::Common

    def friendly_name
      "Oregon Womens Prestige Team Series"
    end

    def category_names
      [ "Team" ]
    end

    def source_events?
      true
    end

    def source_events
      (OregonWomensPrestigeSeries.find_for_year(year) || OregonWomensPrestigeSeries.create).source_events
    end

    def categories?
      true
    end

    def results_per_race
      3
    end

    def team?
      true
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
      results = results.reject do |result|
        result["category_id"].in?(cat_4_category_ids) && result["event_id"].in?(cat_123_only_event_ids)
      end

      # Ignore BAR points multiplier. Leave query "universal".
      set_multiplier results
      results
    end

    def category_ids_for(race)
      if OregonWomensPrestigeSeries.find_for_year
        categories = Category.where("name in (?)", OregonWomensPrestigeSeries.find_for_year.category_names)
        categories.map(&:id) + categories.map(&:descendants).to_a.flatten.map(&:id)
      else
        []
      end
    end

    def cat_4_category_ids
      if @cat_4_category_ids.nil?
        categories = Category.where(name: "Category 4 Women")
        @cat_4_category_ids = categories.map(&:id) + categories.map(&:descendants).to_a.flatten.map(&:id)
      end
      @cat_4_category_ids
    end
  end
end
