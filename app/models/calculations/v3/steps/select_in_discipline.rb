# frozen_string_literal: true

module Calculations
  module V3
    module Steps
      module SelectInDiscipline
        def self.calculate!(calculator)
          return calculator.event_categories if calculator.rules.disciplines.empty?

          calculator.event_categories.each do |category|
            category.results.each do |result|
              result.source_results.select! do |source_result|
                raise(ArgumentError, "Discipline required") unless source_result.discipline

                source_result.discipline.in?(calculator.rules.disciplines)
              end
            end
          end

          calculator.event_categories
        end
      end
    end
  end
end
