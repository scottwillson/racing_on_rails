module Competitions
  module Calculations
    module Calculator
      # Apply rules. Example: DNS or numeric place? Person is a member for this year?
      # It's somewhat arbritrary which elgilibilty rules are applied here, and which were applied by
      # the calling Competition when it selected results from the database.
      # Only keep best +results_per_event+ results for participant (person or team).
      def self.select_results(results, rules)
        results = results.select { |r| r.participant_id && ![ nil, "", "DQ", "DNS" ].include?(r.place) }

        if rules[:members_only] && rules[:team]
          results = results.select(&:team_member)
        end

        if rules[:members_only]
          results = results.select { |r| member_in_year?(r) }
        end

        if rules[:source_event_ids]
          results = results.select { |r| rules[:source_event_ids].include? r.event_id }
        end

        results = select_results_for_event(results, rules[:results_per_event])
        select_results_for_race(results, rules[:results_per_race])
      end

      def self.select_results_for_event(results, results_per_event)
        if results_per_event == UNLIMITED
          results
        else
          results.group_by { |r| [ r.participant_id, r.event_id ] }.
          map do |key, r|
            r.sort_by { |r2| numeric_place(r2) }[0, results_per_event]
          end.
          flatten
        end
      end

      def self.select_results_for_race(results, results_per_race)
        if results_per_race == UNLIMITED
          results
        else
          results.group_by { |r| [ r.participant_id, r.race_id ] }.
          map do |key, r|
            r.sort_by { |r2| numeric_place(r2) }[0, results_per_race]
          end.
          flatten
        end
      end

      def self.member_in_year?(result)
        raise(ArgumentError, "Result year required to check membership") unless result.year
        result.member_from && result.member_to && result.member_from.year <= result.year && result.member_to.year >= result.year
      end
    end
  end
end
