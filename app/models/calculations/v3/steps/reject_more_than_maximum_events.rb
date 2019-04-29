# frozen_string_literal: true

module Calculations
  module V3
    module Steps
      module RejectMoreThanMaximumEvents
        def self.calculate!(calculator)
          rules = calculator.rules
          return calculator.event_categories unless rules.maximum_events?

          calculator.event_categories.each do |event_category|
            maximum_events = maximum_events(rules, event_category)
            event_category.results.each do |result|
              reject_more_than_maximum_events result, maximum_events
            end
          end

          calculator.event_categories
        end

        def self.maximum_events(rules, event_category)
          category_rule = rules.category_rules.detect { |rule| rule.category == event_category.category }
          maximum_events = category_rule&.maximum_events || rules.maximum_events
          rules.source_events.size + maximum_events
        end

        def self.reject_more_than_maximum_events(result, maximum_events)
          source_results_count = result.unrejected_source_results.size
          return if source_results_count <= maximum_events

          sorted_source_results = result.unrejected_source_results.sort_by(&:points).reverse

          sorted_source_results[maximum_events, source_results_count]&.each do |rejected_result|
            rejected_result.reject :worse_result
          end
        end
      end
    end
  end
end
