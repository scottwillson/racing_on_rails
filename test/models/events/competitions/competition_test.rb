require "test_helper"
require_relative "../../../../app/models/competitions/calculations/structs"

module Competitions
  # :stopdoc:
  class CompetitionTest < ActiveSupport::TestCase
    class TestCompetition < Competition
      def friendly_name
        "KOM"
      end
    end

    class TestCompetitionWithSourceEvents < Competition
      def source_events?
        true
      end
    end

    test "find for year" do
      assert_equal nil, Competition.find_for_year, "Should not find anything when no Competitions in DB"
      assert_equal nil, Competition.find_for_year(2005), "Should not find anything when no Competitions in DB"

      competition = Competition.create!
      assert_equal competition, Competition.find_for_year, "Should find current Competition"
      assert_equal nil, Competition.find_for_year(2005), "Should not find anything when no Competitions in DB for this year"

      competition_in_2005 = Competition.create!(date: Time.zone.local(2005))
      assert_equal competition, Competition.find_for_year, "Should find current Competition"
      assert_equal competition_in_2005, Competition.find_for_year(2005), "Should not find anything when no Competitions in DB for this year"
    end

    test "team competition find for year" do
      assert_equal nil, TestCompetition.find_for_year, "find with nothing in DB"

      competition = TestCompetition.create!
      assert_equal competition, TestCompetition.find_for_year, "find in DB"
      assert_equal nil, TestCompetition.find_for_year(2005), "find in DB, different year"

      competition = TestCompetition.create!(date: Date.new(2005))
      assert_equal competition, TestCompetition.find_for_year(2005), "find in DB with multiple events"
    end

    test "dont dupe old events on calc" do
      assert_difference "Event.count", 1 do
        TestCompetition.calculate!
      end

      assert_difference "Event.count", 1 do
        TestCompetition.calculate!(2005)
      end

      assert_difference "Event.count", 0 do
        TestCompetition.calculate!
      end

      assert_difference "Event.count", 0 do
        TestCompetition.calculate!(2005)
      end
    end

    test "dont dupe races on calc" do
      assert_difference "Event.count", 1 do
        TestCompetition.calculate!
      end

      assert_difference "Event.count", 0 do
        TestCompetition.calculate!
      end
    end

    test "calc no source results" do
      competition = TestCompetition.find_or_create_for_year
      competition.source_events << FactoryGirl.create(:event)
      TestCompetition.calculate!
    end

    test "races creation" do
      competition = TestCompetition.create!
      category = Category.find_by_name("KOM")
      assert_equal category, competition.races.first.category, "category"
    end

    test "events" do
      competition = TestCompetition.find_or_create_for_year
      assert_equal(0, competition.source_events.count, 'Events')

      competition.source_events << FactoryGirl.create(:event)
      assert_equal(1, competition.source_events.count, 'Events')
      competition.source_events << FactoryGirl.create(:event)
      assert_equal(2, competition.source_events.count, 'Events')
    end

    test "source event ids" do
      competition = TestCompetitionWithSourceEvents.create!
      assert !competition.source_event_ids(nil).nil?, "Event IDs shouldn't be nil"
      assert competition.source_event_ids(nil).empty?, "Should have no event IDs"
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
      result_1 = FactoryGirl.create(:result, race: race, event: competition)
      result_2 = FactoryGirl.create(:result, race: race, event: competition)

      new_calculated_result = ::Struct::CalculatorResult.new
      new_calculated_result.participant_id = 9999

      existing_calculated_result = ::Struct::CalculatorResult.new
      existing_calculated_result.participant_id = result_2.person_id

      new_results, existing_results, obselete_results = competition.partition_results([ new_calculated_result, existing_calculated_result ], race)

      assert_equal [ 9999 ], new_results.map(&:participant_id), "new_results"
      assert_equal [ result_2.person_id ], existing_results.map(&:participant_id), "existing_results"
      assert_equal [ result_1.person_id ], obselete_results.map(&:person_id), "obselete_results"
    end
  end
end
