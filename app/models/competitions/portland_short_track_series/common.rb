# frozen_string_literal: true

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
          "Category 1 Men U45",
          "Category 1 Men 45+",
          "Category 2 Men 40-49",
          "Category 2 Men 50-59",
          "Category 2 Men 60+",
          "Category 2 Men U40",
          "Category 2 Women 45+",
          "Category 2 Women U45",
          "Category 3 Men 10-13",
          "Category 3 Men 14-18",
          "Category 3 Men 19-39",
          "Category 3 Men 40-49",
          "Category 3 Men 50+",
          "Category 3 Women 10-13",
          "Category 3 Women 14-18",
          "Category 3 Women 19+",
          "Clydesdale",
          "Elite Men",
          "Elite/Category 1 Women",
          "Singlespeed"
        ]
      end

      def point_schedule
        [100, 80, 60, 50, 45, 40, 36, 32, 29, 26, 24, 22, 20, 18, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
      end

      def upgrades
        {
          "Category 2 Men U40" => ["Category 3 Men 10-13", "Category 3 Men 14-18", "Category 3 Men 19-39"],
          "Category 2 Men 40-49" => ["Category 3 Men 40-49", "Category 3 Men 50+"],
          "Category 2 Men 50-59" => "Category 3 Men 50+",
          "Category 2 Men 60+" => "Category 3 Men 50+",
          "Category 2 Women U45" => ["Category 3 Women 10-13", "Category 3 Women 14-18", "Category 3 Women 19+"],
          "Category 2 Women 45+" => "Category 3 Women 19+",
          "Category 1 Men U45" => ["Category 2 Men 40-49", "Category 2 Men U40"],
          "Category 1 Men 45+" => ["Category 2 Men 40-49", "Category 2 Men 50-59", "Category 2 Men 60+"],
          "Elite Men" => ["Category 1 Men U45", "Category 1 Men 45+"],
          "Elite/Category 1 Women" => ["Category 2 Women 45+", "Category 2 Women U45"]
        }
      end
    end
  end
end
