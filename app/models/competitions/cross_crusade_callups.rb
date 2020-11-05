# frozen_string_literal: true

module Competitions
  class CrossCrusadeCallups < Competition
    attribute :name, :boolean, default: -> { "Cross Crusade Callups" }

    def point_schedule
      [15, 12, 10, 8, 7, 6, 5, 4, 3, 2]
    end

    def source_events?
      true
    end

    def categories_for(race)
      categories = super(race)

      if year < 2016
        categories << Category.find_or_create_by(name: "Masters Men A 40+") if race.name == "Masters 35+ A"
        categories << Category.find_or_create_by(name: "Masters Men B 40+") if race.name == "Masters 35+ B"
        if race.name == "Masters 35+ C"
          categories << Category.find_or_create_by(name: "Masters Men C 40+")
          categories << Category.find_or_create_by(name: "Men C 35+")
        end
        if race.name == "Masters 50+"
          categories << Category.find_or_create_by(name: "Men 50+")
          categories << Category.find_or_create_by(name: "Masters Men 50+")
          categories << Category.find_or_create_by(name: "Masters 50+")
        end
        if race.name == "Masters 60+"
          categories << Category.find_or_create_by(name: "Men 60+")
          categories << Category.find_or_create_by(name: "Masters Men 60+")
          categories << Category.find_or_create_by(name: "Masters 60+")
        end
        categories << Category.find_or_create_by(name: "Women 45+") if race.name == "Masters Women 45+"
        categories << Category.find_or_create_by(name: "Stampede") if race.name == "Unicycle"
      else
        categories << Category.find_or_create_by(name: "Masters Men 1/2 40+") if race.name == "Masters 35+ 1/2"
        categories << Category.find_or_create_by(name: "Masters Men 3 40+") if race.name == "Masters 35+ 3"
        if race.name == "Masters 35+ 4"
          categories << Category.find_or_create_by(name: "Masters Men 4 40+")
          categories << Category.find_or_create_by(name: "Men 4 35+")
        end
        if race.name == "Masters 50+"
          categories << Category.find_or_create_by(name: "Men 50+")
          categories << Category.find_or_create_by(name: "Masters Men 50+")
          categories << Category.find_or_create_by(name: "Masters 50+")
        end
        if race.name == "Masters 60+"
          categories << Category.find_or_create_by(name: "Men 60+")
          categories << Category.find_or_create_by(name: "Masters Men 60+")
          categories << Category.find_or_create_by(name: "Masters 60+")
        end
        categories << Category.find_or_create_by(name: "Women 45+") if race.name == "Masters Women 45+"
        categories << Category.find_or_create_by(name: "Stampede") if race.name == "Unicycle"
      end

      categories
    end

    def source_event_types
      [SingleDayEvent, Event, Competitions::BlindDateAtTheDairyOverall]
    end

    def after_source_results(results, _race)
      results.each do |result|
        result["multiplier"] = 1
      end

      results.reject do |result|
        jr_cats = ["Junior Men", "Junior Women", "Junior Men (12-18)", "Junior Women (12-18)"]
        result["category_name"][/Junior/] && !result["category_name"].in?(jr_cats)
      end
    end
  end
end
