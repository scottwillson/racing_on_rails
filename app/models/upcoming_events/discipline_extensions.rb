module UpcomingEvents
  module DisciplineExtensions
    attr_accessor :upcoming_events
    attr_accessor :upcoming_weekly_series

    def find_all_upcoming_events(dates)
      single_day_events = SingleDayEvent.all(
        :conditions => scope_by_sanctioned(['date between ? and ? and cancelled = false and parent_id is null and discipline in (?)', dates.begin, dates.end, self.names]),
        :order => 'date')

      # Find MultiDayEvents, not their children, nor MultiDayEvents subclasses
      multi_day_events = MultiDayEvent.all(
        :select => "distinct events.id, events.name, events.date, events.discipline, events.flyer, events.flyer_approved, events.beginner_friendly, events.bar_points, events.website, events.registration_link, events.number_issuer_id, events.parent_id",
        :joins => "left outer join events as childrens_events on childrens_events.parent_id = events.id",
        :conditions => scope_by_sanctioned([%Q{ childrens_events.date between ? and ? and 
                                                (childrens_events.type is null or childrens_events.type = 'SingleDayEvent') and
                                                events.cancelled = false and 
                                                events.practice = false and
                                                events.instructional = false and 
                                                events.discipline in (?) and 
                                                events.type = ? }, 
                                            dates.begin, dates.end, self.names, "MultiDayEvent"]),
        :order => 'events.date')

      # Find Series events, but not their parents, nor WeeklySeries
      series_events = SingleDayEvent.all(
          :select => "distinct events.id, events.name, events.date, events.discipline, events.flyer, events.flyer_approved, events.beginner_friendly, events.bar_points, events.website, events.registration_link, events.parent_id",
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
      WeeklySeries.all(
        :select => "distinct events.id, events.name, events.date, events.discipline, events.flyer, events.flyer_approved, events.beginner_friendly, events.bar_points, events.website, events.registration_link, events.parent_id",
        :joins => "left outer join events as childrens_events on childrens_events.parent_id = events.id",
        :conditions => scope_by_sanctioned([%Q{ childrens_events.date between ? and ? and 
                                                (childrens_events.type is null or childrens_events.type = 'SingleDayEvent') and
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
      if RacingAssociation.current.show_only_association_sanctioned_races_on_calendar
        conditions[0] = conditions.first + ' and events.sanctioned_by = ?'
        conditions << RacingAssociation.current.default_sanctioned_by
      else
        conditions
      end
    end
  end
end