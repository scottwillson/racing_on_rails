# frozen_string_literal: true

# Factory to create new Calculation for each year
class Calculations::V3::Year
  def self.create!(attributes = {})
    key = attributes[:key]
    year = attributes[:year] || RacingAssociation.current.effective_year
    raise(ArgumentError, "key must be present") if key.blank?
    return if Calculations::V3::Calculation.exists?(key: key, year: year)

    previous_calculation = Calculations::V3::Calculation.latest(key)
    raise(ActiveRecord::RecordNotFound, "No previous Calculation with key '#{key}'") unless previous_calculation

    Calculations::V3::Calculation.transaction do
      previous_calculation.source_event_keys.each do |source_event_key|
        Calculations::V3::Year.create!(key: source_event_key, year: year)
      end

      calculation = create_calculation(previous_calculation, key, year)
      create_categories(calculation, previous_calculation)

      previous_calculation.disciplines.each do |discipline|
        calculation.disciplines << discipline
      end

      calculation
    end
  end

  def self.create_calculation(previous_calculation, key, year)
    Calculations::V3::Calculation.create!(
      association_sanctioned_only: previous_calculation.association_sanctioned_only?,
      discipline_id: previous_calculation.discipline_id,
      double_points_for_last_event: previous_calculation.double_points_for_last_event?,
      event_notes: previous_calculation.event_notes,
      field_size_bonus: previous_calculation.field_size_bonus,
      group_by: previous_calculation.group_by,
      group: previous_calculation.group,
      key: key,
      maximum_events: previous_calculation.maximum_events,
      members_only: previous_calculation.members_only?,
      minimum_events: previous_calculation.minimum_events,
      missing_result_penalty: previous_calculation.missing_result_penalty,
      name: previous_calculation.name,
      place_by: previous_calculation.place_by,
      points_for_place: previous_calculation.points_for_place,
      results_per_event: previous_calculation.results_per_event,
      show_zero_point_source_results: previous_calculation.show_zero_point_source_results,
      source_event_keys: previous_calculation.source_event_keys,
      specific_events: previous_calculation.specific_events?,
      team: previous_calculation.team?,
      weekday_events: previous_calculation.weekday_events?,
      year: year
    )
  end

  def self.create_categories(calculation, previous_calculation)
    previous_calculation.calculation_categories.each do |previous_category|
      calculations_category = calculation.calculation_categories.create!(
        category_id: previous_category.category_id,
        maximum_events: previous_category.maximum_events,
        reject: previous_category.reject?,
        source_only: previous_category.source_only?
      )
      previous_category.mappings.each do |previous_mapping|
        calculations_category.mappings.create!(
          category_id: previous_mapping.category_id,
          discipline_id: previous_mapping.discipline_id
        )
      end
    end
  end
end
