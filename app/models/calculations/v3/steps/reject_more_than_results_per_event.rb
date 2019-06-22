# frozen_string_literal: true

module Calculations
  module V3
    module Steps
      module RejectMoreThanResultsPerEvent
        def self.calculate!(calculator)
          return calculator.event_categories if calculator.rules.results_per_event.nil?

          calculator.source_results
                    .reject { |source_result| source_result.participant.nil? }
                    .group_by { |source_result| [source_result.participant_id, source_result.event] }
                    .each_value do |participant_results|
                      participant_results = participant_results.reject(&:rejected?)
                      next if participant_results.size < calculator.rules.results_per_event

                      start = calculator.rules.results_per_event
                      length = participant_results.size - calculator.rules.results_per_event
                      participant_results.sort_by(&:numeric_place)[start, length].each do |result|
                        result.reject :results_per_event
                      end
                    end

          calculator.event_categories
        end
      end
    end
  end
end
