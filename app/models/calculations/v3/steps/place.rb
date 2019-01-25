# frozen_string_literal: true

module Calculations::V3::Steps::Place
  def self.calculate!(calculator)
    calculator.event_categories.each do |category|
      category.results.each do |result|
        result.place = "1"
      end
    end
  end
end
