# frozen_string_literal: true

module Calculations::V3::Steps::MapSourceResultsToResults
  def self.calculate!(calculator)
    calculator.source_results.each do |source_result|
      event_category = calculator.event_categories.first
      # This short-circuit will go away once we actually match categories
      return calculator.event_categories unless event_category

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
