# Event that spans more than one day: stage races, six days, omniums
# MultiDayEvents represent events that occur on concurrent days, and Series and 
# WeeklySeries subclasses represent events that do not occur on concurrent days, though
# this is just a convention.
#
# Calculate start_date, end_date, and date from events. 
# date = start_date
#
# Cannot have a parent event
#
# By convention, only SingleDayEvents have Standings and Results -- MultiDayEvents do not. 
# Final standings like Overall GC are associated with the last day's SingleDayEvent.
#
# Building large object trees of events and children and memory may not work correctly.
# Prefer +create+ over +new+ and +build+
#
# TODO Build new child event should populate child event with parent data
class MultiDayEvent < Event

  PROPOGATED_ATTRIBUTES = %w{ cancelled city discipline flyer flyer_approved 
                              instructional name practice promoter_id 
                              prize_list sanctioned_by state time velodrome_id
                             } unless defined?(PROPOGATED_ATTRIBUTES)

  validates_presence_of :name, :date
  validate_on_create {:parent.nil?}
  validate_on_update {:parent.nil?}
  
  before_save :update_date
  before_save :update_events
  after_create :create_events
  
  has_many :events, 
           :class_name => 'SingleDayEvent',
           :foreign_key => "parent_id",
           :order => "date" do
             def create!(attributes = {})
               attributes[:parent_id] = @owner.id
               attributes[:parent] = @owner
               PROPOGATED_ATTRIBUTES.each { |attr| attributes[attr] = @owner[attr] }               
               event = SingleDayEvent.new(attributes)
               event.parent = @owner
               event.save!
               event
             end

             def create(attributes = {})
               attributes[:parent_id] = @owner.id
               attributes[:parent] = @owner
               PROPOGATED_ATTRIBUTES.each { |attr| attributes[attr] = @owner[attr] }               
               event = SingleDayEvent.new(attributes)
               event.parent = @owner
               event.save
               event
             end
           end
  
  def MultiDayEvent.find_all_by_year(year, discipline = nil)
    conditions = ["date between ? and ?", "#{year}-01-01", "#{year}-12-31"]

    if ASSOCIATION.show_only_association_sanctioned_races_on_calendar
      conditions.first << " and sanctioned_by = ?"
      conditions << ASSOCIATION.short_name
    end
    
    if discipline
      conditions.first << " and discipline = ?"
      conditions << discipline.name
    end

    MultiDayEvent.find(:all, :conditions => conditions, :order => "date")
  end

  # Create MultiDayEvent from several SingleDayEvents.
  # Use first SingleDayEvent to populate date, name, promoter, etc.
  # Guess subclass (MultiDayEvent, Series, WeeklySeries) from SingleDayEvent dates
  def MultiDayEvent.create_from_events(events)
    if events.empty?
      raise ArgumentError.new("events cannot be empty")
    end
    
    first_event = events.first
    new_event_attributes = {
      :city => first_event.city,
      :discipline => first_event.discipline,
      :flyer => first_event.flyer,
      :name => first_event.name,
      :promoter => first_event.promoter,
      :prize_list => first_event.prize_list,
      :sanctioned_by => first_event.sanctioned_by,
      :state => first_event.state,
      :velodrome => first_event.velodrome
    }
    
    new_multi_day_event_class = MultiDayEvent.guess_type(events)
    multi_day_event = new_multi_day_event_class.create!(new_event_attributes)

    for event in events
      event.parent = multi_day_event
      event.save!
    end

    multi_day_event.events(true)
    multi_day_event
  end
  
  def MultiDayEvent.guess_type(name, date)
    events = SingleDayEvent.find(:all, :conditions => ['name = ? and extract(year from date) = ?', name, date])
    MultiDayEvent.guess_type(events)
  end
  
  def MultiDayEvent.guess_type(events)
    length = events.last.date - events.first.date
    if events.size - 1 == length
     MultiDayEvent
    else
      if events.first.date.wday == 0 or events.first.date.wday == 6
        Series
      else
        WeeklySeries
      end
    end
  end
  
  def MultiDayEvent.same_name_and_year(event)
    raise ArgumentError, "'event' cannot be nil" if event.nil?
    MultiDayEvent.find(:first, :conditions => ['name = ? and extract(year from date) = ?', event.name, event.date.year])
  end
  
  def initialize(attributes = nil)
    super
    self.date = Time.new.beginning_of_year unless self[:date]
  end
  
  # Update child events from parents' attributes if child attribute has the
  # same value as the parent before update
  # TODO original_values is duplicating Rails 2.1's dirty
  def update_events(force = false)
    return if new_record?
    
    original_values = MultiDayEvent.connection.select_one("select #{PROPOGATED_ATTRIBUTES.join(', ')} from events where id = #{self.id}")
    for attribute in PROPOGATED_ATTRIBUTES
      original_value = original_values[attribute]
      new_value = self[attribute]
      RACING_ON_RAILS_DEFAULT_LOGGER.debug("MultiDayEvent update_events #{attribute}, #{original_value}, #{new_value}")
      if force
        SingleDayEvent.update_all(
          ["#{attribute}=?", new_value], 
          ["parent_id=?", self[:id]]
        )
      elsif original_value.nil?
        SingleDayEvent.update_all(
          ["#{attribute}=?", new_value], 
          ["#{attribute} is null and parent_id=?", self[:id]]
        ) unless original_value == new_value
      else
        SingleDayEvent.update_all(
          ["#{attribute}=?", new_value], 
          ["#{attribute}=? and parent_id=?", original_value, self[:id]]
        ) unless original_value == new_value
      end
    end
  end
  
  # Create child events automatically, if we've got enough info to do so
  def create_events
    return unless start_date && @end_date && @every
    
    _start_date = start_date
    until @every.include?(_start_date.wday)
      _start_date = _start_date.next 
    end
    
    _start_date.step(@end_date, 1) do |date|
      events.create!(:date => date) if @every.include?(date.wday)
    end
  end
  
  def after_child_event_save
    update_date
  end
  
  def after_child_event_destroy
    update_date
  end
  
  # Uses SQL query to set +date+ from child events
  def update_date
    return if new_record?
    
    minimum_date = MultiDayEvent.connection.select_value("select min(date) from events where parent_id = #{id}")
    unless minimum_date.blank? || minimum_date == self.date.to_s
      MultiDayEvent.connection.execute("update events set date = '#{minimum_date}' where id = #{id}")
      self.date = minimum_date
    end
  end

  # +date+
  def start_date
    date
  end
  
  def start_date=(date)
    self.date = date
  end
  
  def end_date
    if !events(true).empty?
      events.last.date
    else
      start_date
    end
  end
  
  # end_date is calculated from child events, and not saved to the DB. If there are no child events, end_date is set to start date.
  # This value is stored in @end_date in memory, and is used to create a new MultiDayEvent with children. Example:
  # MultiDayEvent.create!(:start_date => Date.new(2009, 4), :end_date => Date.new(2009, 10), :every => "Monday")
  def end_date=(value)
    @end_date = value
  end
  
  def end_date_s
    "#{end_date.month}/#{end_date.day}"
  end

  # Expects a value from Date::DAYNAMES: Monday, Tuesday, etc., or an array of same. Example: ["Saturday", "Sunday"]
  def every=(value)
    _every = value
    _every = [_every] unless value.respond_to?(:each)
    
    _every.each do |day|
      raise "'#{day}' must be in #{Date::DAYNAMES.join(', ')}" unless Date::DAYNAMES.index(day)
    end

    @every = _every.map { |day| Date::DAYNAMES.index(day) }
  end
  
  def date_range_s(format = :short)
    if format == :long
      if start_date == end_date
        date.strftime('%m/%d/%Y')
      else
        "#{start_date.strftime('%m/%d/%Y')}-#{end_date.strftime('%m/%d/%Y')}"
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
  
  def date_range_long_s
    start_date_s = start_date.strftime('%a, %B %d')
    if start_date == end_date
      start_date_s
    else
      "#{start_date_s} to #{end_date.strftime('%a, %B %d')}"
    end
  end
  
  def missing_children
   @missing_children ||= SingleDayEvent.find(:all, 
                          :conditions => ['parent_id is null and name = ? and extract(year from date) = ?', 
                                          self.name, self.date.year]) 
  end
  
  # Will return false-positive if there are only overall series results, but those should only exist if there _are_ "real" results.
  # The results page should show the results in that case, and TaborSeriesStandings would just create an empty Standings.
  def has_results_with_children?
    has_results_without_children? || events(true).any? { |event| event.has_results? }
  end
  
  # Number of child events with results
  def events_with_results(reload = false)
    events(reload).inject(0) { |count, event| event.has_results? ? count + 1 : count }
  end
  
  def completed?(reload = false)
    events.count(reload) > 0 && (events_with_results(reload) == events.count)
  end
  
  def to_s
    "<#{self.class} #{id} #{discipline} #{name} #{date} #{events.size}>"
  end

  alias_method_chain :has_results?, :children

end