# frozen_string_literal: true

require_relative "../v3"

module Calculations
  module V3
    # :stopdoc:
    class CalculatorTest < Ruby::TestCase
      def test_initialize
        Calculator.new
      end

      def test_calculate
        calculator = Calculator.new
        calculator.calculate!
      end

      def test_map_categories_to_event_categories
        masters_men = Models::Category.new("Masters Men")
        senior_men = Models::Category.new("Senior Men")
        rules = Rules.new(
          category_rules: [
            Models::CategoryRule.new(masters_men),
            Models::CategoryRule.new(senior_men, reject: true)
          ]
        )

        calculator = Calculator.new(rules: rules)

        assert_equal 1, calculator.event_categories.size
        assert_equal "Masters Men", calculator.event_categories.first.name
      end

      def test_min_max
        category = Models::Category.new("Athena")
        participant = Models::Participant.new(0)
        source_events = []
        source_results = []

        association = Models::Association.new(id: 0)
        series = Models::Event.new(id: 0, date: Date.new(2018, 10, 6), end_date: Date.new(2018, 11, 18))
        event = series.add_child(Models::Event.new(id: 1, date: Date.new(2018, 10, 6), sanctioned_by: association))
        event_category = Models::EventCategory.new(category, event)
        source_results << Models::SourceResult.new(id: 10, date: event.date, event_category: event_category, participant: participant, place: 2)
        source_events << event

        event = series.add_child(Models::Event.new(id: 3, date: Date.new(2018, 10, 7), sanctioned_by: association))
        event_category = Models::EventCategory.new(category, event)
        source_results << Models::SourceResult.new(id: 11, date: event.date, event_category: event_category, participant: participant, place: 2)
        source_events << event

        event = series.add_child(Models::Event.new(id: 4, date: Date.new(2018, 10, 14), sanctioned_by: association))
        event_category = Models::EventCategory.new(category, event)
        source_results << Models::SourceResult.new(id: 12, date: event.date, event_category: event_category, participant: participant, place: 1)
        source_events << event

        event = series.add_child(Models::Event.new(id: 5, date: Date.new(2018, 10, 28), sanctioned_by: association))
        event_category = Models::EventCategory.new(category, event)
        source_results << Models::SourceResult.new(id: 13, date: event.date, event_category: event_category, participant: participant, place: 1)
        source_events << event

        event = series.add_child(Models::Event.new(id: 6, date: Date.new(2018, 11, 3), sanctioned_by: association))
        event_category = Models::EventCategory.new(category, event)
        source_results << Models::SourceResult.new(id: 14, date: event.date, event_category: event_category, participant: participant, place: 2)
        source_events << event

        event = series.add_child(Models::Event.new(id: 7, date: Date.new(2018, 11, 4), sanctioned_by: association))
        # Someone else's result. Need a result to know that event was held.
        event_category = Models::EventCategory.new(category, event)
        participant_2 = Models::Participant.new(1)
        source_results << Models::SourceResult.new(id: 99, date: event.date, event_category: event_category, participant: participant_2, place: 2)
        source_events << event

        event = series.add_child(Models::Event.new(id: 8, date: Date.new(2018, 11, 11), sanctioned_by: association))
        event_category = Models::EventCategory.new(category, event)
        source_results << Models::SourceResult.new(id: 15, date: event.date, event_category: event_category, participant: participant, place: 1)
        source_events << event

        event = series.add_child(Models::Event.new(id: 9, date: Date.new(2018, 11, 18), sanctioned_by: association))
        event_category = Models::EventCategory.new(category, event)
        source_results << Models::SourceResult.new(id: 16, date: event.date, event_category: event_category, participant: participant, place: 3)
        source_events << event

        rules = Rules.new(
          association: association,
          category_rules: [Models::CategoryRule.new(category)],
          minimum_events: 3,
          points_for_place: [26, 20, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
          maximum_events: -1
        )
        calculator = Calculator.new(rules: rules, source_events: source_events, source_results: source_results)

        event_categories = calculator.calculate!
        result = event_categories.first.results.detect { |r| r.participant.id == 0 }
        assert_equal 7, result.source_results.size
        assert_equal [26, 26, 26, 20, 20, 20, 16], result.source_results.map(&:points).sort.reverse
        assert_equal 154, result.points
      end

      def test_ironman_rules
        source_results = []
        participant = Models::Participant.new(0)

        association = Models::Association.new(id: 0)
        event = Models::Event.new(id: 1, date: Date.new(2019, 12, 1), sanctioned_by: association)
        event_category = Models::EventCategory.new(Models::Category.new("Athena"), event)
        source_results << Models::SourceResult.new(id: 10, event_category: event_category, participant: participant, place: 99)

        event = Models::Event.new(id: 2, date: Date.new(2019, 12, 15), sanctioned_by: association)
        event_category = Models::EventCategory.new(Models::Category.new("Women 5"), event)
        source_results << Models::SourceResult.new(id: 11, event_category: event_category, participant: participant, place: 1)

        rules = Rules.new(association: association, points_for_place: 1)
        calculator = Calculator.new(rules: rules, source_results: source_results)

        event_categories = calculator.calculate!
        assert_equal 1, event_categories.size
        event_category = event_categories.first
        assert_equal "Calculation", event_category.name
        assert_equal 1, event_category.results.size
        result = event_category.results.first
        refute result.rejected?, result.rejection_reason
        assert_equal 2, result.source_results.size
        assert result.source_results.none?(&:rejected?)
        assert_equal [1, 1], result.source_results.map(&:points)
        assert_equal 2, result.points
      end

      def test_validate
        calculator = Calculator.new
        calculator.validate!

        calculator.event_categories << Models::EventCategory.new(Models::Category.new("Masters Men"))
        calculator.validate!
        calculator.event_categories << Models::EventCategory.new(Models::Category.new("Masters Men"))
        assert_raises(RuntimeError) { calculator.validate! }
      end
    end
  end
end
