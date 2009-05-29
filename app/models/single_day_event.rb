# Event that takes place on one day only
#
# Notifies parent event on save or destroy
class SingleDayEvent < Event
  validate :parent_not_single_day_event
  
  before_create :set_bar_points

  def SingleDayEvent.find_all_by_year(year, discipline = nil, sanctioned_by = ASSOCIATION.show_only_association_sanctioned_races_on_calendar)
    conditions = ["date between ? and ? and practice = ?", "#{year}-01-01", "#{year}-12-31", false]
#mbratodo: I had the following so that practice events would be included:
#     conditions = ["date between ? and ?", "#{year}-01-01", "#{year}-12-31"]


    if sanctioned_by
      conditions.first << " and sanctioned_by = ?"
      conditions << ASSOCIATION.short_name
    end
    
    if discipline
      conditions.first << " and discipline = ?"
      conditions << discipline.name
    end

    SingleDayEvent.find(:all, :conditions => conditions)
  end
  
  def series_event?
    parent && parent.is_a?(WeeklySeries)
  end

  def set_bar_points
    self.bar_points = 0 if series_event?
    true
  end
  
  def missing_parent?
    !missing_parent.nil?
  end
  
  def missing_parent
    if parent_id.nil? 
      MultiDayEvent.same_name_and_year(self)
    else
      nil
    end
  end

  def friendly_class_name
    'Single Day Event'
  end
  
  def parent_not_single_day_event
    errors.add(:parent, "SingleDayEvents cannot be children of other SingleDayEvents") if parent.is_a?(SingleDayEvent)
  end
  
  def to_s
    "#<#{self.class} #{id} #{parent_id} #{discipline} #{name} #{date}>"
  end
end
