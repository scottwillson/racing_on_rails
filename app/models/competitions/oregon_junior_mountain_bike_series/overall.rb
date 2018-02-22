# frozen_string_literal: true

module Competitions
  module OregonJuniorMountainBikeSeries
    class Overall < Competition
      def friendly_name
        "Oregon Junior Mountain Bike Series"
      end

      def point_schedule
        [30, 28, 26, 24, 22, 20, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
      end

      def members_only?
        false
      end

      def category_names
        [
          "Category 3 Junior Men 10-13",
          "Category 3 Junior Men 14-18",
          "Category 3 Junior Women 10-13",
          "Category 3 Junior Women 14-18",
          "Junior Expert Men",
          "Junior Expert Women"
        ]
      end

      def categories_clause(race)
        if race.category.abilities == (0..0)
          Category.where(ages_begin: 9, ages_end: 18, gender: race.category.gender, ability_begin: 0, ability_end: 0)
        else
          Category
            .where(gender: race.category.gender)
            .where("(ability_begin = 3 and ability_end = 5) or (ability_begin = 0 and ability_end = 999)")
            .where("ages_begin >= ?", race.category.ages_begin)
            .where("ages_end <= ?", race.category.ages_end)
        end
      end

      def maximum_events(_)
        3
      end

      def source_events?
        true
      end

      def create_slug
        "ojmtbs"
      end
    end
  end
end
