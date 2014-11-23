module Competitions
  module Calculations
    module Teams
      def team_race?(race_id, results)
        teams(race_id, results) / unique_places(race_id, results) < 0.5
      end

      def unique_places(race_id, results)
        results.select { |r| r.race_id == race_id }.map(&:place).uniq.size.to_f
      end

      def teams(race_id, results)
        results.select { |r| r.race_id == race_id }.group_by(&:place).values.select { |r| r.size > 1 }.size
      end
    end
  end
end
