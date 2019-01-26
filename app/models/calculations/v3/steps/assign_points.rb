# frozen_string_literal: true

module Calculations::V3::Steps::AssignPoints
  def self.calculate!(calculator)
    calculator.event_categories.each do |category|
      category.results.each do |result|
        result.source_results.each do |source_result|
          source_result.points = points_for_place(source_result, calculator.rules.points_for_place)
        end
      end
    end
  end

  def self.points_for_place(source_result, points_for_place)
    return 1 unless points_for_place

    points_for_place[source_result.numeric_place - 1]
  end
end
