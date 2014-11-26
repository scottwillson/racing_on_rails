module Competitions
  # Who has done the most events? Just counts starts/appearences in results. Not pefect -- some events
  # are probably over-counted.
  class Ironman < Competition
    def friendly_name
      "Ironman"
    end

    def points_for(source_result)
      1
    end

    def break_ties?
      false
    end

    def dnf_points
      1
    end

    def notes
      "The Ironman Competition is a 'just for fun' record of the number of events riders do. There is no prize just identification of riders who need to get a life."
    end

    def source_results_query(race)
      super.where("events.ironman" => true)
    end

    # Workaround for Cross Crusade Junior results reporting
    def after_source_results(results)
      results.reject { |r| r["category_name"].in?(junior_categories) && r["event_id"].in?(cross_crusade_2014) }
    end

    def junior_categories
      [
        "Junior Men 10-12",
        "Junior Men 13-14",
        "Junior Men 15-16",
        "Junior Men 17-18",
        "Junior Women 10-12",
        "Junior Women 13-14",
        "Junior Women 15-16",
        "Junior Women 17-18"
      ]
    end

    def cross_crusade_2014
      SingleDayEvent.where(parent_id: 22445).pluck(:id)
    end
  end
end
