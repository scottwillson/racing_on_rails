# frozen_string_literal: true

module Calculations
  module V3
    module Steps
      module RejectBelowMinimumEvents
        def self.calculate!(calculator)
          calculator.event_categories.flat_map(&:results).each do |result|
            if result.source_results.size < calculator.rules.minimum_events
              result.reject :below_minimum_events
            end
          end

          calculator.event_categories
        end
      end
    end
  end
end
