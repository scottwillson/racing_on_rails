# frozen_string_literal: true

module Calculations
  module V3
    module Steps
      module RejectEmptyCategories
        def self.calculate!(calculator)
          calculator.event_categories.reject do |event_category|
            event_category.results.empty? && !event_category.category.in?(calculator.categories)
          end
        end
      end
    end
  end
end
