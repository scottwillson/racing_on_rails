# frozen_string_literal: true

module Calculations
  module V3
    module Steps
      module SumPoints
        def self.calculate!(calculator)
          calculator.event_categories.each do |category|
            category.results.each do |result|
              result.points = result.source_results.sum(&:points)
            end
          end
        end
      end
    end
  end
end
