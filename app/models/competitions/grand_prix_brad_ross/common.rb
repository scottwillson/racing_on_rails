module Competitions
  module GrandPrixBradRoss
    module Common
      extend ActiveSupport::Concern

      included do
        def self.parent_event_name
          "GPCM"
        end
      end

      # Remove Junior age-group categories
      def after_source_results(results, race)
        results.reject do |result|
          result["category_name"]["Junior"] &&
          result["category_ages_begin"] &&
          (
            result["category_ages_begin"] > ::Categories::Ages::JUNIORS.begin ||
            result["category_ages_end"] < ::Categories::Ages::JUNIORS.end
          )
        end
      end

      def category_names
        [
          "Athena",
          "Category 1/2 35+ Men",
          "Category 1/2 35+ Women",
          "Category 1/2 Men",
          "Category 1/2 Women",
          "Category 2/3 Men",
          "Category 3 35+ Men",
          "Category 3 35+ Women",
          "Category 3 Women",
          "Category 4 35+ Men",
          "Category 4 Men",
          "Category 4 Women",
          "Category 5 Men",
          "Category 5 Women",
          "Clydesdale",
          "Elite Junior Men",
          "Elite Junior Women",
          "Junior Men 3/4/5",
          "Junior Women 3/4/5",
          "Masters 50+ Men",
          "Masters 50+ Women",
          "Masters 60+ Men",
          "Singlespeed Men",
          "Singlespeed Women"
        ]
      end

      def point_schedule
        [ 100, 80, 60, 50, 45, 40, 36, 32, 29, 26, 24, 22, 20, 18, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ]
      end
    end
  end
end
