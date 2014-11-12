require File.expand_path("../../../test_case", __FILE__)
require File.expand_path("../../../../../app/models/results/comparison", __FILE__)

# :stopdoc:
module Results
  class ComparisonTest < Ruby::TestCase

    class TestResult
      include Results::Comparison

      attr_accessor :id, :person_id, :person_name, :preliminary, :place, :points, :team_id, :team_name

      def initialize(attr = {})
        attr.each do |k, v|
          send "#{k}=", v
        end
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
