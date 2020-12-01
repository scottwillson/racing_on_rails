# frozen_string_literal: true

require File.expand_path("../test_helper", __dir__)

# :stopdoc:
class ResultsHelperTest < ActionView::TestCase
  setup do
    stubs(mobile_request?: false)
  end

  test "results table" do
    race = Race.new(results: [Result.new(place: "1")])
    table = Nokogiri::HTML(results_table(Event.new, race))
    assert table.css("table.results").present?
  end

  test "results table one ttt" do
    race = Race.new(results: [
                      Result.new(place: "1"),
                      Result.new(place: "1"),
                      Result.new(place: "1")
                    ])
    table = Nokogiri::HTML(results_table(Event.new, race))
    assert table.css("table.results").present?
    assert table.css("td.place").present?, "Should have place column in #{table}"
  end

  test "participant event results table person" do
    table = Nokogiri::HTML(participant_event_results_table(Person.new, [Result.new(place: "1")]))
    assert table.css("table.results").present?
  end

  test "participant event results table team" do
    table = Nokogiri::HTML(participant_event_results_table(Team.new, [Result.new(place: "1")]))
    assert table.css("table.results").present?
  end

  test "edit results table" do
    race = FactoryBot.create(:result).race
    table = Nokogiri::HTML(edit_results_table(race))
    assert table.css("table.results").present?
  end

  test "scores table" do
    table = Nokogiri::HTML(scores_table(Result.new(place: "1")))
    assert table.css("table.results.scores").present?
  end

  test "results table for mobile" do
    stubs(mobile_request?: true)

    race = Race.new(results: [Result.new(place: "1", name: "Molly Cameron", team_name: "Veloshop", time: 1000, laps: 4)])

    table = Nokogiri::HTML(results_table(Event.new, race))
    assert table.css("table th.place").present?
    assert table.css("table th.name").present?
    assert table.css("table th.team_name").empty?, "only show mobile columns"
    assert table.css("table th.points").empty?
    assert table.css("table th.time").present?
    assert table.css("table th.laps").empty?, "only show mobile columns"
  end
end
