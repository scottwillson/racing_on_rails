# All SingleDayEvents that will occur in the next +weeks+. Used to display a list of upcoming events
# on the homepage. Organized by parent class (WeeklySeries and everything else) and Discipline:
# @events: Hash keyed by Discipline#name
# @weekly_series: Hash keyed by Discipline#name
#
# Does not simply add +weeks+ to date when selecting events -- applies a week boundary on Monday
class UpcomingEvents
  
  attr_reader :events, :weekly_series
  
  # Date = start date. Defaults to today
  def initialize(date = Date.today, weeks = 2)
    date = date || Date.today
    weeks = weeks || 2
    _events = SingleDayEvent.find(
      :all, 
      :conditions => scope_by_sanctioned(['date >= ? and date <= ? and cancelled = ? and parent_id is null', 
                      date.to_time.beginning_of_day, cutoff_date(date, weeks), false]),
      :order => 'date')

    _events.concat(MultiDayEvent.find(
        :all, 
        :include => :events,
        :conditions => scope_by_sanctioned(['events_events.date >= ? and events_events.date <= ? and events.type = ?', 
                        date.to_time.beginning_of_day, cutoff_date(date, weeks), 'MultiDayEvent']),
        :order => 'events.date'))

    series_events = (SingleDayEvent.find(
        :all, 
        :include => :parent,
        :conditions => scope_by_sanctioned(['events.date >= ? and events.date <= ? and events.cancelled = ? and events.parent_id is not null', 
            date.to_time.beginning_of_day, cutoff_date(date, weeks), false]),
        :order => 'events.date'))
    # Cannot apply condition  with Rails-generated SQL
    _events.concat(series_events.select {|event| event.parent.is_a?(Series) and !event.parent.is_a?(WeeklySeries)})
    
    weekly_series_events = SingleDayEvent.find(
      :all, 
      :include => :parent,
      :conditions => [
        'events.date >= ? and events.date <= ? and events.sanctioned_by = ? and events.cancelled = ? and events.parent_id is not null', 
                      date.to_time.beginning_of_day, cutoff_date(date, weeks), ASSOCIATION.short_name, false],
      :order => 'events.date')
      # Cannot apply condition  with Rails' generated SQL
      weekly_series_events.reject! {|event| !event.parent.is_a?(WeeklySeries)}
    
    for event in weekly_series_events
      event.parent.days_of_week << event.date
    end
    @events = Hash.new
    @weekly_series = Hash.new
    unique_weekly_series = weekly_series_events.collect {|event| event.parent}.to_set
    
    for discipline in ['Road', 'Mountain Bike', 'Track', 'Cyclocross']
      @events[discipline] = []
      @weekly_series[discipline] = []
    end

    for event in _events
      case event.discipline
      when 'Mountain Bike'
        @events['Mountain Bike'] << event
      when 'Track'
        @events['Track'] << event
      when'Cyclocross'
        @events['Cyclocross'] << event
      else
        @events['Road'] << event
      end
    end

    for event in unique_weekly_series
      case event.discipline
      when 'Mountain Bike'
        @weekly_series['Mountain Bike'] << event
      when 'Track'
        @weekly_series['Track'] << event
      when'Cyclocross'
        @weekly_series['Cyclocross'] << event
      else
        @weekly_series['Road'] << event
      end
    end
  end
    
  # Set date to nearest Monday
  def cutoff_date(date, weeks)
    case date.wday
    when 0
      date + (weeks.to_i * 7)
    when 1
      date + (weeks.to_i * 7) - 1
    when 2
      date + (weeks.to_i * 7) - 2
    when 3
      date + (weeks.to_i * 7) - 3
    when 4
      date + (weeks.to_i * 7) - 4
    when 5
      date + (weeks.to_i * 7) - 5
    when 6
      date + (weeks.to_i * 7) + 1
    end
  end
  
  private
  
  # Awkward method to add sanctioned_by to conditions
  def scope_by_sanctioned(conditions)
    if ASSOCIATION.show_only_association_sanctioned_races_on_calendar
      conditions[0] = conditions.first + ' and events.sanctioned_by = ?'
      conditions << ASSOCIATION.short_name
    else
      conditions
    end
  end
end
