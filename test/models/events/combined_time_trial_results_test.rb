require File.expand_path("../../../test_helper", __FILE__)

# :stopdoc:
class CombinedTimeTrialResultsTest < ActiveSupport::TestCase
  test "create" do
    combined_results = CombinedTimeTrialResults.create_combined_results(FactoryGirl.create(:time_trial_event))
    assert_equal('Combined', combined_results.name, 'name')
    assert_equal(false, combined_results.ironman, 'Ironman')
    assert_equal(0, combined_results.bar_points, 'bar points')
    assert_equal(0, combined_results.races.size, 'combined_results.races')
  end

  test "combined tt" do
    event = FactoryGirl.create(:time_trial_event)
    race_1 = FactoryGirl.create(:race, event: event)
    race_2 = FactoryGirl.create(:race, event: event)
    race_3 = FactoryGirl.create(:race, event: event)
    result_1 = FactoryGirl.create(:result, race: race_1, place: "1", time: "1800")
    result_2 = FactoryGirl.create(:result, race: race_1, place: "2", time: "2112")
    result_3 = FactoryGirl.create(:result, race: race_2, place: "9", time: "1801")
    # Dupe result in different category should be ignored
    FactoryGirl.create(:result, race: race_3, place: "4", time: "1801", person: result_3.person)

    # Results with no time should not be included
    FactoryGirl.create(:result, race: race_2, place: "10")

    # Only include finishers
    FactoryGirl.create(:result, race: race_1, place: "DNF")
    FactoryGirl.create(:result, race: race_1, place: "DNF", time: 0)
    FactoryGirl.create(:result, race: race_1, place: "DQ", time: 12)

    CombinedTimeTrialResults.calculate!
    combined_results = event.combined_results(true)
    combined = combined_results.races.first
    assert_equal(3, combined.results.size, 'combined.results')
    _results = combined.results.sort

    result = _results[0]
    assert_equal('1', result.place, 'place')
    assert_equal(result_1.person, result.person, 'person')
    assert_equal(race_1.category, result.category, 'category')
    assert_equal('30:00.00', result.time_s, 'time_s')

    result = _results[1]
    assert_equal('2', result.place, 'place')
    assert_equal(result_3.person, result.person, 'person')
    assert_equal(race_2.category, result.category, 'category')
    assert_equal('30:01.00', result.time_s, 'time_s')

    result = _results[2]
    assert_equal('3', result.place, 'place')
    assert_equal(result_2.person, result.person, 'person')
    assert_equal(race_1.category, result.category, 'category')
    assert_equal('35:12.00', result.time_s, 'time_s')
  end

  test "destroy" do
    series = Series.create!(discipline: "Time Trial")
    FactoryGirl.create(:result, race: FactoryGirl.create(:race, event: series), place: "1", time: 1000)

    event = series.children.create!
    FactoryGirl.create(:result, race: FactoryGirl.create(:race, event: event), place: "1", time: 500)

    CombinedTimeTrialResults.calculate!

    assert_not_nil(series.combined_results(true), "Series parent should have combined results")
    assert_not_nil(event.combined_results(true), "Series child event parent should have combined results")

    series.reload
    event.reload
    event.destroy_races
    event.combined_results.destroy_races
    assert_nil(event.combined_results(true), "Series child event parent should not have combined results")
  end

  test "should not calculate combined results for combined results" do
    event = FactoryGirl.create(:time_trial_event)
    race = FactoryGirl.create(:race, event: event)
    FactoryGirl.create(:result, race: race, place: "1", time: 1800)

    CombinedTimeTrialResults.calculate!

    assert_not_nil(event.combined_results(true), "TT event should have combined results")
    result_id = event.combined_results.races.first.results.first.id

    race.reload
    race.calculate_members_only_places!
    event.reload
    result_id_after_member_place = event.combined_results(true).races.first.results.first.id
    assert_equal(result_id, result_id_after_member_place, "calculate_members_only_places! should not trigger combined results recalc")
  end

  test "class calculate! with no results" do
    assert_difference "CombinedTimeTrialResults.count", 0 do
      CombinedTimeTrialResults.calculate!
    end
  end

  test "class calculate!" do
    tt_result_1 = nil
    tt_result_2 = nil

    travel_to 1.day.ago do
      tt_result_1 = FactoryGirl.create(:time_trial_result)

      # Create TT result + combined results, then remove result
      # Should destroy
      result = FactoryGirl.create(:time_trial_result)
      tt_with_no_results = result.event
      CombinedTimeTrialResults.calculate!
      assert_equal 2, CombinedTimeTrialResults.count, "CombinedTimeTrialResults"
      result.destroy!

      tt_result_2 = FactoryGirl.create(:time_trial_result)
      FactoryGirl.create(:result)
      FactoryGirl.create(:event)
      FactoryGirl.create(:event, discipline: "Time Trial")

      CombinedTimeTrialResults.calculate!
      assert_equal 2, CombinedTimeTrialResults.count, "CombinedTimeTrialResults"
      assert tt_result_1.event.combined_results.present?, "combined_results"
      assert tt_result_2.event.combined_results.present?, "combined_results"
      assert tt_with_no_results.combined_results.blank?, "combined_results"
    end

    # No new results, nothing should change
    CombinedTimeTrialResults.calculate!
    CombinedTimeTrialResults.all.each do |e|
      assert e.updated_at < 1.hour.ago, "CombinedTimeTrialResults updated_at should be in past"
    end

    tt_1 = tt_result_1.event
    tt_1.races.first.results.create!(place: 2, time: 1000)
    CombinedTimeTrialResults.calculate!
    assert tt_1.combined_results(true).updated_at > 1.hour.ago, "CombinedTimeTrialResults updated_at should be recent"
    assert_equal 2, tt_1.combined_results.races.first.results.count, "combined_results"
    assert tt_result_2.event.updated_at < 1.hour.ago, "CombinedTimeTrialResults updated_at should be in past"
  end

  test "requires_combined_results_events" do
    tt = FactoryGirl.create(:time_trial_result).event

    FactoryGirl.create(:result)

    event = FactoryGirl.create(:time_trial_result).event
    event.update_attributes auto_combined_results: false

    FactoryGirl.create(:event, discipline: "Time Trial")

    assert_equal [ tt ], CombinedTimeTrialResults.requires_combined_results_events
  end
end
