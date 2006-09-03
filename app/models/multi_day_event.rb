# Calculate start_date, end_date, and date from events. 
# date = start_date
# OneDayEvents with no events default to start_date of Jan 1st and end_date of Dec 31
# Save date to database, though this is a slight denormalization.
# TODO Build new child event should populate child event with parent data
class MultiDayEvent < Event

  PROPOGATED_ATTRIBUTES = ["city", "discipline", "flyer", "flyer_approved", "name", "promoter_id", "sanctioned_by", "state"] unless defined?(PROPOGATED_ATTRIBUTES)

  validates_presence_of :name, :date
  validate_on_create {:parent.nil?}
  validate_on_update {:parent.nil?}
  
  before_save :update_date
  
  has_many :events, 
           :class_name => 'SingleDayEvent',
           :foreign_key => "parent_id",
           :order => "date"

  def MultiDayEvent.find_all_by_year(year)
    # Workaround Rails class loader behavior
    WeeklySeries
    start_of_year = Date.new(year, 1, 1)
    end_of_year = Date.new(year, 12, 31)
    return MultiDayEvent.find(
      :all,
      :conditions => ["date >= ? and date <= ? and type = ?", start_of_year, end_of_year, "MultiDayEvent"],
      :order => "date"
    )
  end

  def MultiDayEvent.new_from_events(events)
    if events.empty?
      raise ArgumentError.new("events cannot be empty")
    end
    
    first_event = events.first
    length = events.last.date - first_event.date
    if events.size - 1 == length
      multi_day_event = MultiDayEvent.new
    else
      if first_event.date.wday == 0 or first_event.date.wday == 6
        multi_day_event = Series.new
      else
        multi_day_event = WeeklySeries.new
      end
    end

    multi_day_event.city = first_event.city
    multi_day_event.discipline = first_event.discipline
    multi_day_event.flyer = first_event.flyer
    multi_day_event.name = first_event.name
    multi_day_event.promoter = first_event.promoter
    multi_day_event.sanctioned_by = first_event.sanctioned_by
    multi_day_event.state = first_event.state

    for event in events
      multi_day_event.events << event
      event.parent = multi_day_event
    end
    
    return multi_day_event
  end
  
  def initialize(attributes = nil)
    super
    self.date = Time.new.beginning_of_year
  end
  
  def update_events(original_event_attributes)
    for attribute in PROPOGATED_ATTRIBUTES
      original_value = original_event_attributes[attribute]
      new_value = self[attribute]
      RACING_ON_RAILS_DEFAULT_LOGGER.debug("#{attribute}, #{original_value}, #{new_value}")
      if original_value.nil?
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
  
  def date
    update_date
    self[:date]
  end
  
  def start_date
    if !events.empty?
      events.first.date
    else
      date    
    end
  end
  
  def end_date
    if !events.empty?
      events.last.date
    else
      date = Date.new(Date.today.year, 12, 31)
    end
  end
  
  def date_range_s
    start_date_s = "#{start_date.month}/#{start_date.day}"
    if start_date == end_date
    	start_date_s
    elsif start_date.month == end_date.month
      "#{start_date_s}-#{end_date.day}"
    else
      "#{start_date_s}-#{end_date.month}/#{end_date.day}"
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
  
  def to_s
    "<#{self.class} #{id} #{discipline} #{name} #{date} #{events.size}>"
  end
  
  def friendly_class_name
    "Multi-Day Event"
  end
  
  
  protected
  
  def update_date
    if frozen?
      return
    end
    
    if !events.empty?
      self[:date] = start_date
    else
      _date = self[:date] || Date.today
      self[:date] = Date.new(_date.year, 1, 1)
    end
  end
end