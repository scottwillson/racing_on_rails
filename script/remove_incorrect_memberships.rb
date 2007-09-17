#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../config/boot'
require 'commands/runner'

racer_ids = Racer.connection.select_values(%Q{
  select racers.id 
  from racers, results, races, standings, events 
  where member_from is not null 
  and racers.id not in (select racer_id from race_numbers) 
  and racers.id not in (select racer_id from results where number is not null and ((number between 1 and 999) or (number > 1099))) 
  and racers.id = results.racer_id 
  and races.id=results.race_id 
  and racers.road_category is null
  and standings.id = races.standings_id 
  and events.id = standings.event_id 
  and events.type <> 'RiderRankings' 
  and events.date <= member_from 
  group by racer_id;
})

Racer.transaction do
  for id in racer_ids
    racer = Racer.find(id)
    racer.member = false
    racer.member_from = nil
    racer.member_to = nil
    p racer
    racer.save!
  end
end
