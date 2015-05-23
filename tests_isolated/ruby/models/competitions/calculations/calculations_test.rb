require_relative "../../../test_case"

module Competitions
  module Calculations
    class CalculationsTest < Ruby::TestCase
      def assert_equal_results(expected, actual)
        [ expected, actual ].each do |results|
          results.each { |result| result.scores.sort_by!(&:numeric_place); result.scores.sort_by!(&:date) }
          results.sort_by!(&:place)
          results.sort_by!(&:participant_id)
        end

        unless expected == actual
          expected_message = pretty_to_string(expected)
          actual_message = pretty_to_string(actual)
          flunk("Results not equal." + "\nExpected:\n" + expected_message + "Actual:\n" + actual_message)
        end
      end

      def assert_equal_scores(expected, actual)
        [ expected, actual ].each do |scores|
          scores.sort_by!(&:participant_id)
          scores.sort_by!(&:numeric_place)
          scores.sort_by!(&:date)
        end

        unless expected == actual
          expected_message = pretty_to_string_scores(expected)
          actual_message = pretty_to_string_scores(actual)
          flunk("Scores not equal." + "\nExpected:\n" + expected_message + "Actual:\n" + actual_message)
        end
      end

      def pretty_to_string(results)
        message = ""
        results.each do |r|
          message << "  Result place #{r.place} participant_id: #{r.participant_id} points: #{r.points} preliminary: #{r.preliminary} team_size: #{r.team_size}"
          message << "\n"
          r.scores.each do |s|
            message << "    Score place: #{s.numeric_place} points: #{s.points} date: #{s.date} event_id: #{s.event_id}"
            message << "\n"
          end
          message << "\n" if r.scores.size > 0
        end
        message
      end

      def pretty_to_string_scores(scores)
        message = ""
        scores.each do |s|
          message << "  Score place #{s.numeric_place} participant_id: #{s.participant_id} source_result_id: #{s.source_result_id} event_id: #{s.event_id} points: #{s.points}"
          message << "\n"
        end
        message
      end

      def result(hash = {})
        result = Struct::CalculatorResult.new

        scores = hash[:scores] || []
        scores.map! do |score|
          struct = Struct::CalculatorScore.new
          score.each do |key, value|
            struct[key] = value
          end
          struct
        end
        hash[:scores] = scores

        hash.each do |key, value|
          result[key] = value
        end

        result
      end

      def score(hash = {})
        score = Struct::CalculatorScore.new

        hash.each do |key, value|
          score[key] = value
        end
        score
      end

      def end_of_year
        @end_of_year ||= Date.new(Date.today.year, 12, 31)
      end
    end
  end
end
