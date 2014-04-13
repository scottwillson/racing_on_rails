# Event that takes place on one day only
#
# Notifies parent event on save or destroy
class SingleDayEvent < Event
  validate :parent_not_single_day_event

  before_create :set_bar_points

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
