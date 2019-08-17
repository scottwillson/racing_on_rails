# frozen_string_literal: true

module Calculations
  module V3
    module Steps
      module RejectAllSourceResultsRejected
        def self.calculate!(calculator)
          calculator.unrejected_results.each do |result|
            if result.source_results.all?(&:rejected?)
              result.reject :no_source_results
            end
          end

          calculator.event_categories
        end
      end
    end
  end
end
