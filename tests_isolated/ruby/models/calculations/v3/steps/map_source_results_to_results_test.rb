# frozen_string_literal: true

require_relative "../../v3"

module Calculations
  module V3
    module Steps
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

          rules = Rules.new(categories: [category])
          calculator = Calculator.new(rules: rules, source_results: source_results)

          event_categories = MapSourceResultsToResults.calculate!(calculator)

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
          category = Models::Category.new("Masters Men")

          source_result = Models::SourceResult.new(
            id: 33,
            event_category: Models::EventCategory.new(category),
            participant: participant,
            place: "19"
          )
          source_results = [source_result]

          event_category = Models::Category.new("Masters Women")
          rules = Rules.new(categories: [event_category])
          calculator = Calculator.new(rules: rules, source_results: source_results)

          event_categories = MapSourceResultsToResults.calculate!(calculator)

          assert_equal 2, event_categories.size
          assert_equal ["Masters Men", "Masters Women"], event_categories.map(&:name).sort

          event_category = event_categories.detect { |ec| ec.name == "Masters Men" }
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

          rules = Rules.new(categories: [category])
          calculator = Calculator.new(rules: rules, source_results: source_results)

          event_categories = MapSourceResultsToResults.calculate!(calculator)

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

          rules = Rules.new(categories: [masters_men, junior_women])
          calculator = Calculator.new(rules: rules, source_results: source_results)

          event_categories = MapSourceResultsToResults.calculate!(calculator)
          assert_equal 3, event_categories.size, event_categories.map(&:name)
          junior_women_event_category = event_categories.find { |ec| ec.category == junior_women }
          assert_equal 1, junior_women_event_category.results.size
          masters_men_event_category = event_categories.find { |ec| ec.category == masters_men }
          assert_equal 2, masters_men_event_category.results.size
        end
      end
    end
  end
end
