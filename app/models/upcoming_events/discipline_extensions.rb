module UpcomingEvents
  module DisciplineExtensions
    # TODO Just cache these and make them call find_...
    attr_accessor :upcoming_events
    attr_accessor :upcoming_weekly_series

    def find_all_upcoming_events(dates)
      single_day_events = SingleDayEvent.find(
        :all, 
        :conditions => scope_by_sanctioned(['date between ? and ? and cancelled = false and parent_id is null and discipline in (?)', dates.begin, dates.end, self.names]),
        :order => 'date')

      # Find MultiDayEvents, not their children, nor MultiDayEvents subclasses
      multi_day_events = MultiDayEvent.find(
        :all, 
        :include => :events,
        :conditions => scope_by_sanctioned([%Q{ events_events.date between ? and ? and 
                                                events.cancelled = false and 
                                                events.practice = false and
                                                events.instructional = false and 
                                                events.discipline in (?) and 
                                                events.type = ?}, 
                                            dates.begin, dates.end, self.names, "MultiDayEvent"]),
        :order => 'events.date')

      # Find Series events, but not their parents, nor WeeklySeries
      series_events = SingleDayEvent.find(
          :all, 
          :include => :parent,
          :conditions => scope_by_sanctioned(
                           [%Q{ events.date between ? and ? 
                                and events.cancelled = false 
                                and events.instructional = false 
                                and events.practice = false 
                                and events.parent_id is not null 
                                and parents_events.type = ?
                                and parents_events.discipline in (?) }, 
                            dates.begin, dates.end, "Series", self.names]),
          :order => 'events.date') 
      
      single_day_events + multi_day_events + series_events
    end

    def find_all_upcoming_weekly_series(dates)
      WeeklySeries.find(
        :all, 
        :include => :events,
        :conditions => scope_by_sanctioned([%Q{ events_events.date between ? and ? and 
                                                events.cancelled = false and 
                                                events.practice = false and
                                                events.instructional = false and 
                                                events.discipline in (?)}, 
                                            dates.begin, dates.end, self.names]),
        :order => 'events.date')
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
end