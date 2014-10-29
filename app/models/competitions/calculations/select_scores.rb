module Competitions
  module Calculations
    module Calculator
      # Select only scores with points and a participant up to +maximum_events+
      def self.select_scores(scores, rules)
        scores_with_points = scores.select { |s| points?(s) }
        if maximum_events?(rules)
          reject_scores_greater_than_maximum_events scores_with_points, rules
        else
          scores_with_points
        end
      end
      
      def self.points?(score)
        score.points && score.points > 0.0 && score.participant_id 
      end
      
      def self.maximum_events?(rules)
        rules[:maximum_events] != UNLIMITED
      end

      def self.reject_scores_greater_than_maximum_events(scores, rules)
        scores.group_by(&:participant_id).
        map do |participant_id, participant_scores|
          slice_of participant_scores, rules[:maximum_events]
        end.
        flatten
      end
      
      def self.slice_of(values, maximum)
        values.sort_by(&:points).reverse[ 0, maximum ]
      end
    end
  end
end
