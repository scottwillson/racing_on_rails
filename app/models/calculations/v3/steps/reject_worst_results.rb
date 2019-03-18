# frozen_string_literal: true

module Calculations
  module V3
    module Steps
      module RejectWorstResults
        def self.calculate!(calculator)
          rules = calculator.rules
          return calculator.event_categories unless rules.reject_worst_results?

          maximum_events = rules.source_events.size - rules.reject_worst_results

          calculator.event_categories.flat_map(&:results).each do |result|
            reject_worst_results result, maximum_events
          end

          calculator.event_categories
        end

        def self.reject_worst_results(result, maximum_events)
          source_results_count = result.source_results.size
          return if source_results_count <= maximum_events

          sorted_source_results = result.source_results.sort_by(&:points).reverse

          sorted_source_results[maximum_events, source_results_count].each do |rejected_result|
            rejected_result.reject :worse_result
          end
        end
      end
    end
  end
end
