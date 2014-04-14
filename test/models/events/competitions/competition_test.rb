require File.expand_path("../../../../test_helper", __FILE__)

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

  def test_find_for_year
    assert_equal nil, Competition.find_for_year, "Should not find anything when no Competitions in DB"
    assert_equal nil, Competition.find_for_year(2005), "Should not find anything when no Competitions in DB"

    competition = Competition.create!
    assert_equal competition, Competition.find_for_year, "Should find current Competition"
    assert_equal nil, Competition.find_for_year(2005), "Should not find anything when no Competitions in DB for this year"

    competition_in_2005 = Competition.create!(date: Time.zone.local(2005))
    assert_equal competition, Competition.find_for_year, "Should find current Competition"
    assert_equal competition_in_2005, Competition.find_for_year(2005), "Should not find anything when no Competitions in DB for this year"
  end

  def test_team_competition_find_for_year
    assert_equal nil, TestCompetition.find_for_year, "find with nothing in DB"

    competition = TestCompetition.create!
    assert_equal competition, TestCompetition.find_for_year, "find in DB"
    assert_equal nil, TestCompetition.find_for_year(2005), "find in DB, different year"

    competition = TestCompetition.create!(date: Date.new(2005))
    assert_equal competition, TestCompetition.find_for_year(2005), "find in DB with multiple events"
  end

  def test_dont_dupe_old_events_on_calc
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

  def test_dont_dupe_races_on_calc
    assert_difference "Event.count", 1 do
      TestCompetition.calculate!
    end

    assert_difference "Event.count", 0 do
      TestCompetition.calculate!
    end
  end

  def test_calc_no_source_results
    competition = TestCompetition.find_or_create_for_year
    competition.source_events << FactoryGirl.create(:event)
    TestCompetition.calculate!
  end

  def test_races_creation
    competition = TestCompetition.create!
    category = Category.find_by_name("KOM")
    assert_equal category, competition.races.first.category, "category"
  end

  def test_events
    competition = TestCompetition.find_or_create_for_year
    assert_equal(0, competition.source_events.count, 'Events')

    competition.source_events << FactoryGirl.create(:event)
    assert_equal(1, competition.source_events.count, 'Events')
    competition.source_events << FactoryGirl.create(:event)
    assert_equal(2, competition.source_events.count, 'Events')
  end

  def test_source_event_ids
    competition = TestCompetitionWithSourceEvents.create!
    assert !competition.source_event_ids(nil).nil?, "Event IDs shouldn't be nil"
    assert competition.source_event_ids(nil).empty?, "Should have no event IDs"
  end
end
