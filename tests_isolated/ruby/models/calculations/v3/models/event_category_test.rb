# frozen_string_literal: true

require_relative "../../v3"

module Calculations
  module V3
    module Models
      # :stopdoc:
      class EventCategoryTest < Ruby::TestCase
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

          assert_equal a, a
          assert_equal a, b
          assert_equal a, c
          assert_equal b, a
          assert_equal b, b
          assert_equal b, c
          assert_equal c, a
          assert_equal c, b
          assert_equal c, c
          assert_equal d, d
          refute_equal a, d
          refute_equal b, d
          refute_equal c, d
          refute_equal d, a
          refute_equal d, b
          refute_equal d, c
          refute_equal a, nil
          refute_equal d, nil
          refute_equal nil, a
          refute_equal nil, d
        end

        def test_hash
          a = EventCategory.new(Category.new("Women"))
          b = EventCategory.new(Category.new("Women"))
          c = EventCategory.new(Category.new("Women"))
          d = EventCategory.new(Category.new("Men"))

          assert_equal a.hash, a.hash
          assert_equal a.hash, b.hash
          assert_equal a.hash, c.hash
          assert_equal d.hash, d.hash
          refute_equal a.hash, d.hash
          refute_equal b.hash, d.hash
          refute_equal c.hash, d.hash
          refute_equal a.hash, nil.hash
          refute_equal d.hash, nil.hash
          refute_equal nil.hash, a.hash
          refute_equal nil.hash, d.hash
        end
      end
    end
  end
end
