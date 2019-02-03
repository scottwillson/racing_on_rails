# frozen_string_literal: true

module Calculations
  module V3
    module Steps
      module Place
        def self.calculate!(calculator)
          calculator.event_categories.each do |category|
            place = 0
            category.results.sort_by!(&:points).reverse!.each do |result|
              next if category.rejected?

              place += 1
              result.place = place.to_s
            end
          end
        end
      end
    end
  end
end
