#! /usr/bin/env ruby
# frozen_string_literal: true

# Diagnose
calculations = Calculations::V3::Calculation.all.reject(&:valid?).select do |calculation|
  calculation.errors.full_messages.first == "Event cannot be source event"
end
puts "calculations with source event as event: #{calculations.size}"
puts

calculation_event_ids = Calculations::V3::Calculation.all.map(&:event).compact.map(&:id)

calculated_results = Result.where(event_id: calculation_event_ids).where("competition_result is false and team_competition_result is false")
puts "calculation event results not competition_result: #{calculated_results.count}"

calculated_results = Result.where(event_id: calculation_event_ids).where("id not in (select calculated_result_id from result_sources)")
puts "calculation event results not in result_sources: #{calculated_results.count}"
calculated_results.each do |r|
  puts("#{r.id} #{r.race_full_name} #{r.place} #{r.name} #{r.created_at} #{r.updated_at}")
end
puts "events with results not in result_sources: #{calculated_results.pluck(:event_id).uniq.size}"
Event.find(calculated_results.pluck(:event_id).uniq).sort.each do |event|
  puts "#{event.id} #{event.date} #{event.full_name} calc: #{event.calculation&.name}"
end
puts

calculated_results = Result.
  where(event_id: calculation_event_ids).
  where("id not in (select calculated_result_id from result_sources)").
  where("id not in (select competition_result_id from scores)")
puts "calculation event results not in result_sources nor scores: #{calculated_results.count}"
puts "events with results not in result_sources nor scores: #{calculated_results.pluck(:event_id).uniq.size}"
Event.find(calculated_results.pluck(:event_id).uniq).sort.each do |event|
  puts "#{event.id} #{event.date} #{event.full_name} calc: #{event.calculation&.name}"
end
puts

calculated_results = Result.
  where(event_id: calculation_event_ids).
  where("id not in (select calculated_result_id from result_sources)").
  where("id not in (select competition_result_id from scores)").
  where("competition_result is true or team_competition_result is true")
puts "calculation results not in result_sources nor scores: #{calculated_results.count}"
puts "events with results not in result_sources nor scores: #{calculated_results.pluck(:event_id).uniq.size}"
Event.find(calculated_results.pluck(:event_id).uniq).sort.each do |event|
  puts "#{event.id} #{event.date} #{event.full_name} calc: #{event.calculation&.name}"
end

calculated_results = Result.
  where(event_id: calculation_event_ids).
  where("id not in (select calculated_result_id from result_sources)").
  where("id in (select competition_result_id from scores)").
  where("competition_result is true or team_competition_result is true")
puts "calculation results only in scores: #{calculated_results.count}"
puts "events with results only in scores: #{calculated_results.pluck(:event_id).uniq.size}"
Event.find(calculated_results.pluck(:event_id).uniq).sort.each do |event|
  puts "#{event.id} #{event.date} #{event.full_name} calc: #{event.calculation&.name}"
end

# # Diagnose 2
# Need to filter out calculations
# events = Event.where("id in (select event_id from results, result_sources where results.id = calculated_result_id)")
# puts "events with calculated results in result_sources"
# events.each do |event|
#   puts "#{event.id} #{event.date} #{event.full_name} calc: #{event.calculation&.name}"
#   puts("!!! no calc") unless event.calculation
# end
#
# events = Event.where("id in (select event_id from results, result_sources where results.id = source_result_id)")
# puts "events with source results in result_sources"
# events.each do |event|
#   puts "#{event.id} #{event.date} #{event.full_name} calc: #{event.calculation&.name}"
#   puts("!!! calc") if event.calculation
# end
#
# # Diagnose 3
# with = Set.new
# without = Set.new
#
# count = Result.where(competition_result: true).count
# Result.where(competition_result: true).find_each.with_index do |result, index|
#   if index % 10_000 == 0
#     puts "#{index / count.to_f * 100} with: #{with.size} without: #{without.size}"
#   end
#
#   if result.sources.any?
#     with << result.event_id
#   else
#     without << result.event_id
#   end
# end

# puts "Events with source results"
# Event.find(with.to_a).sort.each do |event|
#   puts "#{event.id} #{event.date} #{event.full_name} #{event.calculation.name}"
# end
#
# puts
# puts "Events without source results"
# Event.find(without.to_a).sort.each do |event|
#   puts "#{event.id} #{event.date} #{event.full_name} calc: #{event.calculation&.name}"
# end

# Fix
Calculations::V3::Calculation.transaction do
  calculations = Calculations::V3::Calculation.all.reject(&:valid?).select do |calculation|
    calculation.errors.full_messages.first == "Event cannot be source event"
  end

  puts "Fix event for calculations:"
  calculations.each do |calculation|
    puts "#{calculation.id} #{calculation.name}"

    old_event = calculation.event

    new_event = Event.create!(
      date: old_event.date,
      discipline: old_event.discipline,
      name: "Series Overall",
      notes: old_event.notes,
      sanctioned_by: old_event.sanctioned_by,
      state: old_event.state,
      end_date: old_event.end_date,
      slug: old_event.slug,
      year: old_event.year
    )

    old_event.races.select(&:any_results?).each do |race|
      race.event = new_event
      race.save!
      race.results.each do |result|
        result.cache_event_attributes
        result.save!
        result.scores.each do |score|
          result.sources.create!(
            calculated_result_id: score.competition_result_id,
            points: score.points,
            source_result_id: score.source_result_id,
            created_at: score.created_at,
            updated_at: score.updated_at
          )
        end
      end
    end

    new_event.parent = calculation.events.map(&:parent).compact.uniq.sort.first
    new_event.save!

    calculation.event = new_event
    calculation.save!
  end

  puts "Fix competition flag"
  Calculations::V3::Calculation.all.each do |calculation|
    puts "#{calculation.id} #{calculation.name}"
    calculation.event&.races&.each do |race|
      if calculation.team?
        race.results.update_all(team_competition_result: true)
      else
        race.results.update_all(competition_result: true)
      end
    end
  end

  Event.find(25759).update!(name: "Team Competition")

  Event.find([13037, 13443]).each do |event|
    event.races.select(&:any_results?).each do |race|
      race.results.each do |result|
        result.scores.each do |score|
          result.sources.create!(
            calculated_result_id: score.competition_result_id,
            points: score.points,
            source_result_id: score.source_result_id,
            created_at: score.created_at,
            updated_at: score.updated_at
          )
        end
      end
    end
  end
end
