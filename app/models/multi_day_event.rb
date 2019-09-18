# frozen_string_literal: true

# Event that spans more than one day: stage races, six days, omniums
# MultiDayEvents represent events that occur on concurrent days, and Series and
# WeeklySeries subclasses represent events that do not occur on concurrent days, though
# this is just a convention.
#
# Calculate start_date, end_date, and date from children.
# date = start_date
#
# Cannot have a parent event
#
# New child event should populate child event with parent data, but they don't
class MultiDayEvent < Event
  validates :name, :date, presence: true
  validate on: :create do |event|
    event.parent.nil?
  end
  validate on: :update do |event|
    event.parent.nil?
  end

  before_save :update_children

  # TODO: Default first child event date to start date, next child to first child date + 1, additional children to next day if adjacent,
  # same day of next week if not adjacent (Series/WeeklySeries)
  has_many :children,
           -> {
             where("type is null or type = 'SingleDayEvent'")
               .order(:date)
           },
           class_name: "Event",
           foreign_key: "parent_id",
           after_add: %i[children_changed update_date],
           after_remove: %i[children_changed update_date] do
             def create!(attributes = {})
               owner = proxy_association.owner
               attributes[:parent_id] = owner.id
               attributes[:parent] = owner
               event = SingleDayEvent.new(attributes)
               (event.date = owner.date) unless attributes[:date]
               event.parent = owner
               event.save!
               owner.children << event
               event
             end

             def create(attributes = {})
               owner = proxy_association.owner
               attributes[:parent_id] = owner.id
               attributes[:parent] = owner
               event = SingleDayEvent.new(attributes)
               (event.date = owner.date) unless attributes[:date]
               event.parent = owner
               event.save
               owner.children << event
               event
             end
           end

  # Create MultiDayEvent from several SingleDayEvents.
  # Use first SingleDayEvent to populate date, name, promoter, etc.
  # Guess subclass (MultiDayEvent, Series, WeeklySeries) from SingleDayEvent dates
  def self.create_from_children(children)
    raise ArgumentError, "children cannot be empty" if children.empty?

    first_event = children.first
    new_event_attributes = {
      city: first_event.city,
      discipline: first_event.discipline,
      email: first_event.email,
      flyer: first_event.flyer,
      name: first_event.name,
      phone: first_event.phone,
      promoter: first_event.promoter,
      prize_list: first_event.prize_list,
      sanctioned_by: first_event.sanctioned_by,
      state: first_event.state,
      team: first_event.team,
      velodrome: first_event.velodrome
    }

    new_multi_day_event_class = MultiDayEvent.guess_type(children)
    multi_day_event = new_multi_day_event_class.create!(new_event_attributes)

    children.each do |child|
      multi_day_event.children << child
    end

    multi_day_event
  end

  # Expects a value from Date::DAYNAMES: Monday, Tuesday, etc., or an array of same. Example: ["Saturday", "Sunday"]
  def self.create_for_every!(days_of_week, params)
    raise(ArgumentError) unless days_of_week && (params[:date] || params[:start_date]) && params[:end_date]

    days_of_week = Array.wrap(days_of_week)
    days_of_week.each do |day|
      raise ArgumentError, "'#{day}' must be in #{Date::DAYNAMES.join(', ')}" unless Date::DAYNAMES.index(day)
    end

    event = create!(params)

    days_of_week_indexes = days_of_week.map { |day| Date::DAYNAMES.index(day) }
    start_date = event.date
    start_date = start_date.next until days_of_week_indexes.include?(start_date.wday)

    start_date.step(event.end_date, 1) do |date|
      event.children.create!(date: date) if days_of_week_indexes.include?(date.wday)
    end

    event
  end

  def self.guess_type(name, date)
    events = SingleDayEvent.where(name: name).year(date.year)
    MultiDayEvent.guess_type(events)
  end

  # This fails if a stage race spans more than one day but has more events than days
  # we could look for events that span contiguous days...but a long stage race could have a rest day...
  def self.guess_type(events)
    length = events.last.date - events.first.date
    if events.size - 1 == length
      MultiDayEvent
    else
      if (events.first.date.wday == 0) || (events.first.date.wday == 6)
        Series
      else
        WeeklySeries
      end
    end
  end

  def self.same_name_and_year(event)
    raise ArgumentError, "'event' cannot be nil" if event.nil?

    MultiDayEvent.where(name: event.name).year(event.date.year).first
  end

  # Uses SQL query to set +date+ from child events. Callbacks pass in unsued child parameter.
  def update_date(_child = nil)
    return true if new_record? || destroyed?

    child_dates = child_dates_query.pluck(:date)
    if child_dates.present?
      self.date = child_dates.min
      self.end_date = child_dates.max
      if date_changed? || end_date_changed?
        # Don't trigger callbacks
        MultiDayEvent.where(id: id).update_all(date: date, end_date: end_date)
      end
    end
  end

  def child_dates_query
    if is_a?(Competitions::Competition) || calculation.present?
      Event.where(parent_id: id).where(cancelled: false).where(postponed: false)
    else
      SingleDayEvent
        .where(parent_id: id)
        .where(cancelled: false)
        .where(postponed: false)
    end
  end

  def set_end_date
    children_for_date = children

    unless is_a?(Competitions::Competition) || calculation.present?
      children_for_date = children_for_date.reject { |child| child.is_a?(Competitions::Competition) }
    end

    self.end_date = children_for_date.map(&:date).max || date if self[:end_date].nil?
  end

  def end_date_s
    "#{end_date.month}/#{end_date.day}"
  end

  # +format+:
  # * :short: 6/7-6/12
  # * :long: 6/7/2010-6/12/2010
  def date_range_s(format = :short)
    if format == :long
      if start_date == end_date
        date.strftime("%-m/%-d/%Y")
      else
        "#{start_date.strftime('%-m/%-d/%Y')}-#{end_date.strftime('%-m/%-d/%Y')}"
      end
    else
      start_date_s = "#{start_date.month}/#{start_date.day}"
      if start_date == end_date
        start_date_s
      elsif start_date.month == end_date.month
        "#{start_date_s}-#{end_date.day}"
      else
        "#{start_date_s}-#{end_date.month}/#{end_date.day}"
      end
    end
  end

  # Unassociated events with same name in same year
  def missing_children
    return [] unless name && date

    @missing_children ||= SingleDayEvent.where(parent_id: nil).where(name: name).year(date.year)
  end

  # All children have results?
  def completed?
    children.present? && (children_with_results.size == children.count)
  end

  # Synch Races with children. More accurately: create a new Race on each child Event for each Race on the parent.
  def propagate_races
    children.each do |event|
      races.map(&:category).each do |category|
        event.races.create!(category: category) unless event.races.map(&:category).include?(category)
      end
    end
  end

  def to_s
    "<#{self.class} #{id} #{discipline} #{name} #{date} #{children.size}>"
  end
end
