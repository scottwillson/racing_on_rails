require File.expand_path("../../../../test_helper", __FILE__)

# :stopdoc:
class IronmanTest < ActiveSupport::TestCase
  def test_count_single_day_events
    old_team = FactoryGirl.create(:team, :name => "Old Team")
    person = FactoryGirl.create(:person, :team => old_team)
    series = Series.create!
    senior_men = FactoryGirl.create(:category)
    series.races.create!(:category => senior_men).results.create(:place => "1", :person => person)

    Ironman.any_instance.expects(:expire_cache).at_least_once
    Ironman.calculate!

    ironman = Ironman.find_for_year
    assert_equal(0, ironman.races.first.results.count, "Should have no Ironman result for a Series result")

    event = series.children.create!
    event.races.create!(:category => senior_men).results.create(:place => "1", :person => person, :team_name => "Source Result Team")

    # Change team
    team = FactoryGirl.create(:team, :name => "Current Team")
    person.team = team
    person.save!

    Ironman.calculate!

    ironman.reload
    assert_equal(1, ironman.races.first.results.count, "Should have one Ironman result for a SingleDayEvent result")
    assert_equal(1, ironman.races.first.results.first.scores.count, "Should have one Ironman score for a SingleDayEvent result")

    # Check that we can calculate again
    Ironman.calculate!

    ironman.reload
    assert_equal(1, ironman.races.first.results.count, "Should have one Ironman result for a SingleDayEvent result")
    assert_equal(1, ironman.races.first.results.first.scores.count, "Should have one Ironman score for a SingleDayEvent result")
    assert_equal team, ironman.races.first.results.first.team, "Should use person's current team, not source result team"
  end

  def test_count_child_events
    person = FactoryGirl.create(:person)
    event = SingleDayEvent.create!
    child = event.children.create!
    senior_men = FactoryGirl.create(:category)
    child.races.create!(:category => senior_men).results.create(:place => "1", :person => person)
    assert(child.ironman?, "Child event should count towards Ironman")

    Ironman.calculate!

    ironman = Ironman.find_for_year
    assert_equal(1, ironman.races.first.results.count, "Should have one Ironman result for a child Event result")
    assert_equal(1, ironman.races.first.results.first.scores.count, "Should have one Ironman score for a child Event result")
  end

  def test_skip_anything_other_than_single_day_event
    person = FactoryGirl.create(:person)
    event = FactoryGirl.create(:time_trial_event)
    senior_men = FactoryGirl.create(:category)
    event.races.create!(:category => senior_men).results.create(:place => "99", :person => person)
    combined_results = CombinedTimeTrialResults.create!(:parent => event)
    assert(!combined_results.ironman?, "CombinedTimeTrialResults event should not count towards Ironman")

    Ironman.calculate!

    ironman = Ironman.find_for_year
    assert_equal(1, ironman.races.first.results.count, "Should have one Ironman result for a TT result")
    assert_equal(1, ironman.races.first.results.first.scores.count, "Should have one Ironman score for a TT result")
  end

  def test_parent_event_results_do_not_count
    person = FactoryGirl.create(:person)
    senior_men = FactoryGirl.create(:category)
    series = Series.create!
    series.races.create!(:category => senior_men).results.create(:place => "1", :person => person)

    # Only way to exclude these results is to manually set ironman? to false
    event = series.children.create!(:ironman => false)
    event.races.create!(:category => senior_men).results.create(:place => "1", :person => person)

    child = event.children.create!
    child.races.create!(:category => senior_men).results.create(:place => "1", :person => person)

    Ironman.calculate!

    ironman = Ironman.find_for_year
    assert_equal(1, ironman.races.first.results.count, "Should have one Ironman result for a child Event result, but no others")
    assert_equal(1, ironman.races.first.results.first.scores.count, "Should have one Ironman score for a child Event result, but no others")
  end

  # TODO Move to superclass once superclass uses them
  def test_source_results_no_results
    ironman = Ironman.create!
    assert_equal [], ironman.source_results(ironman.races.first).to_a, "source_results"
  end

  def test_source_results
    person = FactoryGirl.create(:person, name: "Greg Lemond", member_from: Date.new(2005, 8, 1), member_to: Date.new(2010, 12, 31))
    source_result = FactoryGirl.create(:result, place: "12", person: person)
    ironman = Ironman.create!
    expected = {
      "id" => source_result.id,
      "participant_id" => source_result.person.id,
      "member_from" => Date.new(2005, 8, 1),
      "member_to" => Date.new(2010, 12, 31),
      "place" => "12",
      "event_id" => source_result.event.id,
      "race_id" => source_result.race_id,
      "date" => source_result.event.date,
      "year" => Time.zone.now.year
    }
    assert_equal [ expected ], ironman.source_results(ironman.races.first).to_a, "source_results"
  end

  def test_create_competition_results_for
    person = FactoryGirl.create(:person)
    result1 = FactoryGirl.create(:result, person: person)
    result2 = FactoryGirl.create(:result, person: person)

    Struct.new("TestResult", :place, :participant_id, :points, :scores)
    Struct.new("TestScore", :points, :source_result_id)
    scores = [ Struct::TestScore.new(1, result1.id), Struct::TestScore.new(1, result2.id) ]
    calculated_results = [ Struct::TestResult.new(1, person.id, 2, scores) ]

    ironman = Ironman.create!
    ironman.create_competition_results_for(calculated_results, ironman.races.first)
    assert_equal 3, Result.count
    assert_equal 2, Score.count

    ironman_result = ironman.races.first.results.first
    assert_equal "1", ironman_result.place, "place"
    assert_equal person.id, ironman_result.person_id, "person_id"
    assert_equal person.team_id, ironman_result.team_id, "team_id"
    assert_equal ironman_result.event, ironman_result.event, "event"
    assert_equal ironman.races.first, ironman_result.race, "race"
    assert_equal true, ironman_result.competition_result?, "competition_result"
    assert_equal 2, ironman_result.points, "points"
  end

  def test_create_competition_results_for_no_results
    ironman = Ironman.create!
    ironman.create_competition_results_for([], ironman.races.first)
    assert_equal 0, Result.count
    assert_equal 0, Score.count
  end

  def test_team_ids_by_person_id_hash
    ironman = Ironman.create!
    assert_equal({}, ironman.team_ids_by_person_id_hash([]))
  end

  def test_team_ids_by_person_id_hash_no_results
    team = FactoryGirl.create(:team)
    person = FactoryGirl.create(:person, team: team)
    ironman = Ironman.create!
    Struct.new("TestResult2", :participant_id)
    assert_equal({ person.id => team.id }, ironman.team_ids_by_person_id_hash([ Struct::TestResult2.new(person.id) ]))
  end

  def test_create_score
    ironman = Ironman.create!
    source_result = FactoryGirl.create(:result)
    competition_result = ironman.races.first.results.create!
    score = ironman.create_score(competition_result, source_result.id, 12)
    assert_equal source_result.id, score.source_result_id, "source_result_id"
    assert_equal competition_result.id, score.competition_result_id, "competition_result_id"
    assert_equal 12, score.points, "points"
  end
end
