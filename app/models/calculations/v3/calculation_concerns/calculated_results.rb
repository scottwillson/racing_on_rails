# frozen_string_literal: true

module Calculations::V3::CalculationConcerns::CalculatedResults
  extend ActiveSupport::Concern

  # Take new model results from calculate (graph of EventCategories,
  # CalculatedResults, and SourceResults) and save it to the DB.
  # Inspect existing results. Create, update, or delete. Faster (but more
  # complicated) than wiping out all results and recreating.
  def save_results(event_categories)
    ActiveSupport::Notifications.instrument "save_results.calculations.#{name}.racing_on_rails" do
      event.races.preload(:category)
      delete_obsolete_races event_categories
      create_people_by_id event_categories.flat_map(&:results)
      event_categories.each do |event_category|
        race = create_race(event_category)
        calculated_results = event_category.results
        new_results, existing_results, obsolete_results = partition_results(calculated_results, race)
        create_calculated_results_for new_results, race
        update_calculated_results_for existing_results, race
        delete_calculated_results_for obsolete_results, race
      end
    end

    event_categories
  end

  def partition_results(calculated_results, race)
    participant_ids            = race.results.map(&:person_id)
    calculated_participant_ids = calculated_results.map(&:participant_id)

    new_participant_ids      = calculated_participant_ids - participant_ids
    existing_participant_ids = calculated_participant_ids & participant_ids
    obsolete_participant_ids = participant_ids - calculated_participant_ids

    new_results = calculated_results.select { |r| r.participant_id.in? new_participant_ids }
    existing_results = calculated_results.select { |r| r.participant_id.in? existing_participant_ids }
    obsolete_results = race.results.select { |r| r.person_id.in? obsolete_participant_ids }

    ActiveSupport::Notifications.instrument(
      "partition_results.calculations.#{name}.racing_on_rails " \
      "new_results: #{new_results.size} " \
      "existing_results: #{existing_results.size} " \
      "obsolete_results: #{obsolete_results.size}"
    )

    [new_results, existing_results, obsolete_results]
  end

  def create_race(event_category)
    category = Category.find_or_create_by_normalized_name(event_category.name)
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
        ::ResultSource.where("calculated_result_id in (select id from results where race_id in (?))", race_ids).delete_all
        ::Result.where("race_id in (?)", race_ids).delete_all
      end
      obsolete_races.each { |race| event.races.delete(race) }
    end
  end

  def create_calculated_results_for(results, race)
    Rails.logger.debug "create_calculated_results_for #{race.name}"

    results.each do |result|
      person = @people_by_id[result.participant_id]
      calculated_result = ::Result.create!(
        competition_result: true,
        event: event,
        person: person,
        place: result.place,
        points: result.points,
        race: race,
        rejected: result.rejected?,
        rejection_reason: result.rejection_reason,
        team: person.team
      )

      result.source_results.each do |source_result|
        create_result_source calculated_result, source_result
      end
    end

    true
  end

  def delete_calculated_results_for(results, race)
    Rails.logger.debug "delete_calculated_results_for #{race.name}"
    if results.present?
      ::Result.where(id: results).delete_all
    end
  end

  def update_calculated_results_for(results, race)
    Rails.logger.debug "update_calculation_results_for #{race.name}"
    return true if results.empty?

    existing_results = race.results.where(person_id: results.map(&:participant_id)).includes(:sources)

    results.each do |result|
      update_calculated_result_for result, existing_results
    end
  end

  def update_calculated_result_for(result, existing_results)
    existing_result = existing_results.detect { |r| r.person_id == result.participant_id }

    # Ensure true or false, not nil
    # existing_result.preliminary   = result.preliminary ? true : false
    # to_s important. Otherwise, a change from 3 to "3" triggers a DB update.
    existing_result.place         = result.place.to_s
    existing_result.points        = result.points
    existing_result.team_id       = @people_by_id[result.participant_id].team_id

    # TODO: Why do we need explicit dirty check?
    if existing_result.place_changed? || existing_result.team_id_changed? || existing_result.points_changed? || existing_result.preliminary_changed?
      # Re-use preloaded Team Names
      existing_result.team = @people_by_id[result.participant_id].team
      existing_result.save!
    end

    update_result_sources_for result, existing_result
  end

  def update_result_sources_for(result, existing_result)
    result_sources = result.source_results.map do |source_result|
      new_result_source existing_result, source_result
    end

    sources_to_create = result_sources - existing_result.sources
    sources_to_delete = existing_result.sources - result_sources

    # Delete first because new sources might have same hash
    if sources_to_delete.present?
      ::ResultSource.where(calculated_result_id: existing_result.id)
                    .where(source_result_id: sources_to_delete.map(&:source_result_id))
                    .delete_all
    end

    sources_to_create.each(&:save!)
  end

  def new_result_source(calculated_result, source_result)
    ::ResultSource.new(
      source_result_id: source_result.id,
      calculated_result_id: calculated_result.id,
      points: source_result.points,
      rejection_reason: source_result.rejection_reason
    )
  end

  def create_result_source(calculated_result, source_result)
    new_result_source(calculated_result, source_result).save!
  end

  def create_people_by_id(results)
    @people_by_id = {}

    people = ::Person
             .includes(team: :names)
             .includes(:names)
             .where(id: results.map(&:participant_id).uniq)

    people.find_each do |person|
      @people_by_id[person.id] = person
    end

    @people_by_id
  end
end
