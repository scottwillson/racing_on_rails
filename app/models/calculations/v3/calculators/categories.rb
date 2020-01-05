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

    source_result_category = source_result.event_category.category

    # Override like Men 2/3 => Men 3
    calculation_category = rules.category_rules.detect do |category_rule|
      source_result_category.in? category_rule.matches
    end

    # Matches a calculation category
    calculation_category ||= best_match_in(source_result.category, categories, source_result.racing_age)
    return event_categories.find { |c| c.category == calculation_category } if calculation_category

    # Event has this category
    event_category = event_categories.find { |c| c.category == source_result_category }
    return event_category if event_category

    # New category that doesn't match any existing category
    event_category = Calculations::V3::Models::EventCategory.new(source_result_category)
    event_category.reject "not_calculation_category"
    event_categories << event_category

    event_category
  end

  def in_calculation_category?(category, result_age)
    return true unless categories?
    return false if rules.group_by == "age" && !category.age_group?

    best_match = best_match_in(category, categories, result_age)
    best_match.present?
  end
end
