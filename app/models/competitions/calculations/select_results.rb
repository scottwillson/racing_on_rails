module Competitions
  module Calculations
    module SelectResults
      # Apply rules. Example: DNS or numeric place? Person is a member for this year?
      # It's somewhat arbritrary which elgilibilty rules are applied here, and which were applied by
      # the calling Competition when it selected results from the database.
      # Only keep best +results_per_event+ results for participant (person or team).
      def select_results(results, rules)
        results = results.select { |r| r.participant_id && ![ nil, "", "DQ", "DNS" ].include?(r.place) }

        if rules[:dnf_points].nil? || rules[:dnf_points] == 0
          results = results.reject { |r| r.place == "DNF" }
        end

        if rules[:members_only]
          results = results.select { |r| member_in_year?(r, rules[:team]) }
        end

        if rules[:source_event_ids]
          results = results.select { |r| r.upgrade || rules[:source_event_ids].include?(r.event_id) }
        end
        results = select_results_for(:event_id, results, rules[:results_per_event], rules[:use_source_result_points])
        results = select_results_for(:race_id, results, rules[:results_per_race], rules[:use_source_result_points])
        select_results_for_minimum_events results, rules
      end

      def select_results_for(field, results, limit, use_source_result_points)
        if limit == UNLIMITED
          results
        else
          results.group_by { |r| [ r.participant_id, r[field] ] }.
          map do |key, r|
            if use_source_result_points
              r.sort_by { |r2| r2.points }.reverse.take(limit)
            else
              r.sort_by { |r2| numeric_place(r2) }.take(limit)
            end
          end.
          flatten
        end
      end

      def member_in_year?(result, team = false)
        raise(ArgumentError, "Result year required to check membership") unless result.year

        if team
          result.team_member
        else
          result.member_from &&
          result.member_to &&
          result.member_from.year <= result.year &&
          result.member_to.year >= result.year
        end
      end

      def select_results_for_minimum_events(results, rules)
        if rules[:minimum_events].nil? || !event_complete?(rules)
          return results
        end

        results.group_by(&:participant_id).
        select do |participant_id, participant_results|
          participant_results.size >= rules[:minimum_events]
        end.
        values.
        flatten
      end
    end
  end
end
