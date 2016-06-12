module Competitions
  module OregonWomensPrestigeSeriesModules
    module Common
      def members_only?
        false
      end

      def point_schedule
        [ 25, 21, 18, 16, 14, 12, 10, 8, 7, 6, 5, 4, 3, 2, 1 ]
      end

      def set_multiplier(results)
        results.each do |result|
          if result["type"] == "MultiDayEvent"
            result["multiplier"] = 1.5
          else
            result["multiplier"] = 1
          end
        end
      end

      def cat_123_only_event_ids
        []
      end

      def upgrades
        {
          "Women 3" => "Women 4/5",
          "Women 1/2" => "Women 3"
        }
      end
    end
  end
end
