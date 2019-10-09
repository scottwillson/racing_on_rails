# frozen_string_literal: true

module Competitions
  module CrossCrusade
    module Common
      extend ActiveSupport::Concern

      def category_names
        if year < 2016
          [
            "Athena",
            "Beginner Men",
            "Beginner Women",
            "Category A",
            "Category B",
            "Category C",
            "Clydesdale",
            "Junior Men 10-12",
            "Junior Men 13-14",
            "Junior Men 15-16",
            "Junior Men 17-18",
            "Junior Men",
            "Junior Women 10-12",
            "Junior Women 13-14",
            "Junior Women 15-16",
            "Junior Women 17-18",
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
        else
          [
            "Athenas",
            "Category 1/2 Masters 35+ Men",
            "Category 1/2 Masters 35+ Women",
            "Category 1/2 Men",
            "Category 1/2 Women",
            "Category 1/2/3 Junior Men",
            "Category 1/2/3 Junior Women",
            "Category 2/3 Men",
            "Category 2/3 Women",
            "Category 3 Masters 35+ Men",
            "Category 3 Masters 35+ Women",
            "Category 3/4/5 Junior Men",
            "Category 3/4/5 Junior Women",
            "Category 4 Masters Men 35+",
            "Category 4 Men",
            "Category 4 Women",
            "Category 5 Men",
            "Category 5 Women",
            "Clydesdale",
            "Masters 50+ Men",
            "Masters 50+ Women",
            "Masters 60+ Men",
            "Masters 60+ Women",
            "Masters 70+ Men",
            "Singlespeed Men",
            "Singlespeed Women"
          ]
        end
      end

      def members_only?
        false
      end
    end
  end
end
