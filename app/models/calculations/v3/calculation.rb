# frozen_string_literal: true

# Rules to create and calculate results for event based on another event's results.
# Older code uses the term "Competition.""
# Link source event(s) with caculated Event.
# Handle all ActiveRecord work. All calculation occurs in pure-Ruby Calculator and Models.
class Calculations::V3::Calculation < ApplicationRecord
  has_and_belongs_to_many :categories # rubocop:disable Rails/HasAndBelongsToMany
  belongs_to :event, dependent: :destroy, inverse_of: :calculation, optional: true
  belongs_to :source_event, class_name: "Event"

  # Find all source results with coarse scope (year, source_events)
  # Map results and calculation rules to calculate models
  # model calculate
  # serialize to DB
  def calculate!
    ActiveSupport::Notifications.instrument "calculate.calculations.#{name}.racing_on_rails" do
      transaction do
        event = create_event!
        source_event.children << event
        results = results_to_models(source_results)
        model_categories = categories_to_models(categories)
        event_categories = Calculations::V3::Calculator.new(model_categories).calculate!(results)
        save_results event_categories
      end
    end
  end

  def source_results
    Result.all
  end

  # Map ActiveRecord records to Calculations::V3::Models so Calculator can calculate! them
  def results_to_models(source_results)
    source_results.map do |result|
      Calculations::V3::Models::SourceResult.new(
        id: result.id,
        participant: Calculations::V3::Models::Participant.new(result.person_id),
        place: result.place
      )
    end
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
      category = Category.find_or_create_by(name: event_category.name)
      race = event.races.create!(category: category)

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
