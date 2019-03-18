# frozen_string_literal: true

module Calculations
  module V3
    module Steps
      module RejectNoParticipant
        def self.calculate!(calculator)
          calculator.event_categories.each do |event_category|
            event_category.results.reject! { |result| result.participant.id.nil? }
          end
        end
      end
    end
  end
end
