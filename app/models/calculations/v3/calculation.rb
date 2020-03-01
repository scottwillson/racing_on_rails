# frozen_string_literal: true

# Rules to create and calculate results for event based on another event's results.
# Older code uses the term "Competition.""
# Link source event(s) with caculated Event.
# Handle all ActiveRecord work. All calculation occurs in pure-Ruby Calculator and Models.
#
# Source results selected in two large steps:
#   1. SQL. Apply broad criteria like current year, series events
#   2. Ruby. Apply rules like "best of 6".
# The distinction between SQL and Ruby is somewhat arbritrary. Could load _all_
# results and do all selection and rejection in Ruby. For both performance and
# clarity, some results are filtered early by SQL. For example, no one expects
# criterium and track results to show in the Road BAR.
class Calculations::V3::Calculation < ApplicationRecord
  GROUP_BY = %w[age category].freeze
  PLACE_BY = %w[fewest_points place points time].freeze

  include ActiveSupport::Benchmarkable
  include Calculations::V3::CalculationConcerns::Cache
  include Calculations::V3::CalculationConcerns::CalculatedResults
  include Calculations::V3::CalculationConcerns::Dates
  include Calculations::V3::CalculationConcerns::Races
  include Calculations::V3::CalculationConcerns::ResultSources
  include Calculations::V3::CalculationConcerns::RulesConcerns
  include Calculations::V3::CalculationConcerns::SaveResults
  include Calculations::V3::CalculationConcerns::SourceResults

  serialize :points_for_place
  serialize :source_event_keys, Array

  has_many :calculation_categories, class_name: "Calculations::V3::Category", dependent: :destroy, inverse_of: :calculation
  has_many :calculations_events, class_name: "Calculations::V3::Event", dependent: :destroy
  has_many :categories, through: :calculation_categories, class_name: "::Category"
  has_many :calculation_disciplines, class_name: "Calculations::V3::Discipline", dependent: :destroy
  # Discipline of calculated results' event
  belongs_to :discipline, class_name: "::Discipline"
  # Only count results in these disciplines
  has_many :disciplines, through: :calculation_disciplines
  belongs_to :event, class_name: "::Event", inverse_of: :calculation, optional: true
  has_many :events, through: :calculations_events, class_name: "::Event"
  belongs_to :source_event, class_name: "::Event", optional: true

  accepts_nested_attributes_for :calculation_categories, allow_destroy: true
  accepts_nested_attributes_for :calculations_events, allow_destroy: true

  before_destroy :destroy_event
  before_save :set_name
  after_save :expire_cache

  validate :maximum_events_negative, unless: :blank?
  validates :event, uniqueness: { allow_nil: true }
  validates :key, uniqueness: { allow_nil: true, scope: :year }
  validates :group_by, inclusion: { in: GROUP_BY }
  validates :place_by, inclusion: { in: PLACE_BY }

  default_value_for(:discipline_id) { ::Discipline[RacingAssociation.current.default_discipline]&.id }
  default_value_for :event_notes, ""
  default_value_for :points_for_place, nil

  def self.latest(key)
    where(key: key).order(:year).last
  end

  def add_event!
    benchmark "add_event!.#{key}.calculate.calculations" do
      return if event

      if source_event
        event = create_event!(
          date: source_event.date,
          discipline: source_event.discipline,
          end_date: source_event.end_date,
          name: event_name,
          notes: event_notes
        )
        source_event.children << event
      else
        self.event = create_event!(
          date: Time.zone.local(year).beginning_of_year,
          discipline: discipline.name,
          end_date: Time.zone.local(year).end_of_year,
          name: event_name,
          notes: event_notes
        )
      end
    end
  end

  # Find all source results with coarse scope (year, source_events)
  # Map results and calculation rules to calculate models
  # model calculate
  # serialize to DB
  def calculate!(source_calculations: true)
    ActiveSupport::Notifications.instrument "calculate.calculations.#{name}.racing_on_rails" do
      calculate_source_calculations if source_calculations
      add_event!
      update_event_dates
      results = results_to_models(source_results)
      calculator = Calculations::V3::Calculator.new(
        calculations_events: model_calculations_events,
        logger: logger,
        rules: rules,
        source_events: model_source_events,
        source_results: results,
        year: year
      )
      event_categories = nil
      benchmark "calculate!.#{key}.calculator.calculate.calculations" do
        event_categories = calculator.calculate!
      end
      benchmark "save_results.#{key}.calculate.calculations" do
        save_results event_categories
      end
      GC.start
      expire_cache
    end

    true
  end

  def calculate_source_calculations
    benchmark "calculate_source_calculations.#{key}.calculate.calculations" do
      Calculations::V3::Calculation.where(key: source_event_keys, year: year).find_each(&:calculate!)
    end
  end

  def calculated?(event)
    event&.type != "SingleDayEvent"
  end

  def category_names
    categories.map(&:name)
  end

  def destroy_event
    event&.destroy_races
    event&.destroy
  end

  def event_name
    if source_event
      if team?
        "Team Competition"
      else
        "Overall"
      end
    else
      name
    end
  end

  def expire_cache
    ApplicationController.expire_cache
  end

  def group_event_keys
    group && Calculations::V3::Calculation.where(group: group, year: year).pluck(:key)
  end

  def maximum_events_negative
    # Dupe with Rules
    if !maximum_events.is_a?(Integer) || maximum_events.to_i.positive?
      errors.add(:maximum_events, "must be an integer < 1, but is #{maximum_events.class} #{maximum_events}")
    end
  end

  def set_name
    if name == "New Calculation" && source_event
      if team?
        self.name = "#{source_event.name}: Team Competition"
      else
        self.name = "#{source_event.name}: Overall"
      end
    end
  end

  def update_event_dates
    benchmark "update_event_dates.#{key}.calculate.calculations" do
      if source_event && source_event.dates != event.dates
        event.date = source_event.date
        event.end_date = source_event.end_date
        event.save!
      end
    end
  end

  def years
    Calculations::V3::Calculation.where(key: key).pluck(:year)
  end
end
