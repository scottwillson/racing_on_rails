module Competitions
  # Year-long best rider competition for senior men. http://obra.org/oregon_cup
  class OregonCup < Competition
    def friendly_name
      "Oregon Cup"
    end

    def point_schedule
      [ 100, 75, 60, 50, 45, 40, 35, 30, 25, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10 ]
    end

    def source_results_query(race)
      super.
      where("races.category_id" => categories_for(race))
    end

    # Women are often raced together and then scored separately. Combined Women 1/2/3 results count for Oregon Cup.
    # Mark Oregon Cup race by adding "Oregon Cup" to event name, race name, event notes, or race notes.
    def remove_duplicate_results(results)
      results.delete_if do |result|
        results.any? do |other_result|
          result != other_result &&
          result.race_id != other_result.race_id &&
          result.event.root == other_result.event.root &&
          (
            other_result.race.notes.include?("Oregon Cup") ||
            other_result.event.notes.include?("Oregon Cup") ||
            other_result.event.name.include?("Oregon Cup")
          )
        end
      end
    end

    def category_names
      [ "Senior Men" ]
    end

    def source_events?
      true
    end
  end
end
