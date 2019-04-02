# frozen_string_literal: true

# Rules to create and calculate results for event based on another event's results.
# Older code uses the term "Competition.""
# Link source event(s) with caculated Event.
# Handle all ActiveRecord work. All calculation occurs in pure-Ruby Calculator and Models.
class Calculations::V3::Calculation < ApplicationRecord
  serialize :points_for_place, Array

  has_many :calculation_categories, class_name: "Calculations::V3::Category"
  has_many :calculations_events, class_name: "Calculations::V3::Event"
  has_many :categories, through: :calculation_categories, class_name: "::Category"
  belongs_to :discipline, optional: true
  belongs_to :event, class_name: "::Event", dependent: :destroy, inverse_of: :calculation, optional: true
  has_many :events, through: :calculations_events, class_name: "::Event"
  belongs_to :source_event, class_name: "Event", optional: true

  before_save :set_name
  before_save :set_year

  validate :dates_are_same_year

  default_value_for(:year) {Time.zone.now.year}

  def set_name
    if name == "New Calculation" && source_event
      self.name = "#{source_event.name}: Overall"
    end
  end

  def set_year
    if source_event
      year = source_event.year
    end
  end

  # Find all source results with coarse scope (year, source_events)
  # Map results and calculation rules to calculate models
  # model calculate
  # serialize to DB
  def calculate!
    ActiveSupport::Notifications.instrument "calculate.calculations.#{name}.racing_on_rails" do
      transaction do
        add_event!
        results = results_to_models(source_results)
        calculator = Calculations::V3::Calculator.new(logger: logger, rules: rules, source_results: results)
        event_categories = calculator.calculate!
        save_results event_categories
      end
    end
  end

  def calculated?(event)
    event.competition? || event.type.nil? || event.type == "Event"
  end

  def add_event!
    return if event

    if source_event
      event = create_event!(date: source_event.date, end_date: source_event.end_date, name: "Overall")
      source_event.children << event
    else
      event = create_event!(date: Time.zone.local(year).beginning_of_year, end_date: Time.zone.local(year).end_of_year)
    end
  end

  def source_results
    source_results = Result.joins(race: :event)
                           .where.not(competition_result: true)
                           .where(year: year)

    if source_event
      source_results = source_results.where("events.parent_id" => source_event)
    end

    source_results
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
        participant: Calculations::V3::Models::Participant.new(result.person_id),
        place: result.place
      )
    end
  end

  # Event records cache. Complicated to recurse up parent tree. Want to fetch
  # each event once and use same instance in Model graph.
  # Each year has less than 1_000 events, so fetch them all once.
  def source_result_events
    @source_result_events ||= populate_source_result_events
  end

  # Create event records cache: Hash by ud
  def populate_source_result_events
    ::Event.year(year).each_with_object({}) do |event, events|
      events[event.id] = event
    end
  end

  # Find or create Models::Event from source result Event cache
  def model_events
    @model_events ||= Hash.new do |cache, id|
      event = source_result_events[id]

      model_event = Calculations::V3::Models::Event.new(
        calculated: calculated?(event),
        date: event.date,
        discipline: Calculations::V3::Models::Discipline.new(event.discipline),
        end_date: event.end_date,
        id: event.id,
        multiplier: multiplier(event.id)
      )

      if event.parent_id
        model_event.parent = model_events[event.parent_id]
      end

      cache[id] = model_event
    end
  end

  def model_source_events
    source_events
      .reject(&:competition?)
      .reject { |e| e == event }
      .map { |event| model_events[event.id] }
  end

  def multiplier(event_id)
    event = calculations_events.detect { |e| e.event_id == event_id }
    event&.multiplier || 1
  end

  def source_events
    if source_event
      source_event.children
    else
      Event.year(year)
    end
  end

  def rules
    @rules ||= Calculations::V3::Rules.new(
      category_rules: category_rules(categories),
      discipline: model_discipline,
      double_points_for_last_event: double_points_for_last_event?,
      minimum_events: minimum_events,
      points_for_place: points_for_place,
      maximum_events: maximum_events,
      source_events: model_source_events,
      weekday_events: weekday_events?
    )
  end

  # Map ActiveRecord records to Calculations::V3::Models so Calculator can calculate! them.
  # Categories are a subset of "rules."
  def category_rules(categories)
    calculation_categories.map do |calculation_category|
      category = Calculations::V3::Models::Category.new(calculation_category.category.name)
      Calculations::V3::Models::CategoryRule.new(
        category,
        maximum_events: calculation_category.maximum_events,
        reject: calculation_category.reject?
      )
    end
  end

  def model_discipline
    if discipline
      Calculations::V3::Models::Discipline.new(discipline.name)
    end
  end

  # Change to generic persist
  # Destroy obsolete races
  def save_results(event_categories)
    ActiveSupport::Notifications.instrument "save_results.calculations.#{name}.racing_on_rails" do
      delete_obsolete_races
      event_categories.each do |event_category|
        category = Category.find_or_create_by_normalized_name(event_category.name)
        race = event.races.find_or_create_by!(
          category: category,
          rejected: event_category.rejected?,
          rejection_reason: event_category.rejection_reason
        )

        race.destroy_duplicate_results!
        race.results.reload

        calculated_results = event_category.results
        new_results, existing_results, obsolete_results = partition_results(calculated_results, race)
        ActiveSupport::Notifications.instrument "partition_results.calculations.#{name}.racing_on_rails new_results: #{new_results.size} existing_results: #{existing_results.size} obsolete_results: #{obsolete_results.size}"
        create_calculated_results_for new_results, race
        update_calculated_results_for existing_results, race
        delete_calculated_results_for obsolete_results, race

        # event_category.results.each do |result|
        #   result_record = race.results.create!(
        #     person_id: result.participant.id,
        #     place: result.place,
        #     points: result.points,
        #     rejected: result.rejected?,
        #     rejection_reason: result.rejection_reason,
        #     team_id: team_id(result)
        #   )
        #
        #   result.source_results.each do |source_result|
        #     result_record.sources.create!(
        #       points: source_result.points,
        #       rejected: source_result.rejected?,
        #       rejection_reason: source_result.rejection_reason,
        #       source_result_id: source_result.id
        #     )
        #   end
        # end
      end
    end
  end

  def delete_obsolete_races
    ActiveSupport::Notifications.instrument "delete_obsolete_races.calculations.#{name}.racing_on_rails" do
    obsolete_races = event.races.reject { |race| race.name.in?(category_names) }
      logger.debug "delete_obsolete_races.calculations.#{name}.racing_on_rails.obsolete_races race_ids: #{obsolete_races.size} race_names: #{obsolete_races.map(&:name)}"
      if obsolete_races.any?
        race_ids = obsolete_races.map(&:id)
        ::ResultSource.where("calculated_result_id in (select id from results where race_id in (?))", race_ids).delete_all
        ::Result.where("race_id in (?)", race_ids).delete_all
      end
      obsolete_races.each { |race| event.races.delete(race) }
    end
  end

  def category_names
    categories.map(&:name)
  end

  def partition_results(calculated_results, race)
    participant_ids            = race.results.map(&:person_id)
    calculated_participant_ids = calculated_results.map(&:participant_id)

    new_participant_ids      = calculated_participant_ids - participant_ids
    existing_participant_ids = calculated_participant_ids & participant_ids
    obsolete_participant_ids = participant_ids - calculated_participant_ids

    [
      calculated_results.select { |r| r.participant_id.in?            new_participant_ids },
      calculated_results.select { |r| r.participant_id.in?            existing_participant_ids },
      race.results.select       { |r| r.person_id.in? obsolete_participant_ids }
    ]
  end

  def create_calculated_results_for(results, race)
    Rails.logger.debug "create_calculated_results_for #{race.name}"

    team_ids = team_ids_by_participant_id_hash(results)

    results.each do |result|
      calculated_result = ::Result.create!(
        competition_result: true,
        event: event,
        person_id: result.participant_id,
        place: result.place,
        points: result.points,
        race: race,
        team_id: team_ids[result.participant_id]
      )

      result.source_results.each do |source_result|
        create_result_source calculated_result, source_result.id, source_result.points
      end
    end

    true
  end

  def team_ids_by_participant_id_hash(results)
    team_ids_by_participant_id_hash = {}
    results.map(&:participant_id).uniq.each do |participant_id|
      team_ids_by_participant_id_hash[participant_id] = participant_id
    end

    ::Person.select("id, team_id").where("id in (?)", results.map(&:participant_id).uniq).map do |person|
      team_ids_by_participant_id_hash[person.id] = person.team_id
    end

    team_ids_by_participant_id_hash
  end

  def update_calculated_results_for(results, race)
    Rails.logger.debug "update_calculation_results_for #{race.name}"
    return true if results.empty?

    team_ids = team_ids_by_participant_id_hash(results)
    existing_results = race.results.where(person_id: results.map(&:participant_id)).includes(:sources)

    results.each do |result|
      update_calculated_result_for result, existing_results, team_ids
    end
  end

  def update_calculated_result_for(result, existing_results, team_ids)
    existing_result = existing_results.detect { |r| r.person_id == result.participant_id }

    # Ensure true or false, not nil
    # existing_result.preliminary   = result.preliminary ? true : false
    # to_s important. Otherwise, a change from 3 to "3" triggers a DB update.
    existing_result.place         = result.place.to_s
    existing_result.points        = result.points
    existing_result.team_id       = team_ids[result.participant_id]

    # TODO: Why do we need explicit dirty check?
    if existing_result.place_changed? || existing_result.team_id_changed? || existing_result.points_changed? || existing_result.preliminary_changed?
      existing_result.save!
    end

    update_sources_for result, existing_result
  end

  def update_sources_for(result, existing_result)
    existing_sources = existing_result.sources.map { |s| [s.id, s.points.to_f] }
    new_sources = result.source_results.map { |s| [s.id || existing_result.id, s.points.to_f] }

    sources_to_create = new_sources - existing_sources
    sources_to_delete = existing_sources - new_sources

    # Delete first because new sources might have same key
    ::Source.where(calculated_result_id: existing_result.id).where(source_result_id: sources_to_delete.map(&:first)).delete_all if sources_to_delete.present?

    sources_to_create.each do |source|
      create_source existing_result, source.first, source.second
    end
  end

  def delete_calculated_results_for(results, race)
    Rails.logger.debug "delete_calculated_results_for #{race.name}"
    if results.present?
      ::ResultSource.where(calculated_result_id: results).delete_all
      ::Result.where(id: results).delete_all
    end
  end

  def create_result_source(calculated_result, source_result_id, points)
    ::ResultSource.create!(
      source_result_id: source_result_id,
      calculated_result_id: calculated_result.id,
      points: points
    )
  end

  def date
    event&.date || Time.zone.local(year).beginning_of_year
  end

  def end_date
    event&.end_date || Time.zone.local(year).end_of_year
  end

  def dates_are_same_year
    errors.add(:date, "must be in year #{year}, but is #{date.year}") unless year == date.year
    errors.add(:end_date, "must be in year #{year}, but is #{end_date.year}") unless year == end_date.year

    if event && year != event.year
      errors.add(:event, "year #{event.year} must be same as year #{year}")
    end

    if source_event && year != source_event.year
      errors.add(:source_event, "year #{source_event.year} must be same as year #{year}")
    end
  end
end
