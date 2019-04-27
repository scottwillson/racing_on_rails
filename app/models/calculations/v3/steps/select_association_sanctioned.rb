# frozen_string_literal: true

module Calculations
  module V3
    module Steps
      module SelectAssociationSanctioned
        def self.calculate!(calculator)
          calculator.source_results.each do |source_result|
            if calculator.rules.association.nil?
              raise ArgumentError, "Rules#association sanctioned_by must be present"
            end

            if calculator.rules.association != source_result.event.sanctioned_by
              source_result.reject :sanctioned_by
            end
          end

          calculator.event_categories
        end
      end
    end
  end
end
