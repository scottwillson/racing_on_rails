# frozen_string_literal: true

module Calculations::V3::Steps::MapSourceResultsToResults
  def self.calculate!(calculator)
    calculator.source_results.each do |source_result|
      event_category = calculator.event_categories.find { |c| c.category == source_result.event_category.category }
      raise("Could not find calculated event category in #{calculator.event_categories.map(&:category).flat_map(&:name).sort} for #{source_result.event_category.category.name}") unless event_category

      calculated_result = event_category.results.find { |r| r.participant.id == source_result.participant.id }
      if calculated_result
        calculated_result.source_results << source_result
      else
        event_category.results << Calculations::V3::Models::CalculatedResult.new(
          Calculations::V3::Models::Participant.new(source_result.participant.id),
          [source_result]
        )
      end
    end

    calculator.event_categories
  end
end
