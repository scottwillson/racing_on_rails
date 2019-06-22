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

  def discipline?
    disciplines.any?
  end

  def rules
    @rules ||= Calculations::V3::Rules.new(
      association: Calculations::V3::Models::Association.new(id: RacingAssociation.current.id),
      association_sanctioned_only: association_sanctioned_only,
      category_rules: category_rules,
      disciplines: model_disciplines,
      double_points_for_last_event: double_points_for_last_event?,
      maximum_events: maximum_events,
      members_only: members_only?,
      minimum_events: minimum_events,
      missing_result_penalty: missing_result_penalty,
      most_points_win: most_points_win?,
      points_for_place: points_for_place,
      results_per_event: results_per_event,
      source_events: model_source_events,
      source_event_keys: source_event_keys,
      specific_events: specific_events?,
      team: team?,
      weekday_events: weekday_events?
    )
  end
end
