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
  include Calculations::V3::CalculationConcerns::CalculatedResults
  include Calculations::V3::CalculationConcerns::Dates
  include Calculations::V3::CalculationConcerns::RulesConcerns
  include Calculations::V3::CalculationConcerns::SourceResults

  serialize :points_for_place, Array
  serialize :source_event_keys, Array

  has_many :calculation_categories, class_name: "Calculations::V3::Category", dependent: :destroy
  has_many :calculations_events, class_name: "Calculations::V3::Event", dependent: :destroy
  has_many :categories, through: :calculation_categories, class_name: "::Category"
  has_many :calculation_disciplines, class_name: "Calculations::V3::Discipline", dependent: :destroy
  has_many :disciplines, through: :calculation_disciplines
  belongs_to :event, class_name: "::Event", dependent: :destroy, inverse_of: :calculation, optional: true
  has_many :events, through: :calculations_events, class_name: "::Event"
  belongs_to :source_event, class_name: "Event", optional: true

  before_save :set_name

  validates :key, uniqueness: { allow_nil: true, scope: :year }

  default_value_for :points_for_place, []

  def add_event!
    return if event

    if source_event
      event = create_event!(date: source_event.date, end_date: source_event.end_date, name: "Overall")
      source_event.children << event
    else
      self.event = create_event!(
        date: Time.zone.local(year).beginning_of_year,
        end_date: Time.zone.local(year).end_of_year,
        name: name
      )
    end
  end

  # Find all source results with coarse scope (year, source_events)
  # Map results and calculation rules to calculate models
  # model calculate
  # serialize to DB
  def calculate!
    ActiveSupport::Notifications.instrument "calculate.calculations.#{name}.racing_on_rails" do
      transaction do
        calculate_source_calculations
        add_event!
        results = results_to_models(source_results)
        calculator = Calculations::V3::Calculator.new(logger: logger, rules: rules, source_results: results)
        event_categories = calculator.calculate!
        save_results event_categories
      end
    end

    true
  end

  def calculate_source_calculations
    Calculations::V3::Calculation.where(key: source_event_keys, year: year).find_each(&:calculate!)
  end

  def calculated?(event)
    event.competition? || event.type.nil? || event.type == "Event"
  end

  def category_names
    categories.map(&:name)
  end

  def set_name
    if name == "New Calculation" && source_event
      self.name = "#{source_event.name}: Overall"
    end
  end
end
