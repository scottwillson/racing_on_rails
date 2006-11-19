# Event that takes place on one day only. By convention, this Event is the only subclass
# that has Standings and Results.
#
# Notifys parent event on save or destroy
class SingleDayEvent < Event

  after_save {|event| event.parent.after_child_event_save if event.parent}
  after_destroy {|event| event.parent.after_child_event_destroy if event.parent}
  
  belongs_to :parent, 
             :foreign_key => "parent_id", 
             :class_name => "MultiDayEvent"
  
  def SingleDayEvent.find_all_by_year_month(year, month)
    start_of_month = Date.new(year, month, 1)
    # TODO Better way to do this?
    end_of_month = start_of_month >> 1
    end_of_month = end_of_month - 1
    events = find(
      :all,
      :conditions => ["date >= ? and date <= ?", start_of_month, end_of_month],
      :order => "date"
    )
    return events
  end
  
  def SingleDayEvent.find_all_by_year(year)
    SingleDayEvent.find(
      :all,
      :conditions => ["date >= ? and date <= ? and sanctioned_by = ?",
                      "#{year}-01-01", "#{year}-12-31", ASSOCIATION.short_name])
  end
  
  def initialize(attributes = nil)
    super
    @days_of_week = Set.new
  end
  
  # Child/single day of MultiDayEvent?
  def series_event?
    parent and (parent.is_a?(WeeklySeries))
  end

  def friendly_class_name
    'Single Day Event'
  end
  
  def to_s
    "#<#{self.class} #{id} #{parent_id} #{discipline} #{name} #{date}>"
  end
end