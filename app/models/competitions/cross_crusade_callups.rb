module Competitions
  class CrossCrusadeCallups < Competition
    default_value_for :name, "Cross Crusade Callups"

    def category_names
      [
        "Category A",
        "Category B",
        "Category C",
        "Clydesdale",
        "Junior Men",
        "Junior Women",
        "Masters 35+ A",
        "Masters 35+ B",
        "Masters 35+ C",
        "Masters 50+",
        "Masters 60+",
        "Masters Women 35+ A",
        "Masters Women 35+ B",
        "Masters Women 45+",
        "Singlespeed Women",
        "Singlespeed",
        "Unicycle",
        "Women A",
        "Women B",
        "Women C"
      ]
    end

    def source_results_query(race)
      super.
      where("races.category_id" => categories_for(race))
    end

    def point_schedule
      [ 15, 12, 10, 8, 7, 6, 5, 4, 3, 2 ]
    end

    def source_events?
      true
    end

    def categories_for(race)
      categories = super(race)
      if race.name == "Masters 35+ A"
        categories << Category.find_or_create_by(name: "Masters Men A 40+")
      end
      categories
    end

    def after_source_results(results, race)
      results.each do |result|
        result["multiplier"] = 1
      end
    end
  end
end
