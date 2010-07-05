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
  validates_presence_of :name, :date
  validate_on_create { :parent.nil? }
  validate_on_update { :parent.nil? }

  before_save :update_children
  after_create :create_children
  
  # TODO Default first child event date to start date, next child to first child date + 1, additional children to next day if adjacent, 
  # same day of next week if not adjacent (Series/WeeklySeries)
  has_many :children, 
           :class_name => "Event",
           :foreign_key => "parent_id",
           :conditions => "type is null or type = 'SingleDayEvent'", 
           :after_add => [ :children_changed, :update_date ],
           :after_remove => [ :children_changed, :update_date ],
           :order => "date" do
             def create!(attributes = {})
               attributes[:parent_id] = @owner.id
               attributes[:parent] = @owner
               PROPOGATED_ATTRIBUTES.each { |attr| attributes[attr] = @owner[attr] }               
               event = SingleDayEvent.new(attributes)
               (event.date = @owner.date) unless attributes[:date]
               event.parent = @owner
               event.save!
               @owner.children << event
               event
             end

             def create(attributes = {})
               attributes[:parent_id] = @owner.id
               attributes[:parent] = @owner
               PROPOGATED_ATTRIBUTES.each { |attr| attributes[attr] = @owner[attr] }               
               event = SingleDayEvent.new(attributes)
               (event.date = @owner.date) unless  attributes[:date]
               event.parent = @owner
               event.save
               @owner.children << event
               event
             end
           end

  def MultiDayEvent.find_all_by_year(year, discipline = nil)
    conditions = ["date between ? and ?", "#{year}-01-01", "#{year}-12-31"]

    if ASSOCIATION.show_only_association_sanctioned_races_on_calendar
      conditions.first << " and sanctioned_by = ?"
      conditions << ASSOCIATION.default_sanctioned_by
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
  def MultiDayEvent.create_from_children(children)
    raise ArgumentError.new("children cannot be empty") if children.empty?
    
    first_event = children.first
    new_event_attributes = {
      :city => first_event.city,
      :discipline => first_event.discipline,
      :email => first_event.email,
      :flyer => first_event.flyer,
      :name => first_event.name,
      :phone => first_event.phone,
      :promoter => first_event.promoter,
      :prize_list => first_event.prize_list,
      :sanctioned_by => first_event.sanctioned_by,
      :state => first_event.state,
      :team => first_event.team,
      :velodrome => first_event.velodrome
    }
    
    new_multi_day_event_class = MultiDayEvent.guess_type(children)
    multi_day_event = new_multi_day_event_class.create!(new_event_attributes)
    multi_day_event.disable_notification!

    children.each do |child|
      multi_day_event.children << child
    end

    multi_day_event.enable_notification!
    multi_day_event
  end
  
  def MultiDayEvent.guess_type(name, date)
    events = SingleDayEvent.find(:all, :conditions => ['name = ? and extract(year from date) = ?', name, date])
    MultiDayEvent.guess_type(events)
  end
  
  # This fails if a stage race spans more than one day but has more events than days
  # we could look for events that span contiguous days...but a long stage race could have a rest day...
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

  def default_date
    Time.new.beginning_of_year
  end
  
  # Create child events automatically, if we've got enough info to do so
  def create_children
    return unless start_date && @end_date && @every
    
    _start_date = start_date
    until @every.include?(_start_date.wday)
      _start_date = _start_date.next 
    end
    
    _start_date.step(@end_date, 1) do |date|
      children.create!(:date => date) if @every.include?(date.wday)
    end
  end
  
  # Uses SQL query to set +date+ from child events
  def update_date(child = nil)
    return true if new_record?
    
    minimum_date = Event.minimum(:date, :conditions => { :parent_id => id })
    unless minimum_date.blank?
      # Don't trigger callbacks
      MultiDayEvent.update_all(["date = ?", minimum_date], ["id = ?", id])
      self.date = minimum_date
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
  
  # +format+:
  # * :short: 6/7-6/12
  # * :long: 6/7/2010-6/12/2010
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
      "#{start_date_s} to #{end_date.strftime('%a, %B %d, %Y')}"
    end
  end
  
  # Unassociated events with same name in same year
  def missing_children
    return [] unless name && date
    
    @missing_children ||= SingleDayEvent.find(:all, 
                          :conditions => ['parent_id is null and name = ? and extract(year from date) = ?', 
                                          name, date.year])
  end
  
  # All children have results?
  def completed?(reload = false)
    children.count(reload) > 0 && (children_with_results(reload).size == children.count)
  end
  
  def to_s
    "<#{self.class} #{id} #{discipline} #{name} #{date} #{children.size}>"
  end
end
