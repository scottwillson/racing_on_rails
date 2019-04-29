# frozen_string_literal: true

module Calculations
  module V3
    module Steps
      module RejectDnfs
        def self.calculate!(calculator)
          calculator.unrejected_source_results.each do |source_result|
            if source_result.dnf?
              source_result.reject :dnf
            end
          end

          calculator.event_categories
        end
      end
    end
  end
end
