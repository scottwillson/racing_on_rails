# frozen_string_literal: true

module Calculations::V3::CalculationConcerns::CalculatedResults
  extend ActiveSupport::Concern

  # Change to generic persist
  # Destroy obsolete races
  def save_results(event_categories)
    ActiveSupport::Notifications.instrument "save_results.calculations.#{name}.racing_on_rails" do
      delete_obsolete_races
      event_categories.each do |event_category|
        # TODO extract to method
        category = Category.find_or_create_by_normalized_name(event_category.name)
        race = event.races.find_or_create_by!(
          category: category,
          rejected: event_category.rejected?,
          rejection_reason: event_category.rejection_reason
        )

        race.destroy_duplicate_results!
        race.results.reload

        calculated_results = event_category.results
        new_results, existing_results, obsolete_results = partition_results(calculated_results, race)
        ActiveSupport::Notifications.instrument "partition_results.calculations.#{name}.racing_on_rails new_results: #{new_results.size} existing_results: #{existing_results.size} obsolete_results: #{obsolete_results.size}"
        create_calculated_results_for new_results, race
        update_calculated_results_for existing_results, race
        delete_calculated_results_for obsolete_results, race
      end
    end

    true
  end

  def partition_results(calculated_results, race)
    participant_ids            = race.results.map(&:person_id)
    calculated_participant_ids = calculated_results.map(&:participant_id)

    new_participant_ids      = calculated_participant_ids - participant_ids
    existing_participant_ids = calculated_participant_ids & participant_ids
    obsolete_participant_ids = participant_ids - calculated_participant_ids

    [
      calculated_results.select { |r| r.participant_id.in?            new_participant_ids },
      calculated_results.select { |r| r.participant_id.in?            existing_participant_ids },
      race.results.select       { |r| r.person_id.in? obsolete_participant_ids }
    ]
  end

  def create_calculated_results_for(results, race)
    Rails.logger.debug "create_calculated_results_for #{race.name}"

    team_ids = team_ids_by_participant_id_hash(results)

    results.each do |result|
      calculated_result = ::Result.create!(
        competition_result: true,
        event: event,
        person_id: result.participant_id,
        place: result.place,
        points: result.points,
        race: race,
        rejected: result.rejected?,
        rejection_reason: result.rejection_reason,
        team_id: team_ids[result.participant_id]
      )

      result.source_results.each do |source_result|
        create_result_source calculated_result, source_result
      end
    end

    true
  end

  def update_calculated_results_for(results, race)
    Rails.logger.debug "update_calculation_results_for #{race.name}"
    return true if results.empty?

    team_ids = team_ids_by_participant_id_hash(results)
    existing_results = race.results.where(person_id: results.map(&:participant_id)).includes(:sources)

    results.each do |result|
      update_calculated_result_for result, existing_results, team_ids
    end
  end

  def update_calculated_result_for(result, existing_results, team_ids)
    existing_result = existing_results.detect { |r| r.person_id == result.participant_id }

    # Ensure true or false, not nil
    # existing_result.preliminary   = result.preliminary ? true : false
    # to_s important. Otherwise, a change from 3 to "3" triggers a DB update.
    existing_result.place         = result.place.to_s
    existing_result.points        = result.points
    existing_result.team_id       = team_ids[result.participant_id]

    # TODO: Why do we need explicit dirty check?
    if existing_result.place_changed? || existing_result.team_id_changed? || existing_result.points_changed? || existing_result.preliminary_changed?
      existing_result.save!
    end

    update_sources_for result, existing_result
  end

  def update_sources_for(result, existing_result)
    # TODO change this to models, not arrays
    # existing_sources = existing_result.sources.map { |s| [s.id, s.points.to_f] }
    # new_sources = result.source_results.map { |s| [s.id || existing_result.id, s.points.to_f] }
    #
    # sources_to_create = new_sources - existing_sources
    # sources_to_delete = existing_sources - new_sources
    #
    # # Delete first because new sources might have same key
    # ::ResultSource.where(calculated_result_id: existing_result.id).where(source_result_id: sources_to_delete.map(&:first)).delete_all if sources_to_delete.present?
    #
    # sources_to_create.each do |source|
    #   create_result_source existing_result, source.first, source.second
    # end
  end

  def delete_calculated_results_for(results, race)
    Rails.logger.debug "delete_calculated_results_for #{race.name}"
    if results.present?
      ::ResultSource.where(calculated_result_id: results).delete_all
      ::Result.where(id: results).delete_all
    end
  end

  def create_result_source(calculated_result, source_result)
    ::ResultSource.create!(
      source_result_id: source_result.id,
      calculated_result_id: calculated_result.id,
      points: source_result.points,
      rejected: source_result.rejected?,
      rejection_reason: source_result.rejection_reason
    )
  end

  def delete_obsolete_races
    ActiveSupport::Notifications.instrument "delete_obsolete_races.calculations.#{name}.racing_on_rails" do
      # TODO consider rejected races, too. Inspect event_categories?
      obsolete_races = event.races.reject { |race| race.name.in?(category_names) }
      logger.debug "delete_obsolete_races.calculations.#{name}.racing_on_rails.obsolete_races race_ids: #{obsolete_races.size} race_names: #{obsolete_races.map(&:name)}"
      if obsolete_races.any?
        race_ids = obsolete_races.map(&:id)
        ::ResultSource.where("calculated_result_id in (select id from results where race_id in (?))", race_ids).delete_all
        ::Result.where("race_id in (?)", race_ids).delete_all
      end
      obsolete_races.each { |race| event.races.delete(race) }
    end
  end

  def team_ids_by_participant_id_hash(results)
    # TODO cache now that this can be called more than once
    team_ids_by_participant_id_hash = {}
    results.map(&:participant_id).uniq.each do |participant_id|
      team_ids_by_participant_id_hash[participant_id] = participant_id
    end

    ::Person.select("id, team_id").where("id in (?)", results.map(&:participant_id).uniq).map do |person|
      team_ids_by_participant_id_hash[person.id] = person.team_id
    end

    team_ids_by_participant_id_hash
  end
end
