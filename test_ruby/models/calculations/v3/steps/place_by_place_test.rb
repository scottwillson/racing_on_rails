# frozen_string_literal: true

require_relative "../../v3"

module Calculations
  module V3
    module Steps
      # :stopdoc:
      class PlaceByPlaceTest < Ruby::TestCase
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
          source_result = Models::SourceResult.new(id: 3, event_category: Models::EventCategory.new(category), place: 21, date: Date.today)
          result_4 = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result_4

          participant = Models::Participant.new(4)
          source_result = Models::SourceResult.new(id: 4, event_category: Models::EventCategory.new(category), place: 21, date: Date.today)
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

        def test_many_ties
          men_9_18 = Models::Category.new("Men 9-18")
          rules = Rules.new(category_rules: [Models::CategoryRule.new(men_9_18)], place_by: "place")
          calculator = Calculator.new(rules: rules, source_results: [])
          event_category = calculator.event_categories.first

          date = Date.new(2018, 10, 15)

          junior_men_9 = Models::Category.new("Junior Men 9")
          participant = Models::Participant.new(0)
          source_result = Models::SourceResult.new(id: 0, event_category: Models::EventCategory.new(junior_men_9), place: 1, date: date)
          result = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result

          participant = Models::Participant.new(1)
          source_result = Models::SourceResult.new(id: 1, event_category: Models::EventCategory.new(junior_men_9), place: 2, date: date)
          result = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result

          junior_men_10_12 = Models::Category.new("Junior Men 10-12")
          participant = Models::Participant.new(2)
          source_result = Models::SourceResult.new(id: 2, event_category: Models::EventCategory.new(junior_men_10_12), place: 1, age: 11, date: date)
          result = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result

          participant = Models::Participant.new(3)
          source_result = Models::SourceResult.new(id: 3, event_category: Models::EventCategory.new(junior_men_10_12), place: 2, age: 11, date: date)
          result = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result
          participant = Models::Participant.new(4)
          source_result = Models::SourceResult.new(id: 4, event_category: Models::EventCategory.new(junior_men_10_12), place: 3, age: 11, date: date)
          result = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result

          participant = Models::Participant.new(5)
          source_result = Models::SourceResult.new(id: 5, event_category: Models::EventCategory.new(junior_men_10_12), place: 4, age: 10, date: date)
          result = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result

          junior_men_13_14 = Models::Category.new("Junior Men 13-14")
          participant = Models::Participant.new(6)
          source_result = Models::SourceResult.new(id: 6, event_category: Models::EventCategory.new(junior_men_13_14), place: 1, age: 14, date: date)
          result = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result

          participant = Models::Participant.new(7)
          source_result = Models::SourceResult.new(id: 7, event_category: Models::EventCategory.new(junior_men_13_14), place: 2, age: 13, date: date)
          result = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result

          participant = Models::Participant.new(8)
          source_result = Models::SourceResult.new(id: 8, event_category: Models::EventCategory.new(junior_men_13_14), place: 3, age: 14, date: date)
          result = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result

          participant = Models::Participant.new(9)
          source_result = Models::SourceResult.new(id: 9, event_category: Models::EventCategory.new(junior_men_13_14), place: 4, age: 13, date: date)
          result = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result

          junior_men_15_16 = Models::Category.new("Junior Men 15-16")
          participant = Models::Participant.new(10)
          source_result = Models::SourceResult.new(id: 10, event_category: Models::EventCategory.new(junior_men_15_16), place: 1, age: 16, date: date)
          result = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result

          participant = Models::Participant.new(11)
          source_result = Models::SourceResult.new(id: 11, event_category: Models::EventCategory.new(junior_men_15_16), place: 2, age: 15, date: date)
          result = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result

          participant = Models::Participant.new(12)
          source_result = Models::SourceResult.new(id: 12, event_category: Models::EventCategory.new(junior_men_15_16), place: 3, age: 15, date: date)
          result = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result

          participant = Models::Participant.new(13)
          source_result = Models::SourceResult.new(id: 13, event_category: Models::EventCategory.new(junior_men_15_16), place: 4, age: 16, date: date)
          result = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result

          junior_men_17_18 = Models::Category.new("Junior Men 17-18")
          participant = Models::Participant.new(14)
          source_result = Models::SourceResult.new(id: 14, event_category: Models::EventCategory.new(junior_men_17_18), place: 1, age: 17, date: date)
          result = Models::CalculatedResult.new(participant, [source_result])
          event_category.results << result

          Place.calculate! calculator

          results = calculator.event_categories.first.results.sort_by(&:place)

          first_place_results = results.select { |r| r.place == "1" }
          assert_equal 5, first_place_results.size
          assert first_place_results.all?(&:tied?)

          assert(results.none? { |r| r.place == "2" })
          assert(results.none? { |r| r.place == "3" })
          assert(results.none? { |r| r.place == "4" })
          assert(results.none? { |r| r.place == "5" })

          sixth_place_results = results.select { |r| r.place == "6" }
          assert_equal 4, sixth_place_results.size
          assert sixth_place_results.all?(&:tied?)

          tenth_place_results = results.select { |r| r.place == "10" }
          assert_equal 3, tenth_place_results.size
          assert tenth_place_results.all?(&:tied?)

          thirteenth_place_results = results.select { |r| r.place == "13" }
          assert_equal 3, thirteenth_place_results.size
          assert thirteenth_place_results.all?(&:tied?)

          assert(results.none? { |r| r.place.to_i > 15 })
        end

        def test_by_place_considers_ability
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
      end
    end
  end
end
