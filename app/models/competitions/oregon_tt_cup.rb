# frozen_string_literal: true

module Competitions
  # Year-long OBRA TT competition
  class OregonTTCup < Competition
    include Races

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
        "Masters Men 60-69",
        "Masters Men 70+",
        "Masters Women 30-39",
        "Masters Women 40-49",
        "Masters Women 50-59",
        "Masters Women 60-69",
        "Masters Women 70+",
        "Senior Men Pro/1/2",
        "Senior Women 1/2",
        "Tandem"
      ]
    end

    def point_schedule
      [20, 17, 15, 13, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
    end

    def source_events?
      true
    end

    def maximum_events(_)
      8
    end

    def source_results_query(race)
      super
        .where(bar: true)
        .where("events.sanctioned_by" => RacingAssociation.current.default_sanctioned_by)
    end

    def categories_for(race)
      ids = [race.category] + race.category.descendants

      case race.category.name
      when "Senior Men Pro/1/2"
        ["Men Category 1/2", "Senior Men 1/2"]
      when "Category 4/5 Men"
        category_4_5_men_categories
      when "Senior Women 1/2"
        ["Senior Women", "Women Category 1/2"]
      when "Category 4/5 Women"
        ["Women Category 4", "Women Category 4/5"]
      when "Category 3 Women"
        ["Women Category 3"]
      when "Masters Men 40-49"
        ["Masters Men 40-49", "Men 160-199"]
      when "Masters Men 50-59"
        ["Masters Men 50-59", "Men 200-239"]
      when "Masters Men 60-69"
        ["Masters Men 60-69", "Men 240+"]
      when "Masters Women 40-49"
        ["Masters Women 40-49", "Women 160-199"]
      when "Masters Women 50-59"
        ["Masters Women 50-59", "Women 200-239"]
      when "Masters Women 60-69"
        ["Masters Women 60-69", "Women 240+"]
      else
        []
      end.each do |name|
        category = Category.find_by(name: name)
        ids << category if category
      end

      ids
    end

    def category_4_5_men_categories
      [
        "Category 4 Men",
        "Category 4/5",
        "Category 5 Men",
        "Men 4/5",
        "Men Category 4",
        "Men Category 4/5"
      ]
    end

    def after_source_results(results, race)
      results.each do |result|
        result["team_size"] = 1
      end

      if race.name == "Tandem"
        beginning_of_year = Time.zone.local(year).beginning_of_year
        end_of_year = Time.zone.local(year).end_of_year

        results.each do |result|
          result["member_from"] = beginning_of_year
          result["member_to"] = end_of_year
        end
      end

      results
    end
  end
end
