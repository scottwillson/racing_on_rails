module Competitions
  module BlindDateAtTheDairy
    module Common
      extend ActiveSupport::Concern

      included do
        def self.parent_event_name
          "Blind Date at the Dairy"
        end
      end

      def category_names
        if year < 2016
          [
            "Beginner Men",
            "Beginner Women",
            "Junior Men 10-13",
            "Junior Men 14-18",
            "Junior Women 10-13",
            "Junior Women 14-18",
            "Masters Men A 40+",
            "Masters Men B 40+",
            "Masters Men C 40+",
            "Masters Men 50+",
            "Masters Men 60+",
            "Men A",
            "Men B",
            "Men C",
            "Singlespeed",
            "Stampede",
            "Women A",
            "Women B",
            "Women C"
          ]
        else
          [
            "Category 1/2 Men",
            "Category 2/3 Men",
            "Category 3/4 Men",
            "Category 5 Men",
            "Junior Men 14-18",
            "Junior Men 9-13",
            "Junior Women 14-18",
            "Junior Women 9-13",
            "Masters Men 1/2 40+",
            "Masters Men 2/3 40+",
            "Masters Men 3/4 40+",
            "Masters Men 50+",
            "Masters Men 60+",
            "Singlespeed",
            "Stampede",
            "Women 1/2",
            "Women 3",
            "Women 4",
            "Women 5",
          ]
        end
      end

      def point_schedule
        [ 15, 12, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ]
      end

      # Only members can score points?
      def members_only?
        false
      end
    end
  end
end
