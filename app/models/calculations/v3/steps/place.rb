# frozen_string_literal: true

module Calculations::V3::Steps::Place
  def self.calculate!(calculator)
    calculator.event_categories.each do |category|
      place = 0
      category.results.each do |result|
        place += 1
        result.place = place.to_s
      end
    end
  end
end
