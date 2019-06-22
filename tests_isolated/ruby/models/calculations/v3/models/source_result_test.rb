# frozen_string_literal: true

require_relative "../../v3"

module Calculations
  module V3
    module Models
      # :stopdoc:
      class SourceResultTest < Ruby::TestCase
        def test_initialize
          participant = Participant.new(1)

          result = SourceResult.new(
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
          assert_raises(ArgumentError) { SourceResult.new(id: "id", event_category: event_category) }
        end

        def test_event_category
          assert_raises(ArgumentError) { SourceResult.new(event_category: nil) }
          assert_raises(ArgumentError) { SourceResult.new(event_category: "A") }
        end

        def test_reject
          result = SourceResult.new(id: 19, event_category: event_category, points: 12)
          result.reject(:worse_result)
          assert result.rejected?
          assert_equal :worse_result, result.rejection_reason
          assert_equal 0, result.points
        end

        def test_rejected
          result = SourceResult.new(id: 19, event_category: event_category)
          assert_equal false, result.rejected?
        end

        def test_numeric_place
          result = SourceResult.new(id: 19, event_category: event_category)
          assert_equal Float::INFINITY, result.numeric_place

          result = SourceResult.new(id: 19, place: "1", event_category: event_category)
          assert_equal 1, result.numeric_place
        end

        def test_parent_end_date
          series = Models::Event.new(date: Date.new(2018, 5, 1), end_date: Date.new(2018, 5, 16))
          event_1 = Models::Event.new(date: Date.new(2018, 5, 1))
          series.add_child event_1
          event_2 = Models::Event.new(date: Date.new(2018, 5, 16))
          series.add_child event_2

          category = Category.new("A")

          event_category = EventCategory.new(category, event_1)
          result_1 = SourceResult.new(id: 0, event_category: event_category)

          event_category = EventCategory.new(category, event_2)
          result_2 = SourceResult.new(id: 1, event_category: event_category)

          assert_equal Date.new(2018, 5, 16), result_1.parent_end_date
          assert_equal Date.new(2018, 5, 16), result_2.parent_end_date
        end

        private

        def event_category
          category = Category.new("A")
          EventCategory.new(category)
        end
      end
    end
  end
end
