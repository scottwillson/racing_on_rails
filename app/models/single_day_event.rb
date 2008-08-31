# Event that takes place on one day only. By convention, this Event is the only subclass
# that has Standings and Results.
#
# Notifys parent event on save or destroy
class SingleDayEvent < Event

  after_save {|event| event.parent.after_child_event_save if event.parent}
  after_destroy {|event| event.parent.after_child_event_destroy if event.parent}
  
  belongs_to :parent, 
             :foreign_key => 'parent_id', 
             :class_name => 'Event'
  
  def SingleDayEvent.find_all_by_year(year, discipline = nil)
    conditions = ["date between ? and ?", "#{year}-01-01", "#{year}-12-31"]

    if ASSOCIATION.show_only_association_sanctioned_races_on_calendar
      conditions.first << " and sanctioned_by = ?"
      conditions << ASSOCIATION.short_name
    end
    
    if discipline
      conditions.first << " and discipline = ?"
      conditions << discipline.name
    end

    SingleDayEvent.find(:all, :conditions => conditions)
  end
  
  # Child/single day of MultiDayEvent?
  def series_event?
    parent and (parent.is_a?(WeeklySeries))
  end

  def missing_parent?
    !missing_parent.nil?
  end
  
  def missing_parent
    if self.parent_id.nil? 
      MultiDayEvent.same_name_and_year(self)
    else
      nil
    end
  end
  
  def full_name
    if parent.nil?
      name
    elsif parent.name == name
      name
    elsif name[parent.name]
      name
    else
      "#{parent.name} #{name}"
    end
  end

  def friendly_class_name
    'Single Day Event'
  end
  
  def to_s
    "#<#{self.class} #{id} #{parent_id} #{discipline} #{name} #{date}>"
  end
end