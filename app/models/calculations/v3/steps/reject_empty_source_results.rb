# frozen_string_literal: true

module Calculations
  module V3
    module Steps
      module RejectEmptySourceResults
        def self.calculate!(calculator)
          calculator.event_categories.each do |category|
            category.results.reject! do |result|
              result.source_results.empty?
            end
          end

          calculator.event_categories
        end
      end
    end
  end
end
