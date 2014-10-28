module Competitions
  module Calculations
    module Calculator
      # Select only scores with points and a participant up to +maximum_events+
      def self.select_scores(scores, rules)
        scores_with_points = scores.select { |s| s.points && s.points > 0.0 && s.participant_id }
        reject_scores_greater_than_maximum_events(scores_with_points, rules)
      end

      def self.reject_scores_greater_than_maximum_events(scores, rules)
        if rules[:maximum_events] == UNLIMITED
          scores
        else
          scores.group_by(&:participant_id).
          map do |participant_id, participant_scores|
            participant_scores.sort_by(&:points).reverse[ 0, rules[:maximum_events] ]
          end.
          flatten
        end
      end
    end
  end
end
