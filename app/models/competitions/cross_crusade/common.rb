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
            "Clydesdale",
            "Elite Junior Men",
            "Elite Junior Women",
            "Junior Men 3/4/5",
            "Junior Women 3/4/5",
            "Junior Men 10-12",
            "Junior Men 13-14",
            "Junior Men 15-16",
            "Junior Men 17-18",
            "Junior Men 9",
            "Junior Women 10-12",
            "Junior Women 13-14",
            "Junior Women 15-16",
            "Junior Women 17-18",
            "Junior Women 9",
            "Masters 35+ 1/2",
            "Masters 35+ 3",
            "Masters 35+ 4",
            "Masters 50+",
            "Masters 60+",
            "Masters 70+",
            "Masters Women 35+ 1/2",
            "Masters Women 35+ 3",
            "Masters Women 50+",
            "Men 1/2",
            "Men 2/3",
            "Men 4",
            "Men 5",
            "Singlespeed Women",
            "Singlespeed",
            "Women 1/2",
            "Women 3",
            "Women 4",
            "Women 5"
          ]
        end
      end

      def members_only?
        false
      end
    end
  end
end
