# frozen_string_literal: true

module Calculations::V3::Calculators::Categories
  extend ActiveSupport::Concern

  def best_match_in(category, categories, result_age)
    case rules.group_by
    when "age"
      category.best_match_by_age_in(categories, result_age)
    when "category"
      category.best_match_in(categories, result_age)
    else
      raise "Expected group_by to be :age or :category but is #{rules.group_by.class} #{rules.group_by}"
    end
  end

  def create_event_categories
    if categories?
      categories.map do |category|
        Calculations::V3::Models::EventCategory.new(category)
      end
    elsif team?
      [Calculations::V3::Models::EventCategory.new(Calculations::V3::Models::Category.new("Team"))]
    else
      [Calculations::V3::Models::EventCategory.new(Calculations::V3::Models::Category.new("Calculation"))]
    end
  end

  def find_or_create_event_category(source_result)
    return event_categories.first unless categories?

    category = best_match_in(source_result.category, event_categories.map(&:category), source_result.age)
    event_category = event_categories.find { |c| c.category == category }

    return event_category if event_category

    event_category = Calculations::V3::Models::EventCategory.new(source_result.event_category.category)
    event_category.reject "not_calculation_category"
    event_categories << event_category

    event_category
  end

  def in_calculation_category?(source_result)
    return true unless categories?

    best_match_in(source_result.category, categories, source_result.age).present?
  end
end
