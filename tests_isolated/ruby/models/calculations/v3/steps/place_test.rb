# frozen_string_literal: true

require_relative "../../v3"

module Calculations
  module V3
    module Steps
      # :stopdoc:
      class PlaceTest < Ruby::TestCase
        def test_calculate
          category = Models::Category.new("Masters Men")
          rules = Rules.new(categories: [category])

          participant = Models::Participant.new(0)
          source_result = Models::SourceResult.new(
            id: 33,
            event_category: Models::EventCategory.new(category),
            participant: participant,
            place: "19"
          )
          result = Models::CalculatedResult.new(participant, [source_result])

          calculator = Calculator.new(rules: rules, source_results: [source_result])
          event_category = calculator.event_categories.first
          event_category.results << result

          Place.calculate! calculator

          assert_equal "1", calculator.event_categories.first.results.first.place
        end

        def test_place_many
          category = Models::Category.new("Masters Men")
          rules = Rules.new(categories: [category])
          calculator = Calculator.new(rules: rules, source_results: [])
          event_category = calculator.event_categories.first

          participant = Models::Participant.new(0)
          source_result = Models::SourceResult.new(id: 0, event_category: Models::EventCategory.new(category))
          result_1 = Models::CalculatedResult.new(participant, [source_result])
          result_1.points = 10
          event_category.results << result_1

          participant = Models::Participant.new(1)
          source_result = Models::SourceResult.new(id: 1, event_category: Models::EventCategory.new(category))
          result_2 = Models::CalculatedResult.new(participant, [source_result])
          result_2.points = 3
          event_category.results << result_2

          participant = Models::Participant.new(1)
          source_result = Models::SourceResult.new(id: 2, event_category: Models::EventCategory.new(category))
          result_3 = Models::CalculatedResult.new(participant, [source_result])
          result_3.points = 7
          event_category.results << result_3

          Place.calculate! calculator

          results = calculator.event_categories.first.results.sort_by(&:place)
          assert_equal "1", results[0].place
          refute results[0].tied?
          assert_equal result_1, results[0]

          assert_equal "2", results[1].place
          refute results[1].tied?
          assert_equal result_3, results[1]

          assert_equal "3", results[2].place
          refute results[2].tied?
          assert_equal result_2, results[2]
        end

        def test_break_ties_by_best_place
          category = Models::Category.new("Junior Women")
          rules = Rules.new(categories: [category])
          calculator = Calculator.new(rules: rules, source_results: [])
          event_category = calculator.event_categories.first

          participant = Models::Participant.new(1)
          source_result = Models::SourceResult.new(id: 1, event_category: Models::EventCategory.new(category), place: 2)
          result = Models::CalculatedResult.new(participant, [source_result])
          result.points = 15
          event_category.results << result

          participant = Models::Participant.new(0)
          source_result = Models::SourceResult.new(id: 0, event_category: Models::EventCategory.new(category), place: 4)
          source_result_2 = Models::SourceResult.new(id: 0, event_category: Models::EventCategory.new(category), place: 6)
          result = Models::CalculatedResult.new(participant, [source_result, source_result_2])
          result.points = 15
          event_category.results << result

          Place.calculate! calculator

          results = calculator.event_categories.first.results.sort_by(&:place)
          assert_equal "1", results[0].place
          refute results[0].tied?
          assert_equal 1, results[0].participant.id

          assert_equal "2", results[1].place
          refute results[1].tied?
          assert_equal 0, results[1].participant.id
        end

        def test_compare_by_points
          category = Models::Category.new("Junior Women")

          participant = Models::Participant.new(1)
          source_result = Models::SourceResult.new(id: 1, event_category: Models::EventCategory.new(category), place: 2)
          result = Models::CalculatedResult.new(participant, [source_result])
          result.points = 15

          participant = Models::Participant.new(0)
          source_result = Models::SourceResult.new(id: 0, event_category: Models::EventCategory.new(category), place: 4)
          source_result_2 = Models::SourceResult.new(id: 0, event_category: Models::EventCategory.new(category), place: 6)
          result_2 = Models::CalculatedResult.new(participant, [source_result, source_result_2])
          result_2.points = 15

          assert_equal(-1, Place.compare_by_points(result, result_2))
          assert_equal 1, Place.compare_by_points(result_2, result)
          assert_equal 0, Place.compare_by_points(result, result)
          assert_equal 0, Place.compare_by_points(result_2, result_2)
        end

        def test_compare_by_best_place
          category = Models::Category.new("Junior Women")

          participant = Models::Participant.new(1)
          source_result = Models::SourceResult.new(id: 1, event_category: Models::EventCategory.new(category), place: 2)
          result = Models::CalculatedResult.new(participant, [source_result])
          result.points = 15

          participant = Models::Participant.new(0)
          source_result = Models::SourceResult.new(id: 0, event_category: Models::EventCategory.new(category), place: 4)
          source_result_2 = Models::SourceResult.new(id: 0, event_category: Models::EventCategory.new(category), place: 6)
          result_2 = Models::CalculatedResult.new(participant, [source_result, source_result_2])
          result_2.points = 15

          assert_equal(-1, Place.compare_by_best_place(result, result_2))
          assert_equal 1, Place.compare_by_best_place(result_2, result)
          assert_equal 0, Place.compare_by_best_place(result, result)
          assert_equal 0, Place.compare_by_best_place(result_2, result_2)
        end

        def test_do_not_place_rejected
          category = Models::Category.new("Masters Men")
          rules = Rules.new(categories: [category])

          participant = Models::Participant.new(0)
          source_result = Models::SourceResult.new(
            id: 33,
            event_category: Models::EventCategory.new(category),
            participant: participant,
            place: "19"
          )
          result = Models::CalculatedResult.new(participant, [source_result])

          calculator = Calculator.new(rules: rules, source_results: [source_result])
          event_category = calculator.event_categories.first
          event_category.results << result

          event_category.reject("not_allowed")
          Place.calculate! calculator

          assert_nil calculator.event_categories.first.results.first.place
        end
      end
    end
  end
end
