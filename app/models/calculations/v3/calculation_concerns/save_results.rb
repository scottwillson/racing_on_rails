# frozen_string_literal: true

module Calculations::V3::CalculationConcerns::SaveResults
  extend ActiveSupport::Concern

  # Divide results into three groups: new to be created, existing to be updated, and obsolete to be deleted
  def partition_results(calculated_results, race)
    participant_ids            = race.results.map(&participant_id_symbol)
    calculated_participant_ids = calculated_results.map(&:participant_id)

    new_participant_ids      = calculated_participant_ids - participant_ids
    existing_participant_ids = calculated_participant_ids & participant_ids
    obsolete_participant_ids = participant_ids - calculated_participant_ids

    new_results = calculated_results.select { |r| r.participant_id.in? new_participant_ids }
    existing_results = calculated_results.select { |r| r.participant_id.in? existing_participant_ids }
    obsolete_results = race.results.select { |r| r[participant_id_symbol].in? obsolete_participant_ids }

    ActiveSupport::Notifications.instrument(
      "partition_results.calculations.#{name}.racing_on_rails " \
      "new_results: #{new_results.size} " \
      "existing_results: #{existing_results.size} " \
      "obsolete_results: #{obsolete_results.size}"
    )

    [new_results, existing_results, obsolete_results]
  end

  # Take new model results from calculate (graph of EventCategories,
  # CalculatedResults, and SourceResults) and save it to the DB.
  # Inspect existing results. Create, update, or delete. Faster (but more
  # complicated) than wiping out all results and recreating.
  def save_results(event_categories)
    ActiveSupport::Notifications.instrument "save_results.calculations.#{name}.racing_on_rails" do
      populate_people event_categories.flat_map(&:results)
      populate_teams event_categories.flat_map(&:results)

      event.races.preload(:category)
      delete_obsolete_races event_categories

      transaction do
        event_categories.each do |event_category|
          race = create_race(event_category)
          calculated_results = event_category.results
          new_results, existing_results, obsolete_results = partition_results(calculated_results, race)
          create_calculated_results new_results, race
          update_calculated_results existing_results, race
          delete_calculated_results obsolete_results, race
        end
      end
    end

    event_categories
  end
end
