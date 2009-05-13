# All SingleDayEvents that will occur in the next +weeks+. Used to display a list of upcoming events
# on the homepage. Organized by parent class (WeeklySeries and everything else) and Discipline:
# @events: Hash keyed by Discipline#name
# @weekly_series: Hash keyed by Discipline#name
#
# Does not simply add +weeks+ to date when selecting events -- applies a week boundary on Monday
module UpcomingEvents
  class Base < Array
    # TODO Apply some OO loving
    # TODO Sort events by date: sort {|x, y| x.date <=> y.date
    # TODO Sort weekly series:
    # TODO Rename to List or Array? Maybe change scoping to Events::Upcoming or Upcoming::Events
    # TODO Is discipline scope really applied correctly for MultiDayEvents?

    attr_reader :date, :discipline, :disciplines, :weeks
    
    # Date = start date. Defaults to today
    def initialize(date, weeks, discipline)
      @date = date || Date.today
      @discipline = discipline
      @disciplines = disciplines_for(discipline)
      @weeks = weeks || 2
    end
  
    # By default, we'll search "all" disciplines (Road and Mountain Bike include other disciplines),
    # but if +discipline+ is present, we will only search that one
    def disciplines_for(discipline)
      if discipline
        [Discipline[discipline]]
      else
        [Discipline[:road], Discipline[:mountain_bike], Discipline[:bmx], Discipline[:track], Discipline[:cyclocross]]
#mbratodo: I had the following fix
        #alphere this is causing nil discipline error in UpcomingEvents.find_all
        #[Discipline[:road], Discipline[:mountain_bike], Discipline[:bmx], Discipline[:track], Discipline[:cyclocross]]
        #works: [Discipline[:road]]
#        disciplines = Array.new
#        Discipline.find_all_names.each do | name |
#          disciplines << (Discipline[name.to_sym]) unless name.to_s == ''
#        end
#        disciplines
      end
    end
    
    def dates
      @dates ||= (date.to_date..cutoff_date.to_date)
    end
    
    # Set date to nearest Monday
    def cutoff_date
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
  
    def empty?
      disciplines.all? { |discipline| discipline.upcoming_events.empty? && discipline.upcoming_weekly_series.empty? }
    end
  
    # Get Discipline by name
    def [](discipline_name)
      disciplines.detect { |discipline| discipline.name == discipline_name }
    end
  end
end