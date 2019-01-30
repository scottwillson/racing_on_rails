# frozen_string_literal: true

require_relative "../../v3"

module Calculations
  module V3
    module Models
      # :stopdoc:
      class EventCategoryTest < Ruby::TestCase
        def test_initialize
          participant = Calculations::V3::Models::Participant.new(1)
          category = Calculations::V3::Models::Category.new("Juniors")
          sources = [
            Calculations::V3::Models::SourceResult.new(id: 11, event_category: Calculations::V3::Models::EventCategory.new(category)),
            Calculations::V3::Models::SourceResult.new(id: 13, event_category: Calculations::V3::Models::EventCategory.new(category))
          ]

          result = Calculations::V3::Models::CalculatedResult.new(participant, sources)
          event_category = Calculations::V3::Models::EventCategory.new(category)
          event_category.results << result
        end
      end
    end
  end
end
