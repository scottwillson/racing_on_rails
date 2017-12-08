require "test_helper"

module Events
  # :stopdoc:
  class ResultsTest < ActiveSupport::TestCase
    test "find all with results" do
      event = FactoryBot.create(:result).event
      assert_equal([ event ], Event.find_all_with_results, "events")
    end

    test "find all with results with year" do
      event_with_results = FactoryBot.create(:event, date: Date.new(2003))
      race = FactoryBot.create(:race, event: event_with_results)
      FactoryBot.create(:result, race: race)

      # Event and race + event with no results
      FactoryBot.create(:event, date: Date.new(2003))
      FactoryBot.create(:race)

      assert_equal([ event_with_results ], Event.find_all_with_results(2003), "events")

      event_with_results = FactoryBot.create(:event, date: Date.new(2004))
      race = FactoryBot.create(:race, event: event_with_results)
      FactoryBot.create(:result, race: race)

      weekly_series_with_results = FactoryBot.create(:weekly_series, date: Date.new(2004))
      series_event = weekly_series_with_results.children.create!
      race = FactoryBot.create(:race, event: series_event)
      FactoryBot.create(:result, race: race)

      events = Event.find_all_with_results(2004)
      assert_equal_events([ event_with_results, weekly_series_with_results].sort, events.sort, "events")

      assert_equal([], Event.find_all_with_results(2005), "events")
    end

    test "find all with results with discipline" do
      FactoryBot.create(:discipline, name: "Road")
      FactoryBot.create(:discipline, name: "Circuit")
      FactoryBot.create(:discipline, name: "Criterium")
      FactoryBot.create(:discipline, name: "Track")

      event_with_results = FactoryBot.create(:event, date: Date.new(2003))
      race = FactoryBot.create(:race, event: event_with_results)
      FactoryBot.create(:result, race: race)

      assert_equal([ event_with_results ], Event.find_all_with_results(2003, Discipline["Road"]), "events")

      assert_equal([], Event.find_all_with_results(2003, Discipline["Criterium"]), "events")

      circuit_race = FactoryBot.create(:event, discipline: "Circuit")
      category = FactoryBot.create(:category)
      circuit_race.races.create!(category: category).results.create!

      track_event = FactoryBot.create(:event, discipline: "Track")
      track_event.races.create!(category: category).results.create!

      track_series = WeeklySeries.create!(discipline: "Track")
      track_series_event = track_series.children.create!
      track_series_event.races.create!(category: category).results.create!

      assert_equal([circuit_race], Event.find_all_with_results(Time.zone.today.year, Discipline["Road"]), "events")

      events = Event.find_all_with_results(Time.zone.today.year, Discipline["Track"])
      assert_equal([track_event, track_series].sort, events.sort, "events")
    end

    test "find all with only child event results" do
      series = WeeklySeries.create!
      series_event = series.children.create!
      child_event = series_event.children.create!
      child_event.races.create!(category: FactoryBot.create(:category)).results.create!

      assert(child_event.is_a?(Event), "Child event should be an Event")
      assert(!child_event.is_a?(SingleDayEvent), "Child event should not be an SingleDayEvent")

      assert_equal([series], Event.find_all_with_results, "weekly_series")
    end

    test "has results" do
      assert(!Event.new.any_results?, "New Event should not have results")

      event = SingleDayEvent.create!
      race = event.races.create!(category: FactoryBot.create(:category))
      assert(!event.any_results?, "Event with race, but no results should not have results")

      race.results.create!(place: 200, person: FactoryBot.create(:person))
      assert(event.any_results?, "Event with one result should have results")
    end

    test "races with results" do
      bb3 = FactoryBot.create(:event)
      assert(bb3.races_with_results.empty?, 'No races')

      sr_p_1_2 = FactoryBot.create(:category)
      bb3.races.create!(category: sr_p_1_2)
      assert(bb3.races_with_results.empty?, 'No results')

      senior_women = FactoryBot.create(:category)
      race_1 = bb3.races.create!(category: senior_women)
      race_1.results.create!
      assert_equal([race_1], bb3.races_with_results, 'One results')

      race_2 = bb3.races.create!(category: sr_p_1_2)
      race_2.results.create!
      women_4 = FactoryBot.create(:category)
      bb3.races.create!(category: women_4)
      assert_same_elements [ race_2, race_1 ], bb3.races_with_results, 'Two races with results'
    end

    test "children with results" do
      event = SingleDayEvent.create!
      assert_equal(0, event.children_with_results.size, "events_with_results: no child")
      assert_equal(0, event.children_with_results.size, "children_with_results: no child")

      event.children.create!
      assert_equal(0, event.children_with_results.size, "events_with_results: child with no results")
      assert_equal(0, event.children_with_results.size, "children_with_results: child with no results")

      category = FactoryBot.create(:category)
      event.children.create!.races.create!(category: category).results.create!
      assert_equal(1, event.children_with_results.size, "cached: events_with_results: 1 children with results")
      assert_equal(1, event.children_with_results.size, "refresh cache: events_with_results: 1 children with results")
      assert_equal(1, event.children_with_results.size, "refresh cache: children_with_results: 1 children with results")

      event.children.create!.races.create!(category: category).results.create!
      assert_equal(2, event.children_with_results.size, "refresh cache: events_with_results: 2 children with results")
      assert_equal(2, event.children_with_results.size, "refresh cache: children_with_results: 2 children with results")
    end

    test "children with results only child events" do
      series_event = FactoryBot.create(:series_event)
      child_event = series_event.children.create!
      FactoryBot.create(:result, race: FactoryBot.create(:race, event: child_event))
      series = Event.find(series_event.parent_id)

      assert_equal(1, series.children_with_results.size, "Should have child with results")
      assert_equal(series_event, series.children_with_results.first, "Should have child with results")
      assert_equal(1, series_event.children_with_results.size, "Should have child with results")
      assert_equal(child_event, series_event.children_with_results.first, "Should have child with results")
    end

    test "has results including children" do
      series_event = FactoryBot.create(:weekly_series_event)
      child_event = series_event.children.create!
      FactoryBot.create(:result, race: FactoryBot.create(:race, event: child_event))
      series = Event.find(series_event.parent_id)

      assert(series.any_results_including_children?, "Series any_results_including_children?")
      assert(series_event.any_results_including_children?, "Series Event any_results_including_children?")
      assert(child_event.any_results_including_children?, "Series Event child any_results_including_children?")
    end

    test "results_updated_at" do
      event = FactoryBot.create(:event)
      assert_nil event.results_updated_at, "results_updated_at with no results"

      result = nil
      travel_to 1.day.ago do
        result = FactoryBot.create(:result)
      end
      assert_equal result.reload.updated_at, result.event.results_updated_at, "results_updated_at should use result updated_at"
    end
  end
end
