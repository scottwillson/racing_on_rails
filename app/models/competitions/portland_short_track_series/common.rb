module Competitions
  module PortlandShortTrackSeries
    module Common
      extend ActiveSupport::Concern

      included do
        def self.parent_event_name
          "Portland Short Track Series"
        end
      end

      def category_names
        [
          "Category 1 Men 19-34",
          "Category 1 Men 35-44",
          "Category 1 Men 45+",
          "Category 2 Men 35-44",
          "Category 2 Men 45-54",
          "Category 2 Men 55+",
          "Category 2 Men U35",
          "Category 2 Women 35-44",
          "Category 2 Women 45+",
          "Category 2 Women U35",
          "Category 3 Men 10-14",
          "Category 3 Men 15-18",
          "Category 3 Men 19-44",
          "Category 3 Men 45+",
          "Category 3 Women 10-14",
          "Category 3 Women 15-18",
          "Category 3 Women 19+",
          "Clydesdale",
          "Elite Men",
          "Elite/Category 1 Women",
          "Singlespeed"
        ]
      end

      def point_schedule
        [ 100, 80, 60, 50, 45, 40, 36, 32, 29, 26, 24, 22, 20, 18, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ]
      end

      def upgrades
        {
          "Category 2 Men 35-44"   =>   "Category 3 Men 19-44",
          "Category 2 Men 45-54"   =>   "Category 3 Men 45+",
          "Category 2 Men 55+"     =>   "Category 3 Men 45+",
          "Category 2 Men U35"     => [ "Category 3 Men 10-14", "Category 3 Men 15-18" ],
          "Category 2 Women 35-44" =>   "Category 3 Women 19+",
          "Category 2 Women 45+"   =>   "Category 3 Women 19+",
          "Category 2 Women U35"   => [ "Category 3 Women 10-14", "Category 3 Women 15-18", "Category 3 Women 19+" ],
          "Category 1 Men 19-34"   =>   "Category 2 Men U35",
          "Category 1 Men 35-44"   =>   "Category 2 Men 35-44",
          "Category 1 Men 45+"     => [ "Category 2 Men 45-54", "Category 2 Men 55+" ],
          "Elite Men"              => [ "Category 1 Men 19-34", "Category 1 Men 35-44", "Category 1 Men 45+" ],
          "Elite/Category 1 Women" => [ "Category 2 Women 35-44", "Category 2 Women 45+", "Category 2 Women U35" ]
        }
      end
    end
  end
end
