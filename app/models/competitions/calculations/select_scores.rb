module Competitions
  module Calculations
    module SelectScores
      # Select only scores with points and a participant up to +maximum_events+
      def select_scores(scores, rules)
        scores_with_points = scores.select { |s| points?(s) }
        if maximum_events?(rules)
          # Upgrades don't count towards maximum events
          # Calculator needs to model results as map keyed by category, not an array,
          # to improve this code
          upgrades = scores_with_points.select { |s| s.upgrade }
          reject_scores_greater_than_maximum_events(scores_with_points.select { |s| !s.upgrade }, rules) +
          upgrades
        else
          scores_with_points
        end
      end

      def points?(score)
        score.points && score.points > 0.0 && score.participant_id
      end

      def maximum_events?(rules)
        rules[:maximum_events] != UNLIMITED
      end

      def reject_scores_greater_than_maximum_events(scores, rules)
        scores.group_by(&:participant_id).
        map do |participant_id, participant_scores|
          slice_of participant_scores, rules[:maximum_events]
        end.
        flatten
      end

      def slice_of(values, maximum)
        values.sort_by(&:points).reverse[ 0, maximum ]
      end
    end
  end
end
