# frozen_string_literal: true

module Calculations::V3::CalculationConcerns::ResultSources
  extend ActiveSupport::Concern

  def create_result_source(calculated_result, source_result)
    new_result_source(calculated_result, source_result).save!
  end

  def new_result_source(calculated_result, source_result)
    source_result_id = source_result.id || calculated_result.id

    ::ResultSource.new(
      source_result_id: source_result_id,
      calculated_result_id: calculated_result.id,
      points: source_result.points,
      rejection_reason: source_result.rejection_reason,
      rejected: source_result.rejected?
    )
  end

  def update_result_sources(result, existing_result)
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
end
