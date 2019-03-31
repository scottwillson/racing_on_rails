# frozen_string_literal: true

module Calculations
  module V3
    module Steps
      module RejectCalculatedEvents
        def self.calculate!(calculator)
          calculator.event_categories.flat_map(&:results).flat_map(&:source_results).each do |source_result|
            if source_result.event.calculated?
              source_result.reject :calculated
            end
          end

          calculator.event_categories
        end
      end
    end
  end
end
