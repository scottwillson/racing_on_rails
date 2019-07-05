# frozen_string_literal: true

require_relative "../v3"

module Calculations
  module V3
    # :stopdoc:
    class MapSourceResultsToResultsTest < Ruby::TestCase
      def test_map_source_results_to_results
        participant = Models::Participant.new(0)
        category = Models::Category.new("Masters Men")

        source_result = Models::SourceResult.new(
          id: 33,
          event_category: Models::EventCategory.new(category),
          participant: participant,
          place: "19"
        )
        source_results = [source_result]

        rules = Rules.new(category_rules: [Models::CategoryRule.new(category)])
        calculator = Calculator.new(rules: rules, source_results: source_results)

        event_categories = calculator.event_categories

        assert_equal 1, event_categories.size
        assert_equal 1, event_categories.first.results.size
        result = event_categories.first.results.first
        assert_equal 0, result.participant.id
        refute event_categories.first.rejected?
        refute result.rejected?

        assert_equal 1, result.source_results.size
        assert_equal 33, result.source_results.first.id
        assert_equal "19", result.source_results.first.place
        refute result.source_results.first.rejected?
      end

      def test_add_missing_categories
        participant = Models::Participant.new(0)
        category = Models::Category.new("Junior Men")

        source_result = Models::SourceResult.new(
          id: 33,
          event_category: Models::EventCategory.new(category),
          participant: participant,
          place: "19"
        )
        source_results = [source_result]

        event_category = Models::Category.new("Masters Women")
        rules = Rules.new(category_rules: [Models::CategoryRule.new(event_category)])
        calculator = Calculator.new(rules: rules, source_results: source_results)

        event_categories = calculator.event_categories

        assert_equal 2, event_categories.size
        assert_equal ["Junior Men", "Masters Women"], event_categories.map(&:name).sort

        event_category = event_categories.detect { |ec| ec.name == "Junior Men" }
        assert_equal 1, event_category.results.size
        result = event_category.results.first
        assert_equal 0, result.participant.id
        assert result.rejected?
        assert event_category.rejected?

        assert_equal 1, result.source_results.size
        assert_equal 33, result.source_results.first.id
        assert_equal "19", result.source_results.first.place
        assert result.source_results.first.rejected?
      end

      def test_group_by_participant_id
        source_results = []
        category = Models::Category.new("Masters Men")

        participant_1 = Models::Participant.new(0)
        source_results << Models::SourceResult.new(
          id: 33,
          event_category: Models::EventCategory.new(category),
          participant: participant_1,
          place: "19"
        )

        participant_2 = Models::Participant.new(1)
        source_results << Models::SourceResult.new(
          id: 34,
          event_category: Models::EventCategory.new(category),
          participant: participant_2,
          place: "7"
        )

        source_results << Models::SourceResult.new(
          id: 35,
          event_category: Models::EventCategory.new(category),
          participant: participant_1,
          place: "3"
        )

        rules = Rules.new(category_rules: [Models::CategoryRule.new(category)])
        calculator = Calculator.new(rules: rules, source_results: source_results)

        event_categories = calculator.event_categories

        assert_equal 1, event_categories.size
        assert_equal 2, event_categories.first.results.size

        result = event_categories.first.results.find { |r| r.participant.id == 0 }
        assert_equal 2, result.source_results.size
        source_results = result.source_results.sort_by(&:id)
        assert_equal 33, source_results.first.id
        assert_equal "19", source_results.first.place
        assert_equal 35, source_results[1].id
        assert_equal "3", source_results[1].place

        result = event_categories.first.results.find { |r| r.participant.id == 1 }
        assert_equal 1, result.source_results.size
        assert_equal 34, result.source_results.first.id
        assert_equal "7", result.source_results.first.place
      end

      def test_group_by_category
        source_results = []
        masters_men = Models::Category.new("Masters Men")
        junior_women = Models::Category.new("Junior Women")
        rejected_category = Models::Category.new("Category 3")

        participant_1 = Models::Participant.new(0)
        source_results << Models::SourceResult.new(
          id: 33,
          event_category: Models::EventCategory.new(junior_women),
          participant: participant_1,
          place: "19"
        )

        participant_2 = Models::Participant.new(1)
        source_results << Models::SourceResult.new(
          id: 34,
          event_category: Models::EventCategory.new(masters_men),
          participant: participant_2,
          place: "7"
        )

        source_results << Models::SourceResult.new(
          id: 35,
          event_category: Models::EventCategory.new(masters_men),
          participant: participant_1,
          place: "3"
        )

        source_results << Models::SourceResult.new(
          id: 36,
          event_category: Models::EventCategory.new(rejected_category),
          participant: participant_2,
          place: "19"
        )

        source_results << Models::SourceResult.new(
          id: 37,
          event_category: Models::EventCategory.new(rejected_category),
          participant: participant_1,
          place: "7"
        )

        rules = Rules.new(
          category_rules: [
            Models::CategoryRule.new(masters_men),
            Models::CategoryRule.new(junior_women)
          ]
        )
        calculator = Calculator.new(rules: rules, source_results: source_results)

        event_categories = calculator.event_categories
        assert_equal 3, event_categories.size, event_categories.map(&:name)
        junior_women_event_category = event_categories.find { |ec| ec.category == junior_women }
        assert_equal 1, junior_women_event_category.results.size
        masters_men_event_category = event_categories.find { |ec| ec.category == masters_men }
        assert_equal 2, masters_men_event_category.results.size
      end

      def test_all_in_single_category
        source_results = []
        masters_men = Models::Category.new("Masters Men")
        junior_women = Models::Category.new("Junior Women")

        participant_1 = Models::Participant.new(0)
        source_results << Models::SourceResult.new(
          id: 33,
          event_category: Models::EventCategory.new(junior_women),
          participant: participant_1,
          place: "19"
        )

        participant_2 = Models::Participant.new(1)
        source_results << Models::SourceResult.new(
          id: 34,
          event_category: Models::EventCategory.new(masters_men),
          participant: participant_2,
          place: "7"
        )

        rules = Rules.new
        calculator = Calculator.new(rules: rules, source_results: source_results)
        event_categories = calculator.event_categories
        assert_equal 1, event_categories.size, event_categories.map(&:name)
      end

      def test_match_equivalent_categories
        source_results = []
        masters_men = Models::Category.new("Masters Men")
        masters_30 = Models::Category.new("Masters 30+")
        junior_women = Models::Category.new("Junior Women")

        participant_1 = Models::Participant.new(0)
        source_results << Models::SourceResult.new(
          id: 33,
          event_category: Models::EventCategory.new(junior_women),
          participant: participant_1,
          place: "19"
        )

        participant_2 = Models::Participant.new(1)
        source_results << Models::SourceResult.new(
          id: 34,
          event_category: Models::EventCategory.new(masters_men),
          participant: participant_2,
          place: "7"
        )

        source_results << Models::SourceResult.new(
          id: 35,
          event_category: Models::EventCategory.new(masters_30),
          participant: participant_1,
          place: "3"
        )

        rules = Rules.new(
          category_rules: [
            Models::CategoryRule.new(masters_men),
            Models::CategoryRule.new(junior_women)
          ]
        )
        calculator = Calculator.new(rules: rules, source_results: source_results)

        event_categories = calculator.event_categories
        assert_equal 2, event_categories.size, event_categories.map(&:name)
        junior_women_event_category = event_categories.find { |ec| ec.category == junior_women }
        assert_equal 1, junior_women_event_category.results.size
        masters_men_event_category = event_categories.find { |ec| ec.category == masters_men }
        assert_equal 2, masters_men_event_category.results.size
      end

      def test_group_by_age
        source_results = []
        athena = Models::Category.new("Athena")
        clydesdale = Models::Category.new("Clydesdale")
        men_35_49 = Models::Category.new("Men 35-49")
        men_50 = Models::Category.new("Men 50+")
        men_60 = Models::Category.new("Men 60+")
        men_9_18 = Models::Category.new("Men 9-18")
        junior_men_17_18 = Models::Category.new("Junior Men 17-18")
        women_35_49 = Models::Category.new("Women 35-49")
        masters_50_plus = Models::Category.new("Masters 50+	")

        source_results << Models::SourceResult.new(
          id: 33,
          age: 41,
          event_category: Models::EventCategory.new(athena),
          participant: Models::Participant.new(0),
          place: "1"
        )

        source_results << Models::SourceResult.new(
          id: 34,
          age: 52,
          event_category: Models::EventCategory.new(clydesdale),
          participant: Models::Participant.new(1),
          place: "7"
        )

        source_results << Models::SourceResult.new(
          id: 35,
          age: 17,
          event_category: Models::EventCategory.new(junior_men_17_18),
          participant: Models::Participant.new(2),
          place: "1"
        )

        source_results << Models::SourceResult.new(
          id: 36,
          age: 53,
          event_category: Models::EventCategory.new(masters_50_plus),
          participant: Models::Participant.new(3),
          place: "19"
        )

        source_results << Models::SourceResult.new(
          id: 37,
          event_category: Models::EventCategory.new(rejected_category),
          participant: Models::Participant.new(4),
          place: "7"
        )

        rules = Rules.new(
          category_rules: [
            Models::CategoryRule.new(men_9_18),
            Models::CategoryRule.new(women_35_49),
            Models::CategoryRule.new(men_35_49),
            Models::CategoryRule.new(men_50),
            Models::CategoryRule.new(men_60)
          ],
          group_by: "age"
        )
        calculator = Calculator.new(rules: rules, source_results: source_results)

        event_categories = calculator.event_categories
        assert_equal 3, event_categories.size, event_categories.map(&:name)
        junior_women_event_category = event_categories.find { |ec| ec.category == junior_women }
        assert_equal 1, junior_women_event_category.results.size
        masters_men_event_category = event_categories.find { |ec| ec.category == masters_men }
        assert_equal 2, masters_men_event_category.results.size
      end
    end
  end
end
