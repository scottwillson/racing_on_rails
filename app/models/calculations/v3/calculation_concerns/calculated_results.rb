# frozen_string_literal: true

module Calculations::V3::CalculationConcerns::CalculatedResults
  extend ActiveSupport::Concern

  def changed?(result)
    result.place_changed? ||
      result.points_changed? ||
      result.preliminary_changed? ||
      result.rejected_changed? ||
      result.rejection_reason_changed? ||
      result.team_id_changed?
  end

  def create_calculated_results(results, race)
    Rails.logger.debug { "create_calculated_results #{race.name} #{results.size}" }

    results.each do |result|
      person, team = result_person_and_team(result)

      calculated_result = ::Result.create!(
        competition_result: true,
        event: event,
        person: person,
        place: result.place || "",
        points: result.points,
        race: race,
        rejected: result.rejected?,
        rejection_reason: result.rejection_reason,
        team: team,
        team_competition_result: team?
      )

      result.source_results.each do |source_result|
        create_result_source calculated_result, source_result
      end
    end

    true
  end

  def delete_calculated_results(results, race)
    Rails.logger.debug { "delete_calculated_results #{race.name} #{results.size}" }
    if results.present?
      ::Result.where(id: results, competition_result: true).delete_all
    end
  end

  def participant_id_symbol
    team? ? :team_id : :person_id
  end

  def participant_symbol
    team? ? :team : :person
  end

  def update_calculated_results(results, race)
    Rails.logger.debug { "update_calculated_results #{race.name} #{results.size}" }
    return true if results.empty?

    existing_results = race.results.where(participant_id_symbol => results.map(&:participant_id)).includes(:sources)

    results.each do |result|
      update_calculated_result result, existing_results
    end
  end

  def update_calculated_result(result, existing_results)
    existing_result = existing_results.detect { |r| r[participant_id_symbol] == result.participant_id }

    # Ensure true or false, not nil
    # existing_result.preliminary   = result.preliminary ? true : false
    # to_s important. Otherwise, a change from 3 to "3" triggers a DB update.
    existing_result.place = result.place.to_s
    existing_result.points = result.points
    existing_result.rejected = result.rejected?
    existing_result.rejection_reason = result.rejection_reason
    existing_result.team_id = result_team_id(result)

    if changed?(existing_result)
      # Re-use preloaded Team Names
      existing_result.team = result_team(result)
      existing_result.save!
    end

    update_result_sources result, existing_result
  end
end
