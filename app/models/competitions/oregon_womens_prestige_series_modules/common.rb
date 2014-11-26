module Competitions
  module OregonWomensPrestigeSeriesModules
    module Common
      # Decreasing points to 20th place, then 2 points for 21st through 100th
      def point_schedule
        [ 100, 80, 70, 60, 55, 50, 45, 40, 35, 30, 25, 20, 18, 16, 14, 12, 10, 8, 6, 4 ] + ([ 2 ] * 80)
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
        [ 21334, 21148, 21393, 21146, 21186 ]
      end
    end
  end
end
