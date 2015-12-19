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
class Event < ActiveRecord::Base
  TYPES = %w( Event SingleDayEvent MultiDayEvent Series WeeklySeries )

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
  include RacingOnRails::VestalVersions::Versioned
  include Export::Events
  include Sanctioned

  before_save :set_team
  before_destroy :destroy_event_team_memberships

  validates :date, presence: true
  validates :name, presence: true

  validate :inclusion_of_discipline

  has_many :event_teams, dependent: :destroy
  has_many :event_team_memberships, through: :event_teams
  belongs_to :number_issuer
  belongs_to :team

  has_many :races,
           inverse_of: :event,
           dependent: :destroy,
           after_add: :children_changed,
           after_remove: :children_changed

  belongs_to :velodrome
  belongs_to :region

  scope :today_and_future, -> { where("date >= :today || end_date >= :today", today: Time.zone.today) }
  scope :year, ->(year) { where(date: year_range(year)) }
  # Actually this is effective_year
  scope :current_year, -> { where(date: RacingAssociation.current.effective_year_range) }
  scope :current_year_and_later, -> { where("date > ?", Time.zone.now.beginning_of_year) }
  scope :upcoming_in_weeks, ->(number_of_weeks) {
    where(
      "(date between :today and :later) || (end_date between :today and :later)",
      today: Time.zone.today,
      later: number_of_weeks.weeks.from_now.to_date)
  }

  def self.upcoming(weeks = 2)
    single_day_events   = upcoming_single_day_events(weeks)
    multi_day_events    = upcoming_multi_day_events(weeks)
    series_child_events = upcoming_series_child_events(weeks, multi_day_events)

    if RacingAssociation.current.show_only_association_sanctioned_races_on_calendar? && single_day_events.default_sanctioned_by.present?
      single_day_events = single_day_events.default_sanctioned_by
      multi_day_events = multi_day_events.default_sanctioned_by
      series_child_events = series_child_events.default_sanctioned_by
    end

    # TODO Need to make this lazy-load again
    single_day_events + multi_day_events + series_child_events
  end

  def self.upcoming_single_day_events(weeks)
    SingleDayEvent
      .not_child
      .where(postponed: false)
      .where(cancelled: false)
      .where(practice: false)
      .upcoming_in_weeks(weeks)
  end

  def self.upcoming_multi_day_events(weeks)
    MultiDayEvent
      .where(postponed: false)
      .where(cancelled: false)
      .where(practice: false)
      .where(type: "MultiDayEvent")
      .upcoming_in_weeks(weeks)
  end

  def self.upcoming_series_child_events(weeks, multi_day_events)
    SingleDayEvent
      .includes(parent: :parent)
      .child
      .where(postponed: false)
      .where(cancelled: false)
      .where(practice: false)
      .where.not(parent_id: multi_day_events)
      .upcoming_in_weeks(weeks)
  end

  # Defaults state to RacingAssociation.current.state, date to today, name to Untitled
  def self.find_all_for_team_and_discipline(team, discipline, date = Time.zone.today)
    first_of_year = date.beginning_of_year
    last_of_year = date.end_of_year
    discipline_names = [discipline]
    discipline_names << 'Circuit' if discipline.downcase == 'road'
    Event.select("distinct events.id, events.*")
      .where("events.date" => first_of_year..last_of_year)
      .where("events.discipline" => discipline_names)
      .where("bar_points > 0")
      .where("events.team_id" => team)
  end

  def self.year_range(year)
    Time.zone.local(year).beginning_of_year.to_date..Time.zone.local(year).end_of_year.to_date
  end

  def destroy_races
    transaction do
      destroy_combined_results
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
      if state.present?
        state
      else
        ''
      end
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
    if value.present?
      self.velodrome = Velodrome.find_or_create_by(name: value.strip)
    end
  end

  def discipline_id
    Discipline[discipline].try :id
  end

  def inclusion_of_discipline
    if discipline.present? && Discipline.names.present? && !Discipline.names.include?(discipline)
      errors.add :discipline, "'#{discipline}' is not in #{Discipline.names.join(', ')}"
    end
  end

  def team_name
    team.name if team
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
    type.nil? || %w( Event SingleDayEvent MultiDayEvent Series WeeklySeries ).include?(type)
  end

  def as_json(_)
    super(
      only: [ :discipline, :name, :parent_id, :type ],
      methods: [ :sorted_races ],
      include: {
        sorted_races: {
          only: [ :name ],
          methods: [ :name, :sorted_results ],
          include: {
            sorted_results: {
              only: [ :person_id, :place, :points, :team_id ]
            }
          }
        }
      }
    )
  end

  def inspect_debug
    puts to_s
    races(true).sort.each(&:inspect_debug)
    children(true).sort.each(&:inspect_debug)

    ""
  end

  def to_s
    "<#{self.class} #{id} #{discipline} #{name} #{start_date} #{end_date}"
  end

  private

  def destroy_combined_results
    if combined_results
      combined_results.destroy_races
      combined_results.destroy
    end
  end

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
