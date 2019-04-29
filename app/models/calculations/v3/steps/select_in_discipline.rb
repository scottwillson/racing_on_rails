# frozen_string_literal: true

module Calculations
  module V3
    module Steps
      module SelectInDiscipline
        def self.calculate!(calculator)
          return calculator.event_categories if calculator.rules.disciplines.empty?

          calculator.unrejected_source_results.each do |source_result|
            unless source_result.discipline.in?(calculator.rules.disciplines)
              source_result.reject :discipline
            end
          end

          calculator.event_categories
        end
      end
    end
  end
end
