# frozen_string_literal: true

module Calculations
  module V3
    module Steps
      module MapSourceResultsToResults
        # Put source results in "best" calculated event category.
        # Unmatched categories are added, too, for audit, but will be given no points
        def self.calculate!(calculator)
          calculator.source_results.each do |source_result|
            unless calculator.rules.categories.include?(source_result.category)
              source_result.reject
            end

            event_category = find_or_create_event_category(source_result, calculator)

            calculated_result = event_category.results.find { |r| r.participant.id == source_result.participant.id }
            if calculated_result
              calculated_result.source_results << source_result
            else
              event_category.results << Models::CalculatedResult.new(
                Models::Participant.new(source_result.participant.id),
                [source_result]
              )
            end
          end

          calculator.event_categories
        end

        def self.find_or_create_event_category(source_result, calculator)
          event_category = calculator.event_categories.find { |c| c.category == source_result.category }
          return event_category if event_category

          event_category = Models::EventCategory.new(source_result.event_category.category)
          calculator.event_categories << event_category

          event_category
        end
      end
    end
  end
end
