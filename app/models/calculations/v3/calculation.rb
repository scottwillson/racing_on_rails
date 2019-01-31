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
        event = create_event!(name: "Overall")
        source_event.children << event
        results = results_to_models(source_results)
        calculator = Calculations::V3::Calculator.new(logger: logger, rules: rules, source_results: results)
        event_categories = calculator.calculate!
        save_results event_categories
      end
    end
  end

  def source_results
    Result
      .joins(race: :event)
      .where("events.parent_id" => source_event)
  end

  # Map ActiveRecord records to Calculations::V3::Models so Calculator can calculate! them
  def results_to_models(source_results)
    source_results.map do |result|
      category = Calculations::V3::Models::Category.new(result.race_name)
      Calculations::V3::Models::SourceResult.new(
        id: result.id,
        event_category: Calculations::V3::Models::EventCategory.new(category),
        participant: Calculations::V3::Models::Participant.new(result.person_id),
        place: result.place
      )
    end
  end

  def rules
    Calculations::V3::Rules.new(
      categories: categories_to_models(categories),
      points_for_place: points_for_place
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
    event_categories.each do |event_category|
      category = Category.find_or_create_by_normalized_name(event_category.name)
      race = event.races.find_or_create_by!(category: category)

      event_category.results.each do |result|
        person = Person.find(result.participant.id)
        result_record = race.results.create!(
          person: person,
          place: result.place,
          points: result.points
        )

        result.source_results.each do |source_result|
          result_record.sources.create!(
            points: source_result.points,
            source_result_id: source_result.id
          )
        end
      end
    end
  end
end
