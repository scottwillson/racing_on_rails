# frozen_string_literal: true

module Calculations::V3::CalculationConcerns::SourceResults
  extend ActiveSupport::Concern

  def associations_by_name
    return @associations_by_name if @associations_by_name

    @associations_by_name = {}
    RacingAssociation.find_each do |association|
      @associations_by_name[association.short_name] = Calculations::V3::Models::Association.new(id: association.id)
    end

    @associations_by_name
  end

  def model_disciplines
    disciplines.map do |discipline|
      Calculations::V3::Models::Discipline.new(discipline.name)
    end
  end

  # Find or create Models::Event from source result Event cache
  def model_events
    @model_events ||= Hash.new do |cache, id|
      event = source_result_events[id]

      model_event = Calculations::V3::Models::Event.new(
        calculated: calculated?(event),
        date: event.date.to_date,
        discipline: Calculations::V3::Models::Discipline.new(event.discipline),
        # TODO: end_date triggers SQL
        end_date: event.end_date.to_date,
        id: event.id,
        multiplier: multiplier(event.id),
        sanctioned_by: associations_by_name[event.sanctioned_by]
      )

      if event.parent_id
        model_events[event.parent_id].add_child model_event
      end

      cache[id] = model_event
    end
  end

  def model_participant(source_result)
    person = source_result.person

    membership = nil
    if person&.member_from && person&.member_to
      membership = person.member_from..person.member_to
    end

    Calculations::V3::Models::Participant.new(
      source_result.person_id,
      membership: membership
    )
  end

  def model_source_events
    calculations_events
      .reject { |e| e == event }
      .map { |event| model_events[event.id] }
  end

  def multiplier(event_id)
    event = calculations_events.detect { |e| e.event_id == event_id }
    event&.multiplier || 1
  end

  # Create event records cache: Hash by ud
  def populate_source_result_events
    ::Event.year(year).each_with_object({}) do |event, events|
      events[event.id] = event
    end
  end

  # Map ActiveRecord records to Calculations::V3::Models so Calculator can calculate! them
  def results_to_models(source_results)
    source_results.map do |result|
      category = Calculations::V3::Models::Category.new(result.race_name)
      event = model_events[result.event_id]
      Calculations::V3::Models::SourceResult.new(
        date: result.date,
        event_category: Calculations::V3::Models::EventCategory.new(category, event),
        id: result.id,
        participant: model_participant(result),
        place: result.place
      )
    end
  end

  # Consider results from these events
  def source_events
    # Series overall like Cross Crusade, Tabor
    if source_event
      source_event.children

    # BAR: Overall calculated from Criterium, Road, etc.
    elsif source_event_keys.any?
      Event.year(year).joins(:calculation).where("calculations.key" => source_event_keys)

    # Association-sponsored competition like the Oregon Cup, OWPS
    elsif specific_events?
      events

    # Ironman
    else
      Event.year(year)
    end
  end

  # Event records cache. Complicated to recurse up parent tree. Instead, fetch
  # each event once and use same instance in Model graph.
  # Each year has less than 1_000 events, so fetch them all.
  def source_result_events
    @source_result_events ||= populate_source_result_events
  end

  def source_results
    source_results = Result
                     .includes(:person)
                     .joins(race: :event)
                     .where.not(event: event)
                     .where(year: year)
                     .where("events.type" => Event::TYPES + [nil]) # Skip old Competitions

    if source_event
      source_results = source_results
                       .where("events.parent_id" => source_event)
                       .where(competition_result: false)

    elsif specific_events?
      source_results = source_results.where(event: source_events)
    end

    if source_event_keys.any?
      source_results = source_results.where(event_id: source_events.ids)
    end

    if discipline?
      source_results = source_results.where("events.discipline" => disciplines.map(&:name))
    end

    source_results
  end
end
