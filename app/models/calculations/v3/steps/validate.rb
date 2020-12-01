# frozen_string_literal: true

module Calculations
  module V3
    module Steps
      module Validate
        def self.calculate!(calculator)
          calculator.results.each do |result|
            next unless result.rejected? && result.placed?

            raise(
              Calculations::V3::ValidationError,
              "Result has place #{result.place} but was rejected with #{result.rejection_reason}"
            )
          end

          calculator.event_categories
        end
      end
    end
  end
end
