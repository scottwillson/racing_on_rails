# frozen_string_literal: true

module Calculations::V3::CalculationConcerns::Races
  extend ActiveSupport::Concern

  def create_race(event_category)
    category = ::Category.find_or_create_by_normalized_name(event_category.name)
    race = event.races.find_or_create_by!(
      category: category,
      rejected: event_category.rejected?,
      rejection_reason: event_category.rejection_reason
    )
    race.destroy_duplicate_results!
    race.results.reload
    race
  end

  def delete_obsolete_races(event_categories)
    ActiveSupport::Notifications.instrument "delete_obsolete_races.calculations.#{name}.racing_on_rails" do
      category_names = event_categories.map(&:name)
      obsolete_races = event.races.reject { |race| race.name.in?(category_names) }

      logger.debug(
        "delete_obsolete_races.calculations.#{name}.racing_on_rails.obsolete_races " \
        "race_ids: #{obsolete_races.size} " \
        "race_names: #{obsolete_races.map(&:name)}"
      )

      if obsolete_races.any?
        race_ids = obsolete_races.map(&:id)
        ::ResultSource.where("calculated_result_id in (select id from results where race_id in (?) and competition_result is true)", race_ids).delete_all
        ::Result.where(race_id: race_ids, competition_result: true).delete_all
      end
      obsolete_races.each { |race| event.races.delete(race) }
    end
  end
end
