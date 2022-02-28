#! /usr/bin/env ruby
# frozen_string_literal: true

event_ids = Result
  .includes(:person, :race, :team)
  .joins(race: :event)
  .where(competition_result: false)
  .where(team_competition_result: false)
  .where("events.type": SingleDayEvent)
  .pluck(:event_id)
  .uniq

CSV.open("results.csv", "wb") do |csv|
  csv << ["date", "name", "city", "state", "results"]
  event_ids.each do |event_id|
    event = Event.find(event_id)
    results = Result.where(event_id: event_id).count
    csv << [event.date, event.full_name, event.city, event.state, results]
  end
end
