# frozen_string_literal: true

# rubocop:disable Rails/Date

module Calculations
  module V3
    module Steps
      module AddMissingResultsPenalty
        def self.calculate!(calculator)
          return calculator.event_categories unless calculator.rules.missing_result_penalty?

          calculator.source_results
                    .group_by(&:participant)
                    .each do |participant, participant_results|
                      next unless missing_results?(participant_results, calculator.rules)

                      event_category = calculator.event_categories.first
                      result = event_category.results.detect { |r| r.participant == participant }
                      result.source_results << add_penalty(participant_results, participant, calculator.rules)
                    end

          calculator.event_categories
        end

        def self.add_penalty(results, participant, rules)
          Calculations::V3::Models::SourceResult.new(
            date: Date.today,
            event_category: results.first.event_category,
            participant: participant,
            place: 100,
            points: missing_results_points(results, rules)
          )
        end

        def self.completed_events(result)
          return 0 unless result
          return 0 unless result.event.parent

          result.event.parent.days.count { |day| day <= Date.today }
        end

        def self.missing_results?(results, rules)
          raise(ArgumentError, "Must set results_per_event if there is a missing_result_penalty") unless rules.results_per_event

          results.count(&:not_rejected?) < rules.results_per_event * completed_events(results.first)
        end

        # 100 points for each "missing" result for every completed event
        def self.missing_results_points(results, rules)
          ((rules.results_per_event * completed_events(results.first)) - results.count(&:not_rejected?)) * 100
        end
      end
    end
  end
end

# rubocop:enable Rails/Date
