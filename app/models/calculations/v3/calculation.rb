# frozen_string_literal: true

# Rules to create and calculate results for event based on another event's results.
# Older code uses the term "Competition.""
# Link source event(s) with caculated Event.
# Handle all ActiveRecord work. All calculation occurs in pure-Ruby Calculator and Models.
class Calculations::V3::Calculation < ApplicationRecord
  serialize :points_for_place, Array

  has_and_belongs_to_many :categories # rubocop:disable Rails/HasAndBelongsToMany
  belongs_to :event, dependent: :destroy, inverse_of: :calculation, optional: true
  belongs_to :source_event, class_name: "Event"

  before_save :set_name

  def set_name
    if name == "New Calculation" && source_event
      self.name = "#{source_event.name}: Overall"
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

  def add_event!
    unless event
      event = create_event!(date: source_event.date, end_date: source_event.end_date, name: "Overall")
      source_event.children << event
    end
  end

  def source_results
    Result
      .joins(race: :event)
      .where("events.parent_id" => source_event)
      .where.not(competition_result: true)
      .where(year: year)
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
        date: event.date,
        end_date: event.end_date,
        id: id
      )

      if event.parent_id
        model_event.parent = model_events[event.parent_id]
      end

      cache[id] = model_event
    end
  end

  def model_source_events
    source_event
      .children
      .reject(&:competition?)
      .reject { |e| e == event }
      .map { |event| model_events[event.id] }
  end

  def rules
    Calculations::V3::Rules.new(
      categories: categories_to_models(categories),
      double_points_for_last_event: double_points_for_last_event?,
      minimum_events: minimum_events,
      points_for_place: points_for_place,
      reject_worst_results: reject_worst_results,
      source_events: model_source_events
    )
  end

  # Map ActiveRecord records to Calculations::V3::Models so Calculator can calculate! them.
  # Categories are a subset of "rules."
  def categories_to_models(categories)
    categories.map do |category|
      Calculations::V3::Models::Category.new(category.name)
    end
  end

  # Change to generic persist
  # Destroy obsolete races
  def save_results(event_categories)
    ActiveSupport::Notifications.instrument "save_results.calculations.#{name}.racing_on_rails" do
      event_categories.each do |event_category|
        category = Category.find_or_create_by_normalized_name(event_category.name)
        race = event.races.find_or_create_by!(
          category: category,
          rejected: event_category.rejected?,
          rejection_reason: event_category.rejection_reason
        )

        event_category.results.each do |result|
          result_record = race.results.create!(
            person_id: result.participant.id,
            place: result.place,
            points: result.points,
            rejected: result.rejected?,
            rejection_reason: result.rejection_reason,
            team_id: team_id(result)
          )

          result.source_results.each do |source_result|
            result_record.sources.create!(
              points: source_result.points,
              rejected: source_result.rejected?,
              rejection_reason: source_result.rejection_reason,
              source_result_id: source_result.id
            )
          end
        end
      end
    end
  end

  def team_id(result)
    Person.where(id: result.participant.id).pluck(:team_id).first
  end

  delegate :year, to: :source_event
end
