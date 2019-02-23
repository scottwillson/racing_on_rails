# frozen_string_literal: true

module Calculations
  module V3
    module Steps
      module MapSourceResultsToResults
        # Put source results in "best" calculated event category.
        # Unmatched categories are added, too, for audit, but will be given no points
        def self.calculate!(calculator)
          calculator.source_results.each do |source_result|
            source_result_in_calculation_category = in_calculation_category?(source_result, calculator)
            unless source_result_in_calculation_category
              source_result.reject "not_calculation_category"
            end

            event_category = find_or_create_event_category(source_result, calculator)

            calculated_result = event_category.results.find { |r| r.participant.id == source_result.participant.id }
            if calculated_result
              calculated_result.source_results << source_result
            else
              calculated_result = Models::CalculatedResult.new(
                Models::Participant.new(source_result.participant.id),
                [source_result]
              )
              unless source_result_in_calculation_category
                calculated_result.reject "not_calculation_category"
              end

              event_category.results << calculated_result
            end
          end

          calculator.event_categories
        end

        def self.find_or_create_event_category(source_result, calculator)
          category = source_result.category.best_match_in(calculator.event_categories.map(&:category))
          event_category = calculator.event_categories.find { |c| c.category == category }
          return event_category if event_category

          event_category = Models::EventCategory.new(source_result.event_category.category)
          event_category.reject "not_calculation_category"
          calculator.event_categories << event_category

          event_category
        end

        def self.in_calculation_category?(source_result, calculator)
          source_result.category.best_match_in(calculator.rules.categories).present?
        end
      end
    end
  end
end
