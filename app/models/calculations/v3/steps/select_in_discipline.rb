# frozen_string_literal: true

module Calculations
  module V3
    module Steps
      module SelectInDiscipline
        def self.calculate!(calculator)
          return calculator.event_categories unless calculator.rules.discipline

          calculator.event_categories.flat_map(&:results).flat_map(&:source_results).each do |source_result|
            if source_result.discipline != calculator.rules.discipline
              source_result.reject :discipline
            end
          end

          calculator.event_categories
        end
      end
    end
  end
end
