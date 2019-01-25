# frozen_string_literal: true

module Calculations::V3::Steps::AssignPoints
  def self.calculate!(calculator)
    calculator.event_categories.each do |category|
      category.results.each do |result|
        result.source_results.each do |source_result|
          source_result.points = 100
        end
      end
    end
  end
end
