# frozen_string_literal: true

require_relative "../../v3"
require_relative "./equality_assertion"

module Calculations
  module V3
    module Models
      # :stopdoc:
      class EventCategoryTest < Ruby::TestCase
        include EqualityAssertion

        def test_initialize
          participant = Participant.new(1)
          category = Category.new("Juniors")
          sources = [
            SourceResult.new(id: 11, event_category: EventCategory.new(category)),
            SourceResult.new(id: 13, event_category: EventCategory.new(category))
          ]

          result = CalculatedResult.new(participant, sources)
          event_category = EventCategory.new(category)
          event_category.results << result
        end

        def test_equality
          a = EventCategory.new(Category.new("Women"))
          b = EventCategory.new(Category.new("Women"))
          c = EventCategory.new(Category.new("Women"))
          d = EventCategory.new(Category.new("Men"))

          assert_equality a, b, c, d
        end
      end
    end
  end
end
