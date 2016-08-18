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
            "Athena",
            "Beginner Men",
            "Beginner Women",
            "Category 1/2",
            "Category 3",
            "Category 4",
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
            "Masters 35+ 1/2",
            "Masters 35+ 3",
            "Masters 35+ 4",
            "Masters 50+",
            "Masters 60+",
            "Masters Women 35+ 1/2",
            "Masters Women 35+ 3",
            "Masters Women 45+",
            "Singlespeed Women",
            "Singlespeed",
            "Unicycle",
            "Women 1/2",
            "Women 3",
            "Women 4"
          ]
        end
      end

      def members_only?
        false
      end
    end
  end
end
