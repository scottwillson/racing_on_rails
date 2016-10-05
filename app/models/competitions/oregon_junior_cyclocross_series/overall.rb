module Competitions
  module OregonJuniorCyclocrossSeries
    class Overall < Competition
      def friendly_name
        "Oregon Junior Cyclocross Series"
      end

      def point_schedule
        [ 30, 28, 26, 24, 22, 20, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ]
      end

      def members_only?
        false
      end

      def category_names
        [
          "Junior Men 9-12",
          "Junior Men 13-14",
          "Junior Men 15-16",
          "Junior Men 17-18",
          "Elite Junior Men",
          "Junior Men 3/4/5",
          "Junior Women 9-12",
          "Junior Women 13-14",
          "Junior Women 15-16",
          "Junior Women 17-18",
          "Elite Junior Women",
          "Junior Women 3/4/5"
        ]
      end

      def categories_for(race)
        categories = result_categories_by_race[race.category]

        if race.category.abilities == (0..0) || race.category.abilities == (3..5)
          categories.reject do |category|
            category.ages == (10..12) || category.ages == (9..9) || category.ages == (9..12)
          end
        elsif race.category.ages_begin == 9
          Category.where(ages_begin: 9, ages_end: 9).where(gender: race.category.gender) +
            Category.where(ages_begin: 10, ages_end: 12).where(gender: race.category.gender) +
            Category.where(ages_begin: 9, ages_end: 12).where(gender: race.category.gender)
        else
          categories
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
