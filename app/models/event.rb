require_dependency "acts_as_tree/extensions"

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
  TYPES =  [ 'Event', 'SingleDayEvent', 'MultiDayEvent', 'Series', 'WeeklySeries' ]

  after_initialize :set_defaults
  before_destroy :validate_no_results
  before_save :set_promoter, :set_team
  after_save :update_results
  after_destroy :update_parent_date

  validates_presence_of :date, :name

  validate :parent_is_not_self

  validate :inclusion_of_discipline
  validate :inclusion_of_sanctioned_by

  belongs_to :parent, foreign_key: "parent_id", class_name: "Event", touch: true
  has_many :children,
           -> { order :date },
           class_name: "Event",
           foreign_key: "parent_id",
           dependent: :destroy,
           after_add: :children_changed,
           after_remove: :children_changed

  has_many :child_competitions,
           -> { order :date },
           class_name: "Competitions::Competition",
           foreign_key: "parent_id",
           dependent: :destroy,
           after_add: :children_changed,
           after_remove: :children_changed

  has_many :children_and_child_competitions,
           -> { order :date },
           class_name: "Event",
           foreign_key: "parent_id",
           dependent: :destroy

  has_one :overall, foreign_key: "parent_id", dependent: :destroy, class_name: "Competitions::Overall"
  has_one :combined_results, class_name: "CombinedTimeTrialResults", foreign_key: "parent_id", dependent: :destroy
  has_many :competitions, through: :competition_event_memberships, source: :competition, class_name: "Competitions::Competition"
  has_many :competition_event_memberships, class_name: "Competitions::CompetitionEventMembership"

  belongs_to :number_issuer
  has_and_belongs_to_many :editors, class_name: "Person", association_foreign_key: "editor_id", join_table: "editors_events"
  belongs_to :promoter, class_name: "Person"
  belongs_to :team

  has_many   :races,
             inverse_of: :event,
             dependent: :destroy,
             after_add: :children_changed,
             after_remove: :children_changed

  belongs_to :velodrome
  belongs_to :region

  scope :editable_by, lambda { |person|
    if person.nil?
      where("true = false")
    elsif person.administrator?
      # No scope
    else
      joins("left outer join editors_events on event_id = events.id").
      where("promoter_id = :person_id or editors_events.editor_id = :person_id", person_id: person)
    end
  }

  scope :today_and_future, lambda { where("date >= :today || end_date >= :today", today: Time.zone.today) }

  scope :year, lambda { |year|
    where(
      "date between ? and ?",
      Time.zone.local(year).beginning_of_year.to_date,
      Time.zone.local(year).end_of_year.to_date
    )
  }

  scope :current_year, lambda { where(
    "date between ? and ?",
    Time.zone.local(RacingAssociation.current.effective_year).beginning_of_year.to_date,
    Time.zone.local(RacingAssociation.current.effective_year).end_of_year.to_date
    )
  }

  scope :upcoming_in_weeks, lambda { |number_of_weeks|
    where(
      "(date between :today and :later) || (end_date between :today and :later)",
      today: Time.zone.today,
      later: number_of_weeks.weeks.from_now.to_date)
  }

  scope :child, lambda { where("parent_id is not null") }
  scope :not_child, lambda { where("parent_id is null") }

  attr_reader :new_promoter_name
  attr_reader :new_team_name

  include Events::Comparison
  include Events::Dates
  include Events::Naming
  include ActsAsTree::Extensions
  include RacingOnRails::VestalVersions::Versioned
  include Export::Events

  # Return [weekly_series, events] that have results
  # Honors RacingAssociation.current.show_only_association_sanctioned_races_on_calendar
  def self.find_all_with_results(year = Time.zone.today.year, discipline = nil)
    # Maybe this should be its own class, since it has knowledge of Event and Result?
    events = Event.
              joins(races: :results).
              includes(parent: :parent).
              where(
                "events.date between ? and ?",
                Time.zone.local(year).beginning_of_year.to_date,
                Time.zone.local(year).end_of_year.to_date
              ).
              uniq

    if discipline
      discipline_names = [discipline.name]
      if discipline == Discipline['road']
        discipline_names << 'Circuit'
      end
      events = events.where(discipline: discipline_names)
    end

    if RacingAssociation.current.show_only_association_sanctioned_races_on_calendar
      events = events.where(sanctioned_by: RacingAssociation.current.default_sanctioned_by)
    end

    events = events.to_a.map(&:root).uniq

    weekly_series, events = events.partition { |event| event.is_a?(WeeklySeries) }
    competitions, events = events.partition { |event| event.is_a?(Competitions::Competition) }

    [ weekly_series, events, competitions ]
  end

  def self.find_all_bar_for_discipline(discipline, year = Time.zone.today.year)
    discipline_names = [discipline]
    discipline_names << 'Circuit' if discipline.downcase == 'road'
    Event.distinct.year(year).where(discipline: discipline_names).where("bar_points > 0")
  end

  def self.upcoming(weeks = 2)
    single_day_events = SingleDayEvent.
      not_child.
      where(postponed: false).
      where(cancelled: false).
      where(practice: false).
      upcoming_in_weeks(weeks)

    multi_day_events = MultiDayEvent.
      where(postponed: false).
      where(cancelled: false).
      where(practice: false).
      where(type: "MultiDayEvent").
      upcoming_in_weeks(weeks)

    series_child_events = SingleDayEvent.
      includes(parent: :parent).
      child.
      where(postponed: false).
      where(cancelled: false).
      where(practice: false).
      upcoming_in_weeks(weeks)

    if multi_day_events.present?
      series_child_events = series_child_events.where("parent_id not in (?)", multi_day_events.map(&:id))
    end

    if RacingAssociation.current.show_only_association_sanctioned_races_on_calendar?
      single_day_events = single_day_events.where(sanctioned_by: RacingAssociation.current.default_sanctioned_by)
      multi_day_events = multi_day_events.where(sanctioned_by: RacingAssociation.current.default_sanctioned_by)
      series_child_events = series_child_events.where(sanctioned_by: RacingAssociation.current.default_sanctioned_by)
    end

    (single_day_events.load + multi_day_events.load + series_child_events.load)
  end

  # Defaults state to RacingAssociation.current.state, date to today, name to Untitled
  def Event.find_all_for_team_and_discipline(team, discipline, date = Time.zone.today)
    first_of_year = date.beginning_of_year
    last_of_year = date.end_of_year
    discipline_names = [discipline]
    discipline_names << 'Circuit' if discipline.downcase == 'road'
    Set.new(Event.select("distinct events.id, events.*").
      where("events.date between ? and ?", first_of_year, last_of_year).
      where("events.discipline in (?)", discipline_names).
      where("bar_points > 0").
      where("events.team_id = ?", team).
      all
    )
  end

  # Defaults state to RacingAssociation.current.state, date to today, name to New Event mm-dd-yyyy
  # NumberIssuer: RacingAssociation.current.short_name
  # Child events use their parent's values unless explicity overriden. And you cannot override
  # parent values by passing in blank or nil attributes to initialize, as there is
  # no way to differentiate missing values from nils or blanks.
  def set_defaults
    if new_record?
      if parent
        propogated_attributes.each { |attr|
          (self[attr] = parent[attr]) if self[attr].blank?
        }
      end
      self.bar_points = default_bar_points       if self[:bar_points].nil?
      self.date = default_date                   if self[:date].nil?
      self.discipline = default_discipline       if self[:discipline].nil?
      self.name = default_name                   if self[:name].nil?
      self.ironman = default_ironman             if self[:ironman].nil?
      self.number_issuer = default_number_issuer if number_issuer.nil?
      self.region_id = default_region_id         if self[:region_id].nil?
      self.sanctioned_by = default_sanctioned_by if (parent.nil? && self[:sanctioned_by].nil?) || (parent && parent[:sanctioned_by].nil?)
      self.state = default_state                 if (parent.nil? && self[:state].nil?) || (parent && parent[:state].nil?)
    end
  end

  def propogated_attributes
    @propogated_attributes ||= %w{
      city discipline flyer name number_issuer_id promoter_id prize_list sanctioned_by state time velodrome_id time
      postponed cancelled flyer_approved instructional practice sanctioned_by email phone team_id beginner_friendly
    }
  end

  def attributes_for_duplication
    _attributes = attributes.dup
    _attributes.delete("id")
    _attributes.delete("created_at")
    _attributes.delete("updated_at")
    _attributes
  end

  def default_bar_points
    if parent.is_a?(WeeklySeries) || (parent.try(:parent) && parent.parent.is_a?(WeeklySeries))
      0
    else
      1
    end
  end

  def default_discipline
    "Road"
  end

  def default_ironman
    true
  end

  def default_region_id
    RacingAssociation.current.default_region_id
  end

  def default_state
    RacingAssociation.current.state
  end

  def default_sanctioned_by
    RacingAssociation.current.default_sanctioned_by
  end

  def default_number_issuer
    NumberIssuer.find_by_name(RacingAssociation.current.short_name)
  end

  def validate_no_results
    races(true).each do |race|
      if race.results(true).any?
        errors.add('results', 'Cannot destroy event with results')
        return false
      end
    end

    children(true).each do |event|
      errors.add('results', 'Cannot destroy event with children with results')
      return false unless event.validate_no_results
    end

    true
  end

  # Result updated_at should propagate to Event updated_at but does not yet
  def results_updated_at
    Result.where(race_id: races.map(&:id)).maximum(:updated_at)
  end

  # Will return false-positive if there are only overall series results, but those should only exist if there _are_ "real" results.
  # The results page should show the results in that case.
  def has_results?(reload = false)
    races(reload).any? { |r| !r.results(reload).empty? }
  end

  # Will return false-positive if there are only overall series results, but those should only exist if there _are_ "real" results.
  # The results page should show the results in that case.
  def has_results_including_children?(reload = false)
    races(reload).any? { |r| !r.results(reload).empty? } || children(reload).any? { |event| event.has_results?(reload) || event.has_results_including_children? }
  end

  # Returns only the children with +results+
  def children_with_results(reload = false)
    children(reload).select(&:has_results_including_children?)
  end

  # Returns only the children and child child_competitions with +results+
  def children_and_child_competitions_with_results(reload = false)
    children_and_child_competitions(reload).select(&:has_results_including_children?)
  end

  # Returns only the Races with +results+
  def races_with_results
    races.select { |race| race.results.present? }.sort
  end

  def destroy_races
    ActiveRecord::Base.lock_optimistically = false
    transaction do
      if combined_results
        combined_results.destroy_races
        combined_results.destroy
      end
      races.each do |race|
        # Call to destroy won't remove destroyed records from association
        # Call to clear won't invoke all before_destroy callbacks
        race.results.each(&:destroy)
        race.results.delete(race.results.select(&:destroyed?))
      end
      # Call to destroy won't remove destroyed records from association
      # Call to clear won't invoke all before_destroy callbacks
      races.each(&:destroy)
      races.delete(races.select(&:destroyed?))
    end
    ActiveRecord::Base.lock_optimistically = true
  end

  # All races' Categories and all children's races' Categories
  def categories
    _categories = races.map(&:category)
    children.inject(_categories) { |cats, child| cats + child.categories }
  end

  # Update child events from parents' attributes if child attribute has the
  # same value as the parent before update
  def update_children
    return true if new_record? || children.count == 0
    changes.select { |key, value| propogated_attributes.include?(key) }.each do |change|
      attribute = change.first
      was = change.last.first
      if was.blank?
        SingleDayEvent.where(
          "(#{attribute}=? or #{attribute} is null or #{attribute} = '') and parent_id=?", was, self[:id]
        ).update_all(attribute => self[attribute])
      else
        SingleDayEvent.where(attribute => was, parent_id: id).update_all(attribute => self[attribute])
      end
    end

    children.each(&:update_children)
    true
  end

  # Synch Races with children. More accurately: create a new Race on each child Event for each Race on the parent.
  def propagate_races
    # Do nothing in superclass
  end

  def children_changed(child)
    # Don't trigger callbacks
    Event.where(id: id).update_all(updated_at: Time.zone.now)
    true
  end

  # Set point value/factor for this Competition. Convenience method to hide CompetitionEventMembership complexity.
  def set_points_for(competition, points)
    # For now, allow Nil exception, but probably will want to auto-create membership in the future
    competition_event_membership = competition_event_memberships.detect { |cem| cem.competition == competition }
    competition_event_membership.points_factor = points
    competition_event_membership.save!
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
      errors.add :discipline, "'#{discipline}' is not in #{Discipline.names.join(", ")}"
    end
  end

  def inclusion_of_sanctioned_by
    if sanctioned_by && !RacingAssociation.current.sanctioning_organizations.include?(sanctioned_by)
      errors.add :sanctioned_by, "'#{sanctioned_by}' must be in #{RacingAssociation.current.sanctioning_organizations.join(", ")}"
    end
  end

  def promoter_name
    promoter.name if promoter
  end

  def promoter_name=(value)
    @new_promoter_name = value
  end

  def set_promoter
    if new_promoter_name.present?
      promoters = Person.find_all_by_name_or_alias(new_promoter_name)
      case promoters.size
      when 0
        self.promoter = Person.create!(name: new_promoter_name)
      when 1
        self.promoter = promoters.first
      else
        self.promoter = promoters.detect { |promoter| promoter.id == promoter_id } || promoters.first
      end
    elsif new_promoter_name == ""
      self.promoter = nil
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

  # Update cached event attributes
  def update_results
    Result.
      where(event_id: id).
      update_all(
        event_full_name: full_name,
        event_date_range_s: date_range_s,
        event_end_date: end_date,
        date: date
      )

    parent.try :update_date

    true
  end

  def update_parent_date
    parent.try :update_date
    true
  end

  # Find valid email—either promoter's email or event email. If all are blank, raise exception.
  def email!
    if promoter.try(:email).present?
      promoter.email
    elsif email.present?
      email
    else
      raise BlankEmail, "Event #{name} has no email"
    end
  end

  def association?
    number_issuer.try(:association?)
  end

  # Always return false
  def missing_parent?
    false
  end

  def missing_children?
    missing_children.any?
  end

  # Always return empty Array
  def missing_children
    []
  end

  def multi_day_event_children_with_no_parent?
    multi_day_event_children_with_no_parent.any?
  end

  def multi_day_event_children_with_no_parent
    return [] unless name && date

    @multi_day_event_children_with_no_parent ||= SingleDayEvent.where(
        "parent_id is null and name = ? and extract(year from date) = ?
         and ((select count(*) from events where name = ? and extract(year from date) = ? and type in ('MultiDayEvent', 'Series', 'WeeklySeries')) = 0)",
         self.name, self.date.year, self.name, self.date.year)
    # Could do this in SQL
    if @multi_day_event_children_with_no_parent.size == 1
      @multi_day_event_children_with_no_parent = []
    end
    @multi_day_event_children_with_no_parent
  end

  def missing_parent
    nil
  end

  def parent_is_not_self
    if parent_id && parent_id == id
      errors.add("parent", "Event cannot be its own parent")
    end
  end

  def type_modifiable?
    type.nil? || %w{ Event SingleDayEvent MultiDayEvent Series WeeklySeries }.include?(type)
  end

  def inspect_debug
    puts("#{self.class.name.ljust(20)} #{self.date} #{self.name} #{self.discipline} #{self.id}")
    self.races(true).sort.each {|r|
      puts("#{r.class.name.ljust(20)}   #{r.name}")
      r.results(true).sort.each {|result|
        puts("#{result.class.name.ljust(20)}      #{result.to_long_s}")
        result.scores(true).sort.each{|score|
          puts("#{score.class.name.ljust(20)}         #{score.source_result.place} #{score.source_result.race.event.name}  #{score.source_result.race.name} #{score.points}")
        }
      }
    }

    self.children(true).sort.each do |event|
      event.inspect_debug
    end

    ""
  end

  def to_s
    "<#{self.class} #{id} #{discipline} #{name} #{date}>"
  end

  class BlankEmail < StandardError; end
end
