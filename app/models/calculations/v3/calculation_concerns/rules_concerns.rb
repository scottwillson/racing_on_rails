# frozen_string_literal: true

module Calculations::V3::CalculationConcerns::RulesConcerns
  extend ActiveSupport::Concern

  # Map ActiveRecord records to Calculations::V3::Models so Calculator can calculate! them.
  # Categories are a subset of "rules."
  def category_rules
    calculation_categories.map do |calculation_category|
      category = Calculations::V3::Models::Category.new(calculation_category.category.name)
      Calculations::V3::Models::CategoryRule.new(
        category,
        maximum_events: calculation_category.maximum_events,
        reject: calculation_category.reject?
      )
    end
  end

  def rules
    @rules ||= Calculations::V3::Rules.new(
      category_rules: category_rules,
      discipline: model_discipline,
      double_points_for_last_event: double_points_for_last_event?,
      minimum_events: minimum_events,
      points_for_place: points_for_place,
      maximum_events: maximum_events,
      source_events: model_source_events,
      weekday_events: weekday_events?
    )
  end
end
