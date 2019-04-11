# frozen_string_literal: true

module Calculations
  module V3
    module Steps
      module RejectCategories
        def self.calculate!(calculator)
          calculator.event_categories.each do |event_category|
            event_category.source_results.each do |source_result|
              if source_result.category.in?(calculator.rules.rejected_categories)
                source_result.reject :rejected_category
              end
            end

            calculator.event_categories
          end
        end
      end
    end
  end
end
