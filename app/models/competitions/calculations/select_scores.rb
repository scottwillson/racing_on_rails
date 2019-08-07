# frozen_string_literal: true

module Competitions
  module Calculations
    module SelectScores
      # Select only scores with points and a participant up to +maximum_events+
      def select_scores(scores, rules)
        selected_scores = scores.select { |s| points?(s) && s.participant_id }

        if maximum_events?(rules)
          # Upgrades don't count towards maximum events
          # Calculator needs to model results as map keyed by category, not an array,
          # to improve this code
          upgrades = selected_scores.select(&:upgrade)
          upgrades = limit_upgrades(upgrades, rules[:maximum_upgrade_results], rules[:use_source_result_points])
          reject_scores_greater_than_maximum_events(selected_scores.reject(&:upgrade), rules) + upgrades
        else
          selected_scores
        end
      end

      def points?(score)
        score.points && score.points > 0.0
      end

      # Apply maximum_upgrade_results
      def limit_upgrades(upgrades, limit, use_source_result_points)
        if limit == UNLIMITED
          upgrades
        else
          upgrades.group_by(&:participant_id)
                  .map do |_participant_id, participant_upgrades|

            puts(participant_upgrades.size) if participant_upgrades.size > 0

            if use_source_result_points
              participant_upgrades = participant_upgrades.sort_by(&:points).reverse
            else
              participant_upgrades = participant_upgrades.sort_by { |r| numeric_place(r) }
            end

            if participant_upgrades.size > limit
              participant_upgrades = participant_upgrades.first(limit)
            end

            category_results + upgrades
          end
                 .flatten
        end
      end

      def maximum_events?(rules)
        rules[:maximum_events] != UNLIMITED
      end

      def reject_scores_greater_than_maximum_events(scores, rules)
        scores.group_by(&:participant_id)
              .map do |_participant_id, participant_scores|
          slice_of participant_scores, rules[:maximum_events]
        end
              .flatten
      end

      def slice_of(scores, maximum)
        scores
          .group_by(&:event_id)
          .sort_by { |_, event_scores| date_and_points(event_scores) }
          .reverse[ 0, maximum ]
          .map(&:last)
      end

      def date_and_points(scores)
        [scores.map(&:points).reduce(&:+), scores.first.date]
      end
    end
  end
end
