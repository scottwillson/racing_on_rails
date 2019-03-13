# frozen_string_literal: true

require_relative "../../v3"

module Calculations
  module V3
    module Models
      # :stopdoc:
      class EventTest < Ruby::TestCase
        include EqualityAssertion

        def test_initialize
          event = Event.new(id: 0, date: Date.new(2016))
          assert_equal Date.new(2016), event.date
          assert_equal Date.new(2016), event.start_date
          assert_equal Date.new(2016), event.end_date
          assert_equal Date.new(2016)..Date.new(2016), event.dates
        end

        def test_add_child
          series = Models::Event.new(id: 0, date: Date.new(2018, 5, 1), end_date: Date.new(2018, 5, 8))
          event = Models::Event.new(id: 1, date: Date.new(2018, 5, 1))
          series.add_child event
          assert_equal 1, series.children.size
          assert_equal 1, series.children[0].id
          assert_equal series, event.parent
        end

        def test_equality
          a = Event.new(id: 0)
          b = Event.new(id: 0)
          c = Event.new(id: 0)
          d = Event.new(id: 1)

          assert_equality a, b, c, d
        end
      end
    end
  end
end
