# frozen_string_literal: true

require File.expand_path("../../test_case", __dir__)
require File.expand_path("../../../app/models/results/comparison", __dir__)

# :stopdoc:
module Results
  class ComparisonTest < Ruby::TestCase
    class TestResult
      include Results::Comparison

      attr_accessor :first_name,
                    :id,
                    :last_name,
                    :person_id,
                    :person_name,
                    :preliminary,
                    :place,
                    :points,
                    :rejected,
                    :team_id,
                    :team_name

      def initialize(attr = {})
        attr.each do |k, v|
          send "#{k}=", v
        end
      end

      def numeric_place?
        place && place.to_i > 0
      end

      def rejected?
        @rejected ||= false
      end

      def inspect
        "#<Result #{place} #{first_name} #{last_name}>"
      end
    end

    def test_competition_result_hash
      result_1 = TestResult.new
      result_2 = TestResult.new
      assert_equal result_1.competition_result_hash, result_2.competition_result_hash, "empty results"

      result_1 = TestResult.new(person_id: 1)
      result_2 = TestResult.new(person_id: 1)
      assert_equal result_1.competition_result_hash, result_2.competition_result_hash, "same person"

      result_1 = TestResult.new(person_id: 1)
      result_2 = TestResult.new(person_id: 2)
      assert result_1.competition_result_hash != result_2.competition_result_hash, "different people"
    end

    def test_competition_result_hash_all_fields_equal
      result_1 = TestResult.new(person_id: 2, person_name: "Chris", place: "3", points: 4, team_id: 5, team_name: "Mercury")
      result_2 = TestResult.new(person_id: 2, person_name: "Chris", place: "3", points: 4, team_id: 5, team_name: "Mercury")
      assert result_1.competition_result_hash == result_2.competition_result_hash, "all field the same"
    end

    def test_competition_result_hash_one_difference
      result_1 = TestResult.new(person_id: 2, person_name: "Chris", place: "3", points: 4, team_id: 5, team_name: "Mercury")
      result_2 = TestResult.new(person_id: 3, person_name: "Chris", place: "3", points: 4, team_id: 5, team_name: "Mercury")
      assert result_1.competition_result_hash != result_2.competition_result_hash, "person_id different"

      result_1 = TestResult.new(person_id: 2, person_name: "Chris", place: "3", points: 4, team_id: 5, team_name: "Mercury")
      result_2 = TestResult.new(person_id: 2, person_name: "Christopher", place: "3", points: 4, team_id: 5, team_name: "Mercury")
      assert result_1.competition_result_hash != result_2.competition_result_hash, "person_name different"

      result_1 = TestResult.new(person_id: 2, person_name: "Chris", place: "3", points: 4, team_id: 5, team_name: "Mercury")
      result_2 = TestResult.new(person_id: 2, person_name: "Chris", place: "4", points: 4, team_id: 5, team_name: "Mercury")
      assert result_1.competition_result_hash != result_2.competition_result_hash, "place different"

      result_1 = TestResult.new(person_id: 2, person_name: "Chris", place: "3", points: 4, team_id: 5, team_name: "Mercury")
      result_2 = TestResult.new(person_id: 2, person_name: "Chris", place: "3", points: 5, team_id: 5, team_name: "Mercury")
      assert result_1.competition_result_hash != result_2.competition_result_hash, "points different"

      result_1 = TestResult.new(person_id: 2, person_name: "Chris", place: "3", points: 4, team_id: 5, team_name: "Mercury")
      result_2 = TestResult.new(person_id: 2, person_name: "Chris", place: "3", points: 4, team_id: 6, team_name: "Mercury")
      assert result_1.competition_result_hash != result_2.competition_result_hash, "team_id different"

      result_1 = TestResult.new(person_id: 2, person_name: "Chris", place: "3", points: 4, team_id: 5, team_name: "Mercury")
      result_2 = TestResult.new(person_id: 2, person_name: "Chris", place: "3", points: 4, team_id: 5, team_name: "Postal")
      assert result_1.competition_result_hash != result_2.competition_result_hash, "team_name different"
    end

    def test_rejected_results
      first_place = TestResult.new(first_name: "Zach", last_name: "Taylor", place: "1")
      rejected_1 = TestResult.new(first_name: "Abram", last_name: "McName", place: nil, rejected: true)
      dq = TestResult.new(first_name: "Melodie", last_name: "Doe", place: "DQ")
      rejected_2 = TestResult.new(first_name: "Yaz", last_name: "Smith", place: nil, rejected: true)
      rejected_3 = TestResult.new(first_name: "Lori", last_name: "Smith", place: nil, rejected: true)

      assert_equal [first_place, dq, rejected_1, rejected_3, rejected_2],
                   [first_place, rejected_1, dq, rejected_2, rejected_3].sort
    end

    def test_nils
      result_1 = TestResult.new(place: "3")
      result_2 = TestResult.new(person_id: 2, person_name: "Chris", place: "3", points: 4, team_id: 5, team_name: "Mercury")
      assert result_1.competition_result_hash != result_2.competition_result_hash, "some fields nil"
    end

    def test_same_values_different_fields
      result_1 = TestResult.new(person_id: 2, team_id: 5)
      result_2 = TestResult.new(person_id: 5, team_id: 2)
      assert result_1.competition_result_hash != result_2.competition_result_hash
    end
  end
end
