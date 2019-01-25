# frozen_string_literal: true

module Calculations::V3::Steps::MapCategoriesToEventCategories
  def self.calculate!(calculator)
    calculator.rules.categories.map do |category|
      Calculations::V3::Models::EventCategory.new(category)
    end
  end
end
