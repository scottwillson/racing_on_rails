# frozen_string_literal: true

module Calculations
  module V3
    module Steps
      module RejectMoreThanMaximumEvents
        def self.calculate!(calculator)
          return calculator.event_categories unless calculator.rules.maximum_events?

          calculator.event_categories.each do |event_category|
            maximum_events = maximum_events(calculator, event_category)
            event_category.results.each do |result|
              reject_more_than_maximum_events result, maximum_events
            end
          end

          calculator.event_categories
        end

        def self.events_count(calculator)
          if calculator.rules.specific_events?
            return calculator.calculations_events.count(&:points?)
          end

          calculator.source_events.count(&:points?)
        end

        def self.maximum_events(calculator, event_category)
          category_rule = calculator.rules.category_rules.detect { |rule| rule.category == event_category.category }
          maximum_events = category_rule&.maximum_events || calculator.rules.maximum_events
          events_count(calculator) + maximum_events
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
