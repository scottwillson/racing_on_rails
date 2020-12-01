# frozen_string_literal: true

require "acts_as_tree/extensions"

# Superclass for anything that can have results:
# * Event (Superclass only used to organizes multiple sets of results on a single day.
#          Examples: Alpenrose Challenge Morning Session, Alpenrose Challenge Afternoon Session)
# * SingleDayEvent (Most events, an event on a particular date. Appears on calendar.)
# * MultiDayEvent (Spans more than one day. has many SingleDayEvent children)
# * Competition (Results are calculated/derived from other events' results. Examples: Combined TT times, OBRA BAR)
#
# instructional: class or clinc
# practice: training session
#
# Events have four similar, but distinct relationships to other Events:
# * parent-children: A one-to-many tree. Example: stage race parent + stages children.
#   Used for calculating competition results and schedule display. Does _not_ include
#   Competitions, even though Competitions can have Event parents.
#
#   A purer children association would return all child Events and Competitions
#  (that's how they are in the database). But we almost always want just the child Events,
#   and not the Competitions.
#
# * parent-child_competitions: A one-to-many tree. Example: stage race MultiDayEvent parent
#   with GC and KOM child_competitions. Typically combined with children when we really
#   do want all child Competitions and Events.
#
# * competition_event_memberships: many-to-many from Events to Competitions. Example: Banana Belt I
#   can be a member of the Oregon Cup and the OBRA Road BAR. And the Oregon Cup also includes Kings Valley RR,
#   Table Rock RR, etc. CompetitionEventMembership is a meaningul class in its own right.
#
# Changes to parent Event's attributes are propogated to children, unless the children's attributes are already different.
# See propogated_attributes
#
# It's debatable whether we need STI subclasses or not.
class Event < ApplicationRecord
  TYPES = %w[ Event SingleDayEvent MultiDayEvent Series WeeklySeries ].freeze unless defined?(TYPES)

  include Events::Children
  include Events::Comparison
  include Events::Competitions
  include Events::Dates
  include Events::Defaults
  include Events::Naming
  include Events::Previous
  include Events::Promoters
  include Events::Slugs
  include Events::Results
  include ActsAsTree::Extensions
  include RacingOnRails::PaperTrail::Versions
  include Export::Events
  include Sanctioned

  before_save :set_team
  before_destroy :destroy_event_team_memberships

  validates :date, presence: true
  validates :name, presence: true

  validate :inclusion_of_discipline

  has_one :calculation,
          class_name: "Calculations::V3::Calculation",
          dependent: :nullify,
          inverse_of: :event

  has_many :calculations,
           class_name: "Calculations::V3::Calculation",
           dependent: :destroy,
           foreign_key: :source_event_id,
           inverse_of: :source_event

  has_many :event_teams, dependent: :destroy
  has_many :event_team_memberships, through: :event_teams
  belongs_to :number_issuer, optional: true
  belongs_to :team, optional: true

  has_many :races,
           inverse_of: :event,
           dependent: :destroy,
           after_add: :children_changed,
           after_remove: :children_changed

  belongs_to :velodrome, optional: true
  belongs_to :region, optional: true

  scope :today_and_future, -> { where("date >= :today || end_date >= :today", today: Time.zone.today) }
  scope :year, ->(year) { where(date: year_range(year)) }
  # Actually this is effective_year
  scope :current_year, -> { where(date: RacingAssociation.current.effective_year_range) }
  scope :current_year_and_later, -> { where("date > ?", Time.zone.now.beginning_of_year) }
  scope :upcoming_in_weeks, lambda { |number_of_weeks|
    where(
      "(date between :today and :later) || (end_date between :today and :later)",
      today: Time.zone.today,
      later: number_of_weeks.weeks.from_now.to_date
    )
  }

  def self.name_like(name)
    return Event.none if name.blank?

    Event.where("name like ?", "%#{name.strip}%").order(:date)
  end

  def self.upcoming(weeks = 2)
    single_day_events = upcoming_single_day_events(weeks)
    if association_sanctioned_only?
      single_day_events = single_day_events.default_sanctioned_by
    end

    multi_day_events = multi_day_events(single_day_events)
    multi_day_event_ids = multi_day_events.ids
    single_day_events = single_day_events.reject { |event| multi_day_event_ids.include?(event.parent_id) }

    single_day_events + multi_day_events
  end

  def self.association_sanctioned_only?
    RacingAssociation.current.show_only_association_sanctioned_races_on_calendar? &&
      RacingAssociation.current.default_sanctioned_by.present?
  end

  def self.upcoming_single_day_events(weeks)
    SingleDayEvent
      .where(postponed: false)
      .where(canceled: false)
      .where(practice: false)
      .upcoming_in_weeks(weeks)
  end

  def self.multi_day_events(single_day_events)
    MultiDayEvent
      .where(postponed: false)
      .where(canceled: false)
      .where(practice: false)
      .where(type: "MultiDayEvent")
      .where(id: single_day_events.map(&:parent_id))
  end

  # Defaults state to RacingAssociation.current.state, date to today, name to Untitled
  def self.find_all_for_team_and_discipline(team, discipline, date = Time.zone.today)
    first_of_year = date.beginning_of_year
    last_of_year = date.end_of_year
    discipline_names = [discipline]
    discipline_names << "Circuit" if discipline.casecmp("road").zero?
    discipline_names << "Road/Gravel" if discipline.casecmp("road").zero?
    Event.select("distinct events.id, events.*")
         .where("events.date" => first_of_year..last_of_year)
         .where("events.discipline" => discipline_names)
         .where("bar_points > 0")
         .where("events.team_id" => team)
  end

  def self.year_range(year)
    Time.zone.local(year).beginning_of_year.to_date..Time.zone.local(year).end_of_year.to_date
  end

  def source_result_events
    Event
      .joins("inner join races")
      .joins("inner join result_sources")
      .joins("inner join results as calculated_results")
      .joins("inner join results as source_results")
      .where("result_sources.calculated_result_id = calculated_results.id")
      .where("result_sources.source_result_id = source_results.id")
      .where("source_results.race_id = races.id")
      .where("source_results.event_id = events.id")
      .where("calculated_results.event_id": id)
      .where("calculated_results.rejected": false)
      .where("result_sources.rejected": false)
      .distinct
  end

  def destroy_races
    transaction do
      destroy_results

      # Call to destroy won't remove destroyed records from association
      # Call to clear won't invoke all before_destroy callbacks
      races.each(&:destroy)
      races.delete(races.select(&:destroyed?))
      true
    end
  end

  # All races' Categories and all children's races' Categories
  def categories
    race_categories = races.map(&:category)
    children.inject(race_categories) { |cats, child| cats + child.categories }
  end

  def city_state
    if city.present?
      if state.present?
        "#{city}, #{state}"
      else
        city
      end
    else
      state.presence || ""
    end
  end

  def location
    city_state
  end

  # Will split on comma if city, state
  def location=(value)
    if value.present?
      self.city, self.state = value.split(",")
      self.city = city.strip if city
      self.state = state.strip if state
    else
      self.city = nil
      self.state = nil
    end
  end

  def velodrome_name=(value)
    self.velodrome = Velodrome.find_or_create_by(name: value.strip) if value.present?
  end

  def discipline_id
    Discipline[discipline].try :id
  end

  def inclusion_of_discipline
    if discipline.present? && Discipline.names.present? && Discipline.names.exclude?(discipline)
      errors.add :discipline, "'#{discipline}' is not in #{Discipline.names.join(', ')}"
    end
  end

  def parent_name=(value)
    if value.present? && parent_id.blank?
      self.parent = MultiDayEvent.new(name: value, updater: new_record? ? updater : nil)
    end
  end

  def team_name
    team&.name
  end

  def team_name=(value)
    @new_team_name = value
  end

  # Find or create associated Team based on new_team_name
  def set_team
    if new_team_name.present?
      self.team = Team.find_by_name_or_alias_or_create(new_team_name)
    elsif new_team_name == ""
      self.team = nil
    end
  end

  def association?
    number_issuer.try(:association?)
  end

  def type_modifiable?
    type.nil? || %w[ Event SingleDayEvent MultiDayEvent Series WeeklySeries ].include?(type)
  end

  def as_json(_)
    super(
      only: %i[date discipline id name parent_id type],
      methods: [:sorted_races],
      include: {
        sorted_races: {
          only: [:name],
          methods: %i[name sorted_results],
          include: {
            sorted_results: {
              only: %i[person_id place points team_id]
            }
          }
        }
      }
    )
  end

  def inspect_debug
    puts to_s
    races.reload.sort.each(&:inspect_debug)
    children.reload.sort.each(&:inspect_debug)

    ""
  end

  def to_s
    "<#{self.class} #{id} #{discipline} #{name} #{start_date} #{end_date}"
  end

  private

  def destroy_results
    races.each do |race|
      # Call to destroy won't remove destroyed records from association
      # Call to clear won't invoke all before_destroy callbacks
      race.results.each(&:destroy)
      race.results.delete(race.results.select(&:destroyed?))
    end
  end

  def destroy_event_team_memberships
    event_team_memberships.each(&:destroy)
  end

  def self.three_relation_union(relation_1, relation_2, relation_3)
    # No simple way to do lazy union of three Arel relations
    events_table = Event.arel_table
    union = Event.from(events_table.create_table_alias(relation_1.union(relation_2), :events)).union(relation_3)
    Event.from(events_table.create_table_alias(union, :events))
  end
end
