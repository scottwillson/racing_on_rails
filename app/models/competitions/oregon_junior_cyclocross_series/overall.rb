# frozen_string_literal: true

module Competitions
  module OregonJuniorCyclocrossSeries
    class Overall < Competition
      include Races

      def friendly_name
        "Oregon Junior Cyclocross Series"
      end

      def point_schedule
        [30, 28, 26, 24, 22, 20, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
      end

      def members_only?
        false
      end

      def category_names
        [
          "Junior Men 1/2/3",
          "Junior Men 13-14 3/4/5",
          "Junior Men 15-16 3/4/5",
          "Junior Men 17-18 3/4/5",
          "Junior Men 9-12 3/4/5",
          "Junior Women 1/2/3",
          "Junior Women 13-14 3/4/5",
          "Junior Women 15-16 3/4/5",
          "Junior Women 17-18 3/4/5",
          "Junior Women 9-12 3/4/5"
        ]
      end

      def categories_clause(race)
        if race.category.ability_begin == 3
          Category
            .where(ages_begin: race.category.ages_begin)
            .where(ages_end: race.category.ages_end)
            .where(gender: race.category.gender)
        else
          Category
            .where(ability_begin: race.category.ability_begin)
            .where(ability_end: race.category.ability_end)
            .where(ages_begin: race.category.ages_begin)
            .where(ages_end: race.category.ages_end)
            .where(gender: race.category.gender)
        end
      end

      def maximum_events(_)
        4
      end

      def source_events?
        true
      end

      def create_slug
        "ojcs"
      end
    end
  end
end
