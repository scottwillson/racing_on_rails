# frozen_string_literal: true

require_relative "../../v3"

module Calculations
  module V3
    module Steps
      # :stopdoc:
      class PlaceTest < Ruby::TestCase
        def test_calculate
          category = Models::Category.new("Masters Men")
          rules = Rules.new(category_rules: [Models::CategoryRule.new(category)])

          participant = Models::Participant.new(0)
          source_result = Models::SourceResult.new(
            id: 33,
            event_category: Models::EventCategory.new(category),
            participant: participant,
            place: "19",
            points: 1
          )
          result = Models::CalculatedResult.new(participant, [source_result])
          result.points = 1

          calculator = Calculator.new(rules: rules, source_results: [source_result])
          event_category = calculator.event_categories.first
          event_category.results << result

          Place.calculate! calculator

          assert_equal "1", result.place
        end

        def test_place_many
          category = Models::Category.new("Masters Men")
          rules = Rules.new(category_rules: [Models::CategoryRule.new(category)])
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

        def test_fewest_points_wins
          category = Models::Category.new("Masters Men")
          rules = Rules.new(category_rules: [Models::CategoryRule.new(category)], place_by: "fewest_points")
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
          assert_equal result_2, results[0]

          assert_equal "2", results[1].place
          refute results[1].tied?
          assert_equal result_3, results[1]

          assert_equal "3", results[2].place
          refute results[2].tied?
          assert_equal result_1, results[2]
        end

        def test_by_time
          category = Models::Category.new("Masters Men")
          rules = Rules.new(category_rules: [Models::CategoryRule.new(category)], place_by: "time")
          calculator = Calculator.new(rules: rules, source_results: [])
          event_category = calculator.event_categories.first

          participant = Models::Participant.new(0)
          source_result = Models::SourceResult.new(id: 0, event_category: Models::EventCategory.new(category), time: 2000)
          result_1 = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result_1

          participant = Models::Participant.new(1)
          source_result = Models::SourceResult.new(id: 1, event_category: Models::EventCategory.new(category), time: 1950)
          result_2 = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result_2

          participant = Models::Participant.new(1)
          source_result = Models::SourceResult.new(id: 2, event_category: Models::EventCategory.new(category), time: 1951)
          result_3 = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result_3

          Place.calculate! calculator

          results = calculator.event_categories.first.results.sort_by(&:place)
          assert_equal "1", results[0].place
          refute results[0].tied?
          assert_equal result_2, results[0]

          assert_equal "2", results[1].place
          refute results[1].tied?
          assert_equal result_3, results[1]

          assert_equal "3", results[2].place
          refute results[2].tied?
          assert_equal result_1, results[2]
        end

        def test_by_place
          category = Models::Category.new("Masters Men")
          rules = Rules.new(category_rules: [Models::CategoryRule.new(category)], place_by: "place")
          calculator = Calculator.new(rules: rules, source_results: [])
          event_category = calculator.event_categories.first

          participant = Models::Participant.new(0)
          source_result = Models::SourceResult.new(id: 0, event_category: Models::EventCategory.new(category), place: 20)
          result_1 = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result_1

          participant = Models::Participant.new(1)
          source_result = Models::SourceResult.new(id: 1, event_category: Models::EventCategory.new(category), place: 18)
          result_2 = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result_2

          participant = Models::Participant.new(2)
          source_result = Models::SourceResult.new(id: 2, event_category: Models::EventCategory.new(category), place: 19)
          result_3 = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result_3

          participant = Models::Participant.new(3)
          source_result = Models::SourceResult.new(id: 3, event_category: Models::EventCategory.new(category), place: 21)
          result_4 = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result_4

          participant = Models::Participant.new(4)
          source_result = Models::SourceResult.new(id: 4, event_category: Models::EventCategory.new(category), place: 21)
          result_5 = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result_5

          Place.calculate! calculator

          results = calculator.event_categories.first.results.sort_by(&:place)
          assert_equal "1", results[0].place
          refute results[0].tied?
          assert_equal result_2, results[0]

          assert_equal "2", results[1].place
          refute results[1].tied?
          assert_equal result_3, results[1]

          assert_equal "3", results[2].place
          refute results[2].tied?
          assert_equal result_1, results[2]

          assert_equal "4", results[3].place
          assert results[3].tied?

          assert_equal "4", results[4].place
          assert results[4].tied?
        end

        def test_by_placed_considers_ability
          category = Models::Category.new("19-34")
          rules = Rules.new(category_rules: [Models::CategoryRule.new(category)], place_by: "place")
          calculator = Calculator.new(rules: rules, source_results: [])
          event_category = calculator.event_categories.first

          men_1_2 = Models::Category.new("Men 1/2")
          participant = Models::Participant.new(0)
          source_result = Models::SourceResult.new(id: 0, event_category: Models::EventCategory.new(men_1_2), place: 1)
          result_1 = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result_1

          men_3 = Models::Category.new("Men 3")
          participant = Models::Participant.new(1)
          source_result = Models::SourceResult.new(id: 1, event_category: Models::EventCategory.new(men_3), place: 1)
          result_2 = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result_2

          Place.calculate! calculator

          results = calculator.event_categories.first.results.sort_by(&:place)
          assert_equal "1", results[0].place
          refute results[0].tied?
          assert_equal result_1, results[0]

          assert_equal "2", results[1].place
          refute results[1].tied?
          assert_equal result_2, results[1]
        end

        def test_break_ties_by_best_place
          category = Models::Category.new("Junior Women")
          rules = Rules.new(category_rules: [Models::CategoryRule.new(category)])
          calculator = Calculator.new(rules: rules, source_results: [])
          event_category = calculator.event_categories.first

          participant = Models::Participant.new(1)
          source_result = Models::SourceResult.new(id: 1, event_category: Models::EventCategory.new(category), place: 2, points: 15)
          result = Models::CalculatedResult.new(participant, [source_result])
          result.points = 15
          event_category.results << result

          participant = Models::Participant.new(0)
          source_result = Models::SourceResult.new(id: 0, event_category: Models::EventCategory.new(category), place: 4, points: 9)
          source_result_2 = Models::SourceResult.new(id: 0, event_category: Models::EventCategory.new(category), place: 6, points: 6)
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
          source_result = Models::SourceResult.new(id: 1, date: Date.new(2018, 5, 8), event_category: Models::EventCategory.new(category), place: 2, points: 15)
          result = Models::CalculatedResult.new(participant, [source_result])
          result.points = 15

          participant = Models::Participant.new(0)
          source_result = Models::SourceResult.new(id: 0, date: Date.new(2018, 5, 1), event_category: Models::EventCategory.new(category), place: 4, points: 9)
          source_result_2 = Models::SourceResult.new(id: 0, date: Date.new(2018, 5, 15), event_category: Models::EventCategory.new(category), place: 6, points: 6)
          result_2 = Models::CalculatedResult.new(participant, [source_result, source_result_2])
          result_2.points = 15

          assert_equal(-1, Place.compare_by_points(result, result_2))
          assert_equal 1, Place.compare_by_points(result_2, result)
          assert_equal 0, Place.compare_by_points(result, result)
          assert_equal 0, Place.compare_by_points(result_2, result_2)
        end

        def test_compare_by_points_ignores_dqs
          category = Models::Category.new("Junior Women")

          participant = Models::Participant.new(1)
          source_result = Models::SourceResult.new(id: 1, date: Date.new(2018, 6, 6), event_category: Models::EventCategory.new(category), place: 3, points: 50)
          result = Models::CalculatedResult.new(participant, [source_result])
          result.points = 50

          participant = Models::Participant.new(0)
          source_result = Models::SourceResult.new(id: 0, date: Date.new(2018, 5, 30), event_category: Models::EventCategory.new(category), place: 3, points: 50)
          source_result_2 = Models::SourceResult.new(id: 0, date: Date.new(2018, 6, 6), event_category: Models::EventCategory.new(category), place: "DQ", points: 0)
          result_2 = Models::CalculatedResult.new(participant, [source_result, source_result_2])
          result_2.points = 50

          assert_equal(-1, Place.compare_by_points(result, result_2))
          assert_equal 1, Place.compare_by_points(result_2, result)
          assert_equal 0, Place.compare_by_points(result, result)
          assert_equal 0, Place.compare_by_points(result_2, result_2)
        end

        def test_compare_by_best_place
          category = Models::Category.new("Junior Women")

          participant = Models::Participant.new(1)
          source_result = Models::SourceResult.new(id: 1, event_category: Models::EventCategory.new(category), place: 2, points: 15)
          result = Models::CalculatedResult.new(participant, [source_result])
          result.points = 15

          participant = Models::Participant.new(0)
          source_result = Models::SourceResult.new(id: 0, event_category: Models::EventCategory.new(category), place: 4, points: 9)
          source_result_2 = Models::SourceResult.new(id: 2, event_category: Models::EventCategory.new(category), place: 6, points: 6)
          source_result_3 = Models::SourceResult.new(id: 3, event_category: Models::EventCategory.new(category), place: "DNF")
          source_result_4 = Models::SourceResult.new(id: 3, event_category: Models::EventCategory.new(category), place: "99")
          result_2 = Models::CalculatedResult.new(participant, [source_result, source_result_2, source_result_3, source_result_4])
          result_2.points = 15

          assert_equal(-1, Place.compare_by_best_place(result, result_2))
          assert_equal 1, Place.compare_by_best_place(result_2, result)
          assert_equal 0, Place.compare_by_best_place(result, result)
        end

        def test_compare_by_most_recent_result
          category = Models::Category.new("Junior Women")

          participant = Models::Participant.new(1)
          source_result = Models::SourceResult.new(id: 1, date: Date.new(2018, 5, 1), event_category: Models::EventCategory.new(category), place: 2, points: 15)
          result = Models::CalculatedResult.new(participant, [source_result])
          result.points = 15

          participant = Models::Participant.new(0)
          source_result = Models::SourceResult.new(id: 0, date: Date.new(2018, 4, 1), event_category: Models::EventCategory.new(category), place: 2, points: 15)
          result_2 = Models::CalculatedResult.new(participant, [source_result])
          result_2.points = 15

          assert_equal(-1, Place.compare_by_most_recent_result(result, result_2))
          assert_equal 1, Place.compare_by_most_recent_result(result_2, result)
          assert_equal 0, Place.compare_by_most_recent_result(result, result)
          assert_equal 0, Place.compare_by_most_recent_result(result_2, result_2)
        end

        def test_compare_by_most_recent_result_ignores_dqs
          category = Models::Category.new("Junior Women")

          participant = Models::Participant.new(1)
          source_result = Models::SourceResult.new(id: 1, date: Date.new(2018, 5, 1), event_category: Models::EventCategory.new(category), place: 2, points: 15)
          result = Models::CalculatedResult.new(participant, [source_result])
          result.points = 15

          participant = Models::Participant.new(0)
          source_result = Models::SourceResult.new(id: 0, date: Date.new(2018, 4, 1), event_category: Models::EventCategory.new(category), place: 2, points: 15)
          source_result_2 = Models::SourceResult.new(id: 2, date: Date.new(2018, 6, 1), event_category: Models::EventCategory.new(category), place: "DQ", points: 15)
          source_result_3 = Models::SourceResult.new(id: 2, date: Date.new(2018, 8, 1), event_category: Models::EventCategory.new(category), place: "99")
          result_2 = Models::CalculatedResult.new(participant, [source_result, source_result_2, source_result_3])
          result_2.points = 15

          assert_equal(-1, Place.compare_by_most_recent_result(result, result_2))
          assert_equal 1, Place.compare_by_most_recent_result(result_2, result)
          assert_equal 0, Place.compare_by_most_recent_result(result, result)
          assert_equal 0, Place.compare_by_most_recent_result(result_2, result_2)
        end

        def test_compare_by_date
          category = Models::Category.new("Masters Men")

          result = Models::SourceResult.new(id: 0, date: Date.new(2018, 4, 1), event_category: Models::EventCategory.new(category), place: 2, points: 15)
          result_2 = Models::SourceResult.new(id: 0, date: Date.new(2018, 5, 1), event_category: Models::EventCategory.new(category), place: 2, points: 15)
          assert_equal 1, Place.compare_by_date(result, result_2)
        end

        def test_do_not_place_rejected
          category = Models::Category.new("Masters Men")
          rules = Rules.new(category_rules: [Models::CategoryRule.new(category)])

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

        def test_only_place_if_points
          category = Models::Category.new("Masters Men")
          rules = Rules.new(category_rules: [Models::CategoryRule.new(category)])

          participant = Models::Participant.new(0)
          source_result = Models::SourceResult.new(
            id: 33,
            event_category: Models::EventCategory.new(category),
            participant: participant,
            place: "19",
            points: 0
          )
          result = Models::CalculatedResult.new(participant, [source_result])

          calculator = Calculator.new(rules: rules, source_results: [source_result])
          event_category = calculator.event_categories.first
          event_category.results << result

          Place.calculate! calculator

          assert_nil calculator.event_categories.first.results.first.place
        end
      end
    end
  end
end
