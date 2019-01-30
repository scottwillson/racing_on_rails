# frozen_string_literal: true

require_relative "../../v3"

module Calculations
  module V3
    module Models
      # :stopdoc:
      class CalculatedResultTest < Ruby::TestCase
        def test_initialize
          category = Category.new("A")
          event_category = EventCategory.new(category)
          sources = [SourceResult.new(id: 11, event_category: event_category)]
          participant = Participant.new(1)

          result = CalculatedResult.new(participant, sources)

          assert_equal participant, result.participant
          assert_equal sources, result.source_results
        end

        def test_participant
          assert_raises(ArgumentError) { CalculatedResult.new(nil) }
        end

        def test_sources
          assert_raises(ArgumentError) { CalculatedResult.new(1, nil) }
          assert_raises(ArgumentError) { CalculatedResult.new(2, []) }
          assert_raises(ArgumentError) { CalculatedResult.new(2, "") }
        end
      end
    end
  end
end
