# Event that takes place on one day only
#
# Notifies parent event on save or destroy
class SingleDayEvent < Event
  validate :parent_not_single_day_event
  
  before_create :set_bar_points

  def SingleDayEvent.find_all_by_year(year, discipline = nil, sanctioned_by = RacingAssociation.current.show_only_association_sanctioned_races_on_calendar)
    conditions = ["date between ? and ?", "#{year}-01-01", "#{year}-12-31"]
    SingleDayEvent.find_all_by_conditions(conditions, discipline, sanctioned_by)
  end

  def SingleDayEvent.find_all_by_unix_dates(start_date, end_date, discipline = nil, sanctioned_by = RacingAssociation.current.show_only_association_sanctioned_races_on_calendar)
    conditions = ["date between ? and ?", "#{Time.at(start_date.to_i).strftime('%Y-%m-%d')}", "#{Time.at(end_date.to_i).strftime('%Y-%m-%d')}"]
    SingleDayEvent.find_all_by_conditions(conditions, discipline, sanctioned_by)
  end

  def SingleDayEvent.find_all_by_conditions(conditions, discipline = nil, sanctioned_by = RacingAssociation.current.show_only_association_sanctioned_races_on_calendar)
    conditions.first << " and practice in (?)"
    conditions << [RacingAssociation.current.show_practices_on_calendar?, false]

    if sanctioned_by
      conditions.first << " and sanctioned_by = ?"
      conditions << RacingAssociation.current.default_sanctioned_by
    end

    if discipline
      conditions.first << " and discipline = ?"
      conditions << discipline.name
    end

    SingleDayEvent.find.all( :conditions => conditions)
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
