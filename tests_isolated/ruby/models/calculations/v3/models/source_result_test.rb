# frozen_string_literal: true

require_relative "../../v3"

module Calculations
  module V3
    module Models
      # :stopdoc:
      class SourceResultTest < Ruby::TestCase
        def test_initialize
          participant = Calculations::V3::Models::Participant.new(1)

          result = Calculations::V3::Models::SourceResult.new(
            id: 19,
            event_category: event_category,
            participant: participant,
            place: "DNF"
          )

          assert_equal 19, result.id
          assert_equal participant, result.participant
          assert_equal "DNF", result.place
          assert_equal 0, result.points
        end

        def test_id
          assert_raises(ArgumentError) { Calculations::V3::Models::SourceResult.new(id: nil, event_category: event_category) }
          assert_raises(ArgumentError) { Calculations::V3::Models::SourceResult.new(id: "id", event_category: event_category) }
        end

        def test_event_category
          assert_raises(ArgumentError) { Calculations::V3::Models::SourceResult.new(event_category: nil) }
          assert_raises(ArgumentError) { Calculations::V3::Models::SourceResult.new(event_category: "A") }
        end

        def test_rejected
          result = Calculations::V3::Models::SourceResult.new(id: 19, event_category: event_category)
          assert_equal false, result.rejected?
        end

        def test_numeric_place
          result = Calculations::V3::Models::SourceResult.new(id: 19, event_category: event_category)
          assert_equal 0, result.numeric_place

          result = Calculations::V3::Models::SourceResult.new(id: 19, place: "1", event_category: event_category)
          assert_equal 1, result.numeric_place
        end

        private

        def event_category
          category = Calculations::V3::Models::Category.new("A")
          Calculations::V3::Models::EventCategory.new(category)
        end
      end
    end
  end
end
