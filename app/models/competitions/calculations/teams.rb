module Competitions
  module Calculations
    module Teams
      def team_races(results)
        results.group_by(&:race_id).select do |race_id, race_results|
          team_race? race_results
        end.
        keys
      end

      def team_race?(results)
        teams(results) / unique_places(results) < 0.5
      end

      def unique_places(results)
        results.map(&:place).uniq.size.to_f
      end

      def teams(results)
        results.group_by(&:place).values.select { |r| r.size > 1 }.size
      end
    end
  end
end
