# frozen_string_literal: true

module Calculations
  module V3
    module Steps
      module SelectMembers
        def self.calculate!(calculator)
          if calculator.rules.members_only?
            calculator.results.each do |result|
              unless result.participant.member?(calculator.year)
                result.reject :members_only
              end
            end
          end

          calculator.event_categories
        end
      end
    end
  end
end
