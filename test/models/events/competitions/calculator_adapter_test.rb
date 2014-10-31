require "test_helper"
require "competitions/calculations/structs"

module Competitions
  # :stopdoc:
  class CalculatorAdapterTest < ActiveSupport::TestCase
    class TestCompetition < Competition
      include Calculations::CalculatorAdapter

      def friendly_name
        "KOM"
      end
    end
    
    test "partition_results with no results" do
      competition = TestCompetition.find_or_create_for_year
      race = competition.races(true).first
      new_results, existing_results, obselete_results = competition.partition_results([], race)
      assert_equal [], new_results, "new_results"
      assert_equal [], existing_results, "existing_results"
      assert_equal [], obselete_results, "obselete_results"
    end
    
    test "partition_results" do
      competition = TestCompetition.find_or_create_for_year
      race = competition.races(true).first
      FactoryGirl.create(:result, race: race, event: competition, person_id: 1)
      FactoryGirl.create(:result, race: race, event: competition, person_id: 2)
      
      new_calculated_result = ::Struct::CalculatorResult.new
      new_calculated_result.participant_id = 3
      
      existing_calculated_result = ::Struct::CalculatorResult.new
      existing_calculated_result.participant_id = 2
      
      new_results, existing_results, obselete_results = competition.partition_results([ new_calculated_result, existing_calculated_result ], race)

      assert_equal [ 3 ], new_results.map(&:participant_id), "new_results"
      assert_equal [ 2 ], existing_results.map(&:participant_id), "existing_results"
      assert_equal [ 1 ], obselete_results.map(&:person_id), "obselete_results"
    end
  end
end
